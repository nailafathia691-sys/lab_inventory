import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lab_inventory/auth/session_controller.dart';
import 'package:lab_inventory/core/models.dart';
import 'package:lab_inventory/core/failures.dart';

import 'support/fakes.dart';

void main() {
  late FakeAuthGateway gateway;
  late SessionController controller;
  setUp(() {
    gateway = FakeAuthGateway();
    controller = SessionController(gateway);
  });
  tearDown(() async {
    controller.dispose();
    await gateway.events.close();
  });

  test('startup without a server session stays signed out', () async {
    await controller.start();
    expect(controller.status, SessionStatus.signedOut);
    expect(controller.requireProfile, throwsA(isA<AppFailure>()));
  });
  test('role follows the server profile rather than the email', () async {
    gateway.current = studentProfile;
    await controller.start();
    expect(controller.requireProfile().isAdmin, false);
  });
  test('a login failure cannot open an authenticated session', () async {
    await controller.start();
    gateway.signInError = const AppFailure('Autentikasi gagal');
    await expectLater(
      controller.signIn('admin@example.test', 'incorrect'),
      throwsA(isA<AppFailure>()),
    );
    expect(controller.status, SessionStatus.signedOut);
    expect(controller.profile, isNull);
  });
  test('missing or invalid server profile fails closed', () async {
    gateway.loader = () async => throw const FormatException('No profile');
    await controller.start();
    expect(controller.status, SessionStatus.failed);
    expect(controller.profile, isNull);
  });
  test(
    'logout calls the backend and clears the authenticated identity',
    () async {
      gateway.current = adminProfile;
      await controller.start();
      await controller.signOut();
      expect(gateway.signOutCalls, 1);
      expect(controller.status, SessionStatus.signedOut);
      expect(controller.profile, isNull);
    },
  );
  test(
    'a delayed profile load cannot restore a session after logout',
    () async {
      gateway.current = studentProfile;
      await controller.start();
      final delayed = Completer<AppProfile?>();
      gateway.loader = () => delayed.future;
      final refresh = controller.refresh();
      await controller.signOut();
      // Allow the sign-out event to trigger another pending profile read too.
      gateway.loader = () async => null;
      await Future<void>.delayed(Duration.zero);
      delayed.complete(studentProfile);
      await refresh;
      expect(controller.status, SessionStatus.signedOut);
      expect(controller.profile, isNull);
    },
  );
  test('unknown and inactive roles cannot become app identities', () {
    final row = {
      'id': 'a',
      'nama': 'A',
      'npm': '',
      'role': 'superadmin',
      'is_active': true,
    };
    expect(
      () => AppProfile.fromJson(row, 'a@example.test'),
      throwsFormatException,
    );
    row['role'] = 'admin';
    row['is_active'] = false;
    expect(
      () => AppProfile.fromJson(row, 'a@example.test'),
      throwsFormatException,
    );
  });
  test(
    'slow revocation of an old session does not clear a newer login',
    () async {
      gateway.current = studentProfile;
      await controller.start();
      gateway.signOutGate = Completer<void>();
      final logout = controller.signOut();
      await Future<void>.delayed(Duration.zero);
      gateway.current = adminProfile;
      await controller.refresh();
      gateway.signOutGate!.complete();
      await logout;
      expect(controller.requireProfile().id, adminProfile.id);
    },
  );
}
