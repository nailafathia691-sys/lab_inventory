import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_inventory/core/config_loader.dart';

class ConfigBundle extends CachingAssetBundle {
  ConfigBundle(this.contents);
  final String? contents;
  int reads = 0;

  @override
  Future<ByteData> load(String key) async {
    reads++;
    if (key != 'config/supabase.local.json' || contents == null) {
      throw FlutterError('Missing client settings');
    }
    final bytes = Uint8List.fromList(utf8.encode(contents!));
    return ByteData.sublistView(bytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const local = '''{
    "SUPABASE_URL": "https://local-project.supabase.co",
    "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_local"
  }''';

  test('plain launch loads the bundled local public configuration', () async {
    final bundle = ConfigBundle(local);
    final config = await loadProductionConfig(
      url: '',
      publishableKey: '',
      bundle: bundle,
    );
    expect(config.url, 'https://local-project.supabase.co');
    expect(config.publishableKey, 'sb_publishable_local');
    expect(bundle.reads, 1);
  });

  test('explicit settings override the bundle without reading it', () async {
    final bundle = ConfigBundle(null);
    final config = await loadProductionConfig(
      url: 'https://staging.supabase.co',
      publishableKey: 'sb_publishable_staging',
      bundle: bundle,
    );
    expect(config.url, 'https://staging.supabase.co');
    expect(config.publishableKey, 'sb_publishable_staging');
    expect(bundle.reads, 0);
  });

  test(
    'partial overrides cannot mix settings from different projects',
    () async {
      for (final urlOnly in [true, false]) {
        final bundle = ConfigBundle(local);
        await expectLater(
          loadProductionConfig(
            url: urlOnly ? 'https://staging.supabase.co' : '',
            publishableKey: urlOnly ? '' : 'sb_publishable_staging',
            bundle: bundle,
          ),
          throwsFormatException,
        );
        expect(bundle.reads, 0);
      }
    },
  );

  test(
    'missing and malformed assets fail without exposing their content',
    () async {
      for (final contents in [
        null,
        'invalid-private-content',
        '[]',
        '{"SUPABASE_URL":42}',
      ]) {
        await expectLater(
          loadProductionConfig(
            url: '',
            publishableKey: '',
            bundle: ConfigBundle(contents),
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'message',
              isNot(contains('invalid-private-content')),
            ),
          ),
        );
      }
    },
  );

  test('a bundled secret or service-role key is rejected', () async {
    final servicePayload = base64Url.encode(
      utf8.encode(jsonEncode({'role': 'service_role'})),
    );
    for (final key in [
      'sb_secret_forbidden',
      'header.$servicePayload.signature',
    ]) {
      final contents = jsonEncode({
        'SUPABASE_URL': 'https://local-project.supabase.co',
        'SUPABASE_PUBLISHABLE_KEY': key,
      });
      await expectLater(
        loadProductionConfig(
          url: '',
          publishableKey: '',
          bundle: ConfigBundle(contents),
        ),
        throwsFormatException,
      );
    }
  });
}
