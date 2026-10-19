import 'package:flutter_test/flutter_test.dart';
import 'package:lab_inventory/auth/session_controller.dart';
import 'package:lab_inventory/demo/demo_backend.dart';

void main() {
  test(
    'local demo supports student/admin transactions without a Supabase client',
    () async {
      final gateway = DemoAuthGateway();
      final session = SessionController(gateway);
      final repository = DemoInventoryRepository(session);
      await session.start();
      await session.signIn('', '');
      final item = (await repository.getItems()).first;
      final today = DateTime.now().toUtc().add(const Duration(hours: 7));
      await repository.createBorrowing(
        itemId: item.id,
        jumlah: 1,
        tglPinjam: today,
        tglKembali: today,
        keperluan: 'Latihan',
      );
      final loan = (await repository.getBorrowings()).single;
      expect((await repository.getItems()).first.stock, item.stock);
      await session.signOut();
      gateway.admin = true;
      await session.signIn('', '');
      await repository.updateBorrowingStatus(id: loan.id, status: 'approved');
      expect((await repository.getItems()).first.stock, item.stock - 1);
      await repository.updateBorrowingStatus(
        id: loan.id,
        status: 'returned',
        returnedGood: false,
      );
      expect((await repository.getItems()).first.stock, item.stock - 1);
      expect((await repository.getBorrowings()).single.status, 'returned');
      session.dispose();
    },
  );
}
