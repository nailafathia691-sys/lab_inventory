import 'dart:async';

import 'package:lab_inventory/auth/session_controller.dart';
import 'package:lab_inventory/core/models.dart';
import 'package:lab_inventory/data/inventory_repository.dart';

const studentProfile = AppProfile(
  id: 'student-a',
  email: 'admin@example.test',
  name: 'Mahasiswa A',
  identityNumber: '1001',
  role: AppRole.student,
);
const adminProfile = AppProfile(
  id: 'admin-a',
  email: 'laboran@example.test',
  name: 'Laboran A',
  identityNumber: '2001',
  role: AppRole.admin,
);
const availableItem = InventoryItem(
  id: 'item-a',
  name: 'Laptop',
  code: 'INV-001',
  category: 'Komputer',
  condition: 'Baik',
  stock: 2,
  location: 'Rak A',
);

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({this.current});
  AppProfile? current;
  Object? signInError;
  Future<AppProfile?> Function()? loader;
  int signOutCalls = 0;
  Completer<void>? signOutGate;
  final events = StreamController<SessionEvent>.broadcast();
  @override
  Stream<SessionEvent> get changes => events.stream;
  @override
  Future<AppProfile?> loadProfile() => loader?.call() ?? Future.value(current);
  @override
  Future<void> signIn(String email, String password) async {
    if (signInError != null) throw signInError!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    current = null;
    events.add(SessionEvent.signedOut);
    await signOutGate?.future;
  }
}

class FakeInventoryRepository implements InventoryRepository {
  final List<Borrowing> borrowings = [];
  Object? readError;
  Object? writeError;
  int writeCalls = 0;
  final List<String> statusUpdates = [];
  @override
  Future<List<InventoryItem>> getItems() async {
    if (readError != null) throw readError!;
    return [availableItem];
  }

  @override
  Future<List<Borrowing>> getBorrowings({
    String? status,
    String? userId,
    bool includeRelations = false,
  }) async {
    if (readError != null) throw readError!;
    return borrowings;
  }

  Future<void> write() async {
    writeCalls++;
    if (writeError != null) throw writeError!;
  }

  @override
  Future<void> addItem({
    required String name,
    required String category,
    required String condition,
    required int stock,
    required String location,
    required String description,
  }) => write();
  @override
  Future<void> createBorrowing({
    required String itemId,
    required int jumlah,
    required DateTime tglPinjam,
    required DateTime tglKembali,
    required String keperluan,
  }) => write();
  @override
  Future<void> updateBorrowingStatus({
    required String id,
    required String status,
    String? notes,
    bool? returnedGood,
  }) async {
    statusUpdates.add('$id:$status');
    await write();
  }
}
