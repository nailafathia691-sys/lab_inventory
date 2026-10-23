import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lab_inventory/auth/session_controller.dart';
import 'package:lab_inventory/core/failures.dart';
import 'package:lab_inventory/core/models.dart';
import 'package:lab_inventory/data/inventory_repository.dart';

import 'support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SessionController session;
  late FakeAuthGateway gateway;
  late SharedPreferences preferences;
  late SupabaseClient client;
  final requests = <http.Request>[];
  late Future<http.Response> Function(http.Request) handler;
  SupabaseInventoryRepository repository() => SupabaseInventoryRepository(
    client,
    session,
    PreferencesRequestIdStore(preferences),
  );
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    requests.clear();
    gateway = FakeAuthGateway(current: studentProfile);
    session = SessionController(gateway);
    await session.start();
    handler = (_) async =>
        http.Response('[]', 200, headers: {'content-type': 'application/json'});
    client = SupabaseClient(
      'https://example.supabase.co',
      'public-test-key',
      httpClient: MockClient((request) async {
        requests.add(request);
        final response = await handler(request);
        return http.Response.bytes(
          response.bodyBytes,
          response.statusCode,
          headers: response.headers,
          request: request,
        );
      }),
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      postgrestOptions: const PostgrestClientOptions(retryEnabled: false),
    );
  });
  tearDown(() async {
    session.dispose();
    await gateway.events.close();
    await client.dispose();
  });
  Future<void> submit(SupabaseInventoryRepository repo) async =>
      repo.createBorrowing(
        itemId: 'item-a',
        jumlah: 1,
        tglPinjam: DateTime(2026, 10, 18),
        tglKembali: DateTime(2026, 10, 19),
        keperluan: 'Praktikum',
      );

  test('student queries always use the authenticated profile even if another ID is supplied', () async {
    await repository().getBorrowings(userId: 'other-user');
    expect(requests.single.url.queryParameters['user_id'], 'eq.student-a');
  });
  test('borrowing reads map persisted transaction detail metadata', () async {
    handler = (_) async => http.Response(
      jsonEncode([
        {
          'id': 'loan-detail',
          'user_id': 'student-a',
          'item_id': 'item-a',
          'nama_peminjam': 'Mahasiswa A',
          'nama_barang': 'Laptop',
          'jumlah': 2,
          'tgl_pinjam': '2026-10-20',
          'tgl_kembali': '2026-10-21',
          'keperluan': 'Praktikum',
          'status': 'returned',
          'catatan_kondisi': 'Layar rusak',
          'updated_by': 'admin-a',
          'created_at': '2026-10-19T08:30:00Z',
          'approved_at': '2026-10-19T09:00:00Z',
          'returned_at': '2026-10-21T10:15:00Z',
          'returned_good': false,
          'updated_at': '2026-10-21T10:15:00Z',
          'student': {'nama': 'Mahasiswa A', 'npm': '1001'},
          'related_item': {
            'nama_barang': 'Laptop',
            'kode_barang': 'INV-001',
            'kategori': 'Komputer',
          },
        },
      ]),
      200,
      headers: {'content-type': 'application/json'},
    );

    final transaction = (await repository().getBorrowings(
      includeRelations: true,
    )).single;

    expect(transaction.id, 'loan-detail');
    expect(transaction.namaPeminjam, 'Mahasiswa A');
    expect(transaction.namaBarang, 'Laptop');
    expect(transaction.jumlah, 2);
    expect(transaction.createdAt, DateTime.parse('2026-10-19T08:30:00Z'));
    expect(transaction.approvedAt, DateTime.parse('2026-10-19T09:00:00Z'));
    expect(transaction.returnedAt, DateTime.parse('2026-10-21T10:15:00Z'));
    expect(transaction.returnedGood, isFalse);
    expect(transaction.updatedAt, DateTime.parse('2026-10-21T10:15:00Z'));
    expect(
      requests.single.url.queryParameters['select'],
      contains('profiles!lab_borrowing_owner'),
    );
    expect(
      requests.single.url.queryParameters['select'],
      contains('items!lab_borrowing_item'),
    );
    expect(transaction.relatedStudentName, 'Mahasiswa A');
    expect(transaction.studentIdentityNumber, '1001');
    expect(transaction.relatedItemName, 'Laptop');
    expect(transaction.relatedItemCode, 'INV-001');
    expect(transaction.relatedItemCategory, 'Komputer');
  });
  test('read failures throw instead of returning an empty list or sample inventory', () async {
    handler = (_) async =>
        http.Response('{"message":"denied","code":"42501"}', 403);
    await expectLater(repository().getItems(), throwsA(isA<AppFailure>()));
    await expectLater(repository().getBorrowings(), throwsA(isA<AppFailure>()));
  });
  test('genuinely empty inventories stay empty', () async {
    expect(await repository().getItems(), isEmpty);
  });
  test(
    'staged profiles can read but cannot send transaction requests',
    () async {
      gateway.current = AppProfile.fromJson({
        'id': 'staged-admin',
        'nama': 'Laboran',
        'npm': '',
        'role': 'admin',
        'is_active': true,
        'transactions_enabled': false,
      }, 'admin@example.test');
      await session.refresh();
      await repository().getItems();
      expect(requests.length, 1);
      requests.clear();
      for (final action in <Future<void> Function()>[
        () => submit(repository()),
        () =>
            repository().updateBorrowingStatus(id: 'loan', status: 'approved'),
        () => repository().addItem(
          name: 'Item',
          category: 'Komputer',
          condition: 'Baik',
          stock: 1,
          location: '',
          description: '',
        ),
      ]) {
        await expectLater(
          Future.sync(action),
          throwsA(
            isA<AppFailure>().having(
              (error) => error.message,
              'message',
              contains('rekonsiliasi stok'),
            ),
          ),
        );
      }
      expect(requests, isEmpty);
    },
  );
  test(
    'missing sessions prevent commands before any network request',
    () async {
      await session.signOut();
      await expectLater(submit(repository()), throwsA(isA<AppFailure>()));
      expect(requests, isEmpty);
    },
  );
  test('student admin mutations fail before contacting the API', () async {
    await expectLater(
      Future.sync(
        () => repository().updateBorrowingStatus(id: 'a', status: 'approved'),
      ),
      throwsA(isA<AppFailure>()),
    );
    expect(requests, isEmpty);
  });
  test('ambiguous server failures keep the persisted request ID across repository recreation', () async {
    handler = (_) async => http.Response('{"message":"gateway failure"}', 503);
    await expectLater(
      submit(repository()),
      throwsA(isA<AppFailure>().having((e) => e.uncertain, 'uncertain', true)),
    );
    final originalId = jsonDecode(requests.first.body)['p_request_id'];
    expect(preferences.getKeys(), isNotEmpty);
    handler = (_) async =>
        http.Response('{"id":"loan-1","status":"pending"}', 200);
    await submit(repository());
    expect(jsonDecode(requests.last.body)['p_request_id'], originalId);
    expect(preferences.getKeys(), isEmpty);
  });
  test('commands submit to RPC and do not accept client-supplied names or user identities', () async {
    handler = (_) async =>
        http.Response('{"id":"loan-1","status":"pending"}', 200);
    await submit(repository());
    expect(requests.single.url.path, '/rest/v1/rpc/request_borrowing');
    final payload = jsonDecode(requests.single.body) as Map;
    expect(payload.containsKey('user_id'), false);
    expect(payload.containsKey('nama_peminjam'), false);
    expect(payload['p_borrow_date'], '2026-10-18');
    expect(
      payload['p_request_id'],
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });
  test(
    'rapid identical submissions share the same in-flight network request',
    () async {
      final response = Completer<http.Response>();
      handler = (_) => response.future;
      final repo = repository();
      final a = submit(repo), b = submit(repo);
      await Future<void>.delayed(Duration.zero);
      response.complete(
        http.Response('{"id":"loan-1","status":"pending"}', 200),
      );
      await Future.wait([a, b]);
      expect(requests.length, 1);
    },
  );
}
