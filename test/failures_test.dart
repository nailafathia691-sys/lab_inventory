import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lab_inventory/core/failures.dart';

void main() {
  test('missing schema and RPCs do not masquerade as connection failures', () {
    for (final code in ['PGRST205', '42P01', 'PGRST202']) {
      final failure = appFailure(
        PostgrestException(message: 'server detail', code: code),
      );
      expect(failure.message, contains('penyiapan server'));
      expect(failure.uncertain, false);
      expect(failure.message, isNot(contains('server detail')));
    }
  });
  test('missing profile produces an account-specific message', () {
    expect(
      appFailure(PostgrestException(message: 'No rows', code: 'PGRST116'))
          .message,
      contains('Profil akun belum tersedia'),
    );
  });
}
