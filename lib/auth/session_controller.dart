import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/failures.dart';
import '../core/models.dart';

enum SessionEvent { changed, signedOut }

abstract class AuthGateway {
  Stream<SessionEvent> get changes;
  Future<void> signIn(String email, String password);
  Future<AppProfile?> loadProfile();
  Future<void> signOut();
}

class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this.client);
  final SupabaseClient client;
  @override
  Stream<SessionEvent> get changes => client.auth.onAuthStateChange.map(
    (state) => state.event == AuthChangeEvent.signedOut
        ? SessionEvent.signedOut
        : SessionEvent.changed,
  );
  @override
  Future<void> signIn(String email, String password) async {
    final result = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (result.user == null || result.session == null) {
      throw const AppFailure(
        'Autentikasi belum berhasil. Silakan masuk kembali.',
      );
    }
  }

  @override
  Future<AppProfile?> loadProfile() async {
    final user = client.auth.currentUser;
    if (user == null || client.auth.currentSession == null) return null;
    if (user.isAnonymous) {
      throw const AppFailure(
        'Gunakan akun email yang terdaftar untuk mengakses aplikasi operasional.',
      );
    }
    final row = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single()
        .timeout(const Duration(seconds: 15));
    return AppProfile.fromJson(row, user.email ?? '');
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      // The SDK clears the local session before requesting remote revocation.
      // An offline revocation failure must not reopen that local identity.
      if (client.auth.currentSession != null) rethrow;
    }
  }
}

enum SessionStatus { loading, signedOut, signedIn, failed }

class SessionController extends ChangeNotifier {
  SessionController(this.gateway);
  final AuthGateway gateway;
  StreamSubscription<SessionEvent>? _subscription;
  int _generation = 0;
  bool _disposed = false;
  SessionStatus status = SessionStatus.loading;
  AppProfile? profile;
  String? error;

  Future<void> start() async {
    _subscription = gateway.changes.listen(
      (event) {
        if (_disposed) return;
        if (event == SessionEvent.signedOut) {
          _generation++;
          profile = null;
          error = null;
          status = SessionStatus.signedOut;
          notifyListeners();
        } else {
          unawaited(refresh());
        }
      },
      onError: (Object failure) {
        if (_disposed) return;
        _generation++;
        profile = null;
        error = appFailure(failure).message;
        status = SessionStatus.failed;
        notifyListeners();
      },
    );
    await refresh();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    profile = null;
    error = null;
    status = SessionStatus.loading;
    notifyListeners();
    try {
      final result = await gateway.loadProfile();
      if (_disposed || generation != _generation) return;
      profile = result;
      status = result == null
          ? SessionStatus.signedOut
          : SessionStatus.signedIn;
    } catch (failure) {
      if (_disposed || generation != _generation) return;
      error = appFailure(failure).message;
      status = SessionStatus.failed;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await gateway.signIn(email, password);
    await refresh();
  }

  Future<void> signOut() async {
    final generation = ++_generation;
    profile = null;
    error = null;
    status = SessionStatus.loading;
    notifyListeners();
    try {
      await gateway.signOut();
      if (_disposed || generation != _generation) return;
      status = SessionStatus.signedOut;
      notifyListeners();
    } catch (failure) {
      if (!_disposed && generation == _generation) {
        error = appFailure(failure).message;
        status = SessionStatus.failed;
        notifyListeners();
      }
      rethrow;
    }
  }

  AppProfile requireProfile() {
    final current = profile;
    if (status != SessionStatus.signedIn || current == null) {
      throw const AppFailure('Sesi berakhir. Silakan masuk kembali.');
    }
    return current;
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
