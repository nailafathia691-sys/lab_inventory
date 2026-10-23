import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/session_controller.dart';
import '../core/failures.dart';
import '../core/models.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getItems();
  Future<List<Borrowing>> getBorrowings({
    String? status,
    String? userId,
    bool includeRelations = false,
  });
  Future<void> addItem({
    required String name,
    required String category,
    required String condition,
    required int stock,
    required String location,
    required String description,
  });
  Future<void> createBorrowing({
    required String itemId,
    required int jumlah,
    required DateTime tglPinjam,
    required DateTime tglKembali,
    required String keperluan,
  });
  Future<void> updateBorrowingStatus({
    required String id,
    required String status,
    String? notes,
    bool? returnedGood,
  });
}

abstract class RequestIdStore {
  Future<String> getOrCreate(String operationKey);
  Future<void> complete(String operationKey);
}

String newRequestId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

class PreferencesRequestIdStore implements RequestIdStore {
  PreferencesRequestIdStore(this.preferences);
  final SharedPreferences preferences;
  @override
  Future<String> getOrCreate(String operationKey) async {
    final existing = preferences.getString(operationKey);
    if (existing != null) return existing;
    final id = newRequestId();
    if (!await preferences.setString(operationKey, id)) {
      throw const AppFailure(
        'Tidak dapat menyiapkan permintaan. Periksa penyimpanan perangkat.',
      );
    }
    return id;
  }

  @override
  Future<void> complete(String operationKey) async {
    // Keeping an old key is safe: a retry only reads the committed result.
    await preferences.remove(operationKey);
  }
}

class SupabaseInventoryRepository implements InventoryRepository {
  SupabaseInventoryRepository(this.client, this.session, this.requestIds);
  final SupabaseClient client;
  final SessionController session;
  final RequestIdStore requestIds;
  final Map<String, Future<void>> _inFlight = {};

  void _requireAdmin() {
    if (!session.requireProfile().isAdmin) {
      throw const AppFailure('Tindakan ini hanya tersedia untuk laboran.');
    }
  }

  Future<void> _command(String function, Map<String, dynamic> params) {
    final actor = session.requireProfile();
    if (!actor.transactionsEnabled) {
      throw const AppFailure(
        'Transaksi belum diaktifkan. Laboran perlu menyelesaikan rekonsiliasi stok terlebih dahulu.',
      );
    }
    final key =
        'lab_request:${actor.id}:$function:${base64Url.encode(utf8.encode(jsonEncode(params)))}';
    final running = _inFlight[key];
    if (running != null) return running;
    final operation = _execute(function, params, key, actor.id);
    _inFlight[key] = operation;
    return operation.whenComplete(() => _inFlight.remove(key));
  }

  Future<void> _execute(
    String function,
    Map<String, dynamic> params,
    String key,
    String actorId,
  ) async {
    final requestId = await requestIds.getOrCreate(key);
    if (session.requireProfile().id != actorId) {
      throw const AppFailure(
        'Sesi sudah berubah. Silakan ulangi dari akun aktif.',
      );
    }
    try {
      final result = await client
          .rpc(function, params: {...params, 'p_request_id': requestId})
          .timeout(const Duration(seconds: 20));
      if (result is! Map ||
          result['id'] is! String ||
          (result['id'] as String).isEmpty ||
          (function == 'process_borrowing' &&
              (result['id'] != params['p_borrowing_id'] ||
                  result['status'] != params['p_status']))) {
        throw const AppFailure(
          'Konfirmasi server tidak lengkap. Coba lagi dengan data yang sama.',
          uncertain: true,
        );
      }
    } catch (error) {
      final failure = appFailure(error);
      if (!failure.uncertain) await requestIds.complete(key);
      throw failure;
    }
    // A storage failure after a commit must not turn a successful write into a failure.
    try {
      await requestIds.complete(key);
    } catch (_) {
      /* safe to retain the request ID */
    }
  }

  @override
  Future<List<InventoryItem>> getItems() async {
    session.requireProfile();
    try {
      final rows = await client
          .from('items')
          .select()
          .order('nama_barang')
          .timeout(const Duration(seconds: 15));
      return rows.map(InventoryItem.fromJson).toList();
    } catch (error) {
      throw appFailure(error);
    }
  }

  @override
  Future<List<Borrowing>> getBorrowings({
    String? status,
    String? userId,
    bool includeRelations = false,
  }) async {
    final profile = session.requireProfile();
    try {
      final selection = includeRelations
          ? '*, student:profiles!lab_borrowing_owner(nama,npm), related_item:items!lab_borrowing_item(nama_barang,kode_barang,kategori)'
          : '*';
      var query = client.from('borrowings').select(selection);
      final ownerId = profile.isAdmin ? userId : profile.id;
      if (ownerId != null) query = query.eq('user_id', ownerId);
      if (status != null) query = query.eq('status', status);
      final rows = await query
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 15));
      return rows.map(Borrowing.fromJson).toList();
    } catch (error) {
      throw appFailure(error);
    }
  }

  @override
  Future<void> addItem({
    required String name,
    required String category,
    required String condition,
    required int stock,
    required String location,
    required String description,
  }) {
    _requireAdmin();
    return _command('create_inventory_item', {
      'p_name': name.trim(),
      'p_category': category,
      'p_condition': condition,
      'p_stock': stock,
      'p_location': location.trim(),
      'p_description': description.trim(),
    });
  }

  @override
  Future<void> createBorrowing({
    required String itemId,
    required int jumlah,
    required DateTime tglPinjam,
    required DateTime tglKembali,
    required String keperluan,
  }) {
    session.requireProfile();
    return _command('request_borrowing', {
      'p_item_id': itemId,
      'p_quantity': jumlah,
      'p_borrow_date': businessDate(tglPinjam),
      'p_due_date': businessDate(tglKembali),
      'p_purpose': keperluan.trim(),
    });
  }

  @override
  Future<void> updateBorrowingStatus({
    required String id,
    required String status,
    String? notes,
    bool? returnedGood,
  }) {
    _requireAdmin();
    return _command('process_borrowing', {
      'p_borrowing_id': id,
      'p_status': status,
      'p_notes': notes?.trim() ?? '',
      'p_returned_good': returnedGood,
    });
  }
}
