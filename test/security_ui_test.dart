import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_inventory/auth/session_controller.dart';
import 'package:lab_inventory/core/failures.dart';
import 'package:lab_inventory/core/models.dart';
import 'package:lab_inventory/core/runtime.dart';
import 'package:lab_inventory/main.dart';

import 'support/fakes.dart';

void main() {
  late FakeAuthGateway gateway;
  late FakeInventoryRepository repository;
  setUp(() async {
    isDemo = false;
    gateway = FakeAuthGateway();
    sessionController = SessionController(gateway);
    repository = FakeInventoryRepository();
    inventoryRepository = repository;
    await sessionController.start();
  });
  tearDown(() async {
    sessionController.dispose();
    await gateway.events.close();
  });
  for (final demo in [false, true]) {
    testWidgets('submit stays above Android navigation in demo=$demo', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(412, 915);
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
      tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
      addTearDown(tester.view.reset);
      gateway.current = studentProfile;
      await sessionController.refresh();
      isDemo = demo;
      await tester.pumpWidget(const LabInventoryApp());
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const BorrowingFormScreen(item: availableItem),
            ),
          );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      final submit = find.byType(FilledButton).last;
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      expect(tester.getBottomRight(submit).dy, lessThanOrEqualTo(875));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('transaction history opens details for the selected row', (
    tester,
  ) async {
    repository.borrowings.add(
      Borrowing(
        id: 'loan-detail',
        userId: studentProfile.id,
        itemId: availableItem.id,
        namaPeminjam: studentProfile.name,
        namaBarang: 'Laptop detail',
        jumlah: 2,
        tglPinjam: DateTime(2026, 10, 20),
        tglKembali: DateTime(2026, 10, 21),
        keperluan: 'Praktikum',
        status: 'returned',
        catatanKondisi: 'Layar rusak',
        createdAt: DateTime.utc(2026, 10, 19, 8, 30),
        approvedAt: DateTime.utc(2026, 10, 19, 9),
        returnedAt: DateTime.utc(2026, 10, 21, 10, 15),
        returnedGood: false,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(home: TransactionHistoryScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laptop detail - 2 unit'));
    await tester.pumpAndSettle();

    expect(find.text('ID transaksi'), findsOneWidget);
    expect(find.text('loan-detail'), findsOneWidget);
    expect(find.text('Dikembalikan'), findsNWidgets(2));
    expect(find.text('Layar rusak'), findsOneWidget);
    expect(find.text('Rusak'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final decision in {'Setujui': 'approved', 'Tolak': 'rejected'}.entries) {
    testWidgets(
      'approval detail shows related records and can ${decision.key.toLowerCase()} the request',
      (tester) async {
        repository.borrowings.add(
          Borrowing(
            id: 'pending-detail',
            userId: studentProfile.id,
            itemId: availableItem.id,
            namaPeminjam: 'Snapshot yang tidak dipakai',
            namaBarang: 'Snapshot barang yang tidak dipakai',
            jumlah: 3,
            tglPinjam: DateTime(2026, 10, 24),
            tglKembali: DateTime(2026, 10, 25),
            keperluan: 'Praktikum instrumentasi',
            status: 'pending',
            createdAt: DateTime.utc(2026, 10, 23, 8, 30),
            relatedStudentName: 'Nama dari profil terkait',
            studentIdentityNumber: 'NPM-2026',
            relatedItemName: 'Mikroskop dari inventaris',
            relatedItemCode: 'LAB-022',
            relatedItemCategory: 'Elektronik',
          ),
        );

        await tester.pumpWidget(const MaterialApp(home: ApprovalScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Nama dari profil terkait'), findsOneWidget);
        expect(
          find.textContaining('Mikroskop dari inventaris'),
          findsOneWidget,
        );
        await tester.tap(find.text('Nama dari profil terkait'));
        await tester.pumpAndSettle();

        expect(find.text('NPM-2026'), findsOneWidget);
        expect(find.text('LAB-022'), findsOneWidget);
        expect(find.text('Praktikum instrumentasi'), findsOneWidget);
        expect(find.text('Snapshot yang tidak dipakai'), findsNothing);
        expect(find.text('Snapshot barang yang tidak dipakai'), findsNothing);

        final decisionButton = find.text(decision.key);
        await tester.ensureVisible(decisionButton);
        await tester.tap(decisionButton);
        await tester.pumpAndSettle();

        expect(repository.statusUpdates, ['pending-detail:${decision.value}']);
        expect(repository.writeCalls, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('production login has no demo bypass or role selector', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AuthGate()));
    expect(find.byType(RadioListTile<String>), findsNothing);
    expect(find.textContaining('Tanpa Akun'), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'admin@example.test');
    await tester.enterText(find.byType(TextField).last, 'incorrect');
    gateway.signInError = const AppFailure('Autentikasi gagal');
    await tester.ensureVisible(find.text('MASUK'));
    await tester.tap(find.text('MASUK'));
    await tester.pumpAndSettle();
    expect(find.text('Autentikasi gagal'), findsOneWidget);
    expect(find.byType(AdminMainScreen), findsNothing);
  });
  testWidgets(
    'signing out disposes the entire protected detail navigation stack',
    (tester) async {
      gateway.current = studentProfile;
      await sessionController.refresh();
      await tester.pumpWidget(const MaterialApp(home: AuthGate()));
      await tester.pumpAndSettle();
      final shell = tester.state<NavigatorState>(
        find
            .descendant(
              of: find.byType(ProtectedShell),
              matching: find.byType(Navigator),
            )
            .first,
      );
      shell.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Protected detail')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Protected detail'), findsOneWidget);
      await sessionController.signOut();
      await tester.pumpAndSettle();
      expect(find.text('Protected detail'), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );
  testWidgets('a load failure is shown explicitly and can be retried', (
    tester,
  ) async {
    repository.readError = const AppFailure('Koneksi gagal');
    await tester.pumpWidget(
      const MaterialApp(home: InventoryListScreen(isAdmin: false)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Koneksi gagal'), findsOneWidget);
    expect(find.text('Barang tidak ditemukan.'), findsNothing);
    repository.readError = null;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Koneksi gagal'), findsNothing);
    expect(find.text('Laptop'), findsOneWidget);
  });
  testWidgets('opening borrowing history fetches loans created after login', (
    tester,
  ) async {
    gateway.current = studentProfile;
    await sessionController.refresh();
    await tester.pumpWidget(const MaterialApp(home: MahasiswaMainScreen()));
    await tester.pumpAndSettle();
    repository.borrowings.add(
      Borrowing(
        id: 'new-loan',
        userId: studentProfile.id,
        itemId: availableItem.id,
        namaPeminjam: studentProfile.name,
        namaBarang: 'Laptop baru dipinjam',
        jumlah: 1,
        tglPinjam: DateTime.now(),
        tglKembali: DateTime.now(),
        keperluan: 'Praktikum',
        status: 'pending',
      ),
    );
    await tester.tap(find.text('Peminjaman'));
    await tester.pumpAndSettle();
    expect(find.text('Laptop baru dipinjam (1 Unit)'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('Belum Ada Riwayat Peminjaman'), findsNothing);
  });
  testWidgets('failed inventory creation keeps the form and its input', (
    tester,
  ) async {
    repository.writeError = const AppFailure('Simpan gagal');
    await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));
    await tester.enterText(find.byType(TextField).at(0), 'Laptop baru');
    await tester.enterText(find.byType(TextField).at(1), '2');
    final button = find.byType(FilledButton).last;
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Simpan gagal'), findsOneWidget);
    expect(find.byType(AddItemScreen), findsOneWidget);
    expect(find.text('Laptop baru'), findsOneWidget);
    expect(find.textContaining('lokal/RLS'), findsNothing);
  });
  testWidgets('return information wraps long purposes on a narrow screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 346,
              child: InfoLine(
                label: 'Keperluan',
                value:
                    'Uji Playwright: peminjaman dan pengembalian kondisi baik',
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'failed borrowing never reports success and keeps the submission form',
    (tester) async {
      repository.writeError = const AppFailure('Pengajuan gagal');
      await tester.pumpWidget(
        const MaterialApp(home: BorrowingFormScreen(item: availableItem)),
      );
      for (var i = 0; i < 2; i++) {
        final date = find.text('DD/MM/YYYY').first;
        await tester.ensureVisible(date);
        await tester.tap(date);
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Praktikum jaringan');
      final button = find.text('KIRIM / COBA LAGI');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(repository.writeCalls, 1);
      expect(find.text('Pengajuan gagal'), findsOneWidget);
      expect(find.byType(BorrowingFormScreen), findsOneWidget);
      expect(find.text('Praktikum jaringan'), findsOneWidget);
      expect(find.textContaining('Pengajuan berhasil'), findsNothing);
    },
  );
}
