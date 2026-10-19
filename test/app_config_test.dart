import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lab_inventory/core/app_config.dart';

void main() {
  const url = 'https://example.supabase.co';
  test('missing configuration and nonlocal HTTP endpoints are rejected', () {
    expect(
      () => const ProductionConfig(url: '', publishableKey: '').validate(),
      throwsFormatException,
    );
    expect(
      () => const ProductionConfig(
        url: 'http://example.com',
        publishableKey: 'sb_publishable_test',
      ).validate(),
      throwsFormatException,
    );
  });
  test('only public keys can initialize the mobile backend', () {
    const ProductionConfig(
      url: url,
      publishableKey: 'sb_publishable_test',
    ).validate();
    expect(
      () => const ProductionConfig(
        url: url,
        publishableKey: 'sb_secret_test',
      ).validate(),
      throwsFormatException,
    );
    for (final role in ['anon', 'service_role']) {
      final payload = base64Url.encode(utf8.encode(jsonEncode({'role': role})));
      final config = ProductionConfig(
        url: url,
        publishableKey: 'header.$payload.signature',
      );
      if (role == 'anon') {
        config.validate();
      } else {
        expect(config.validate, throwsFormatException);
      }
    }
  });
}
