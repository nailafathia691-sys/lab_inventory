import 'dart:async';

import '../auth/session_controller.dart';
import '../core/failures.dart';
import '../core/models.dart';
import '../data/inventory_repository.dart';

// This backend imports no Supabase SDK and never reads production configuration.
class DemoAuthGateway implements AuthGateway {
  final _changes = StreamController<SessionEvent>.broadcast();
  AppProfile? _profile;
  bool admin = false;
  @override
  Stream<SessionEvent> get changes => _changes.stream;
  @override
  Future<void> signIn(String email, String password) async {
    _profile = AppProfile(
      id: admin ? 'demo-admin' : 'demo-student',
      email: '',
      name: admin ? 'Laboran Demo' : 'Mahasiswa Demo',
      identityNumber: 'DEMO',
      role: admin ? AppRole.admin : AppRole.student,
    );
  }

  @override
  Future<AppProfile?> loadProfile() async => _profile;
  @override
  Future<void> signOut() async {
    _profile = null;
    _changes.add(SessionEvent.signedOut);
  }
}

class DemoInventoryRepository implements InventoryRepository {
  DemoInventoryRepository(this.session);
  final SessionController session;
  final List<InventoryItem> _items = [
    const InventoryItem(
      id: 'demo-projector',
      name: 'Proyektor Demo',
      code: 'DEMO-001',
      category: 'Elektronik',
      condition: 'Baik',
      stock: 2,
      location: 'Rak Demo',
    ),
    const InventoryItem(
      id: 'demo-laptop',
      name: 'Laptop Demo',
      code: 'DEMO-002',
      category: 'Komputer',
      condition: 'Baik',
      stock: 3,
      location: 'Rak Demo',
    ),
  ];
  final List<Borrowing> _borrowings = [];
  @override
  Future<List<InventoryItem>> getItems() async {
    session.requireProfile();
    return List.unmodifiable(_items);
  }

  @override
  Future<List<Borrowing>> getBorrowings({
    String? status,
    String? userId,
  }) async {
    final profile = session.requireProfile();
    return _borrowings
        .where(
          (b) =>
              (profile.isAdmin
                  ? userId == null || b.userId == userId
                  : b.userId == profile.id) &&
              (status == null || b.status == status),
        )
        .toList();
  }

  void _admin() {
    if (!session.requireProfile().isAdmin) {
      throw const AppFailure(
        'Hanya laboran demo yang dapat melakukan tindakan ini.',
      );
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
  }) async {
    _admin();
    if (name.trim().isEmpty || stock < 0) {
      throw const AppFailure('Periksa nama dan stok barang.');
    }
    _items.add(
      InventoryItem(
        id: newRequestId(),
        name: name,
        code: 'DEMO-${_items.length + 1}',
        category: category,
        condition: condition,
        stock: stock,
        location: location,
      ),
    );
  }

  @override
  Future<void> createBorrowing({
    required String itemId,
    required int jumlah,
    required DateTime tglPinjam,
    required DateTime tglKembali,
    required String keperluan,
  }) async {
    final profile = session.requireProfile();
    final item = _items.firstWhere((i) => i.id == itemId);
    final error = validateBorrowing(
      item: item,
      amount: jumlah,
      borrowDate: tglPinjam,
      returnDate: tglKembali,
      purpose: keperluan,
    );
    if (error != null) throw AppFailure(error);
    _borrowings.add(
      Borrowing(
        id: newRequestId(),
        userId: profile.id,
        itemId: itemId,
        namaPeminjam: profile.name,
        namaBarang: item.name,
        jumlah: jumlah,
        tglPinjam: tglPinjam,
        tglKembali: tglKembali,
        keperluan: keperluan,
        status: 'pending',
      ),
    );
  }

  @override
  Future<void> updateBorrowingStatus({
    required String id,
    required String status,
    String? notes,
    bool? returnedGood,
  }) async {
    _admin();
    final index = _borrowings.indexWhere((b) => b.id == id);
    if (index < 0) throw const AppFailure('Transaksi demo tidak ditemukan.');
    final b = _borrowings[index];
    if (b.status == status) return;
    if (!(b.isPending && (status == 'approved' || status == 'rejected')) &&
        !(b.isApproved && status == 'returned')) {
      throw const AppFailure('Perubahan status tidak diizinkan.');
    }
    final itemIndex = _items.indexWhere((i) => i.id == b.itemId);
    final item = _items[itemIndex];
    if (status == 'approved' && (!item.canBorrow || item.stock < b.jumlah)) {
      throw const AppFailure('Stok demo tidak mencukupi.');
    }
    if (status == 'returned' && returnedGood == null) {
      throw const AppFailure('Pilih kondisi pengembalian.');
    }
    final stock =
        item.stock +
        (status == 'approved'
            ? -b.jumlah
            : status == 'returned' && returnedGood == true
            ? b.jumlah
            : 0);
    _items[itemIndex] = InventoryItem(
      id: item.id,
      name: item.name,
      code: item.code,
      category: item.category,
      condition: item.condition,
      stock: stock,
      location: item.location,
    );
    _borrowings[index] = Borrowing(
      id: b.id,
      userId: b.userId,
      itemId: b.itemId,
      namaPeminjam: b.namaPeminjam,
      namaBarang: b.namaBarang,
      jumlah: b.jumlah,
      tglPinjam: b.tglPinjam,
      tglKembali: b.tglKembali,
      keperluan: b.keperluan,
      status: status,
      catatanKondisi: notes,
      updatedBy: session.requireProfile().id,
    );
  }
}
