import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_config.dart';

/// Explicit build settings take precedence as a pair. Otherwise load the
/// public client settings bundled from the gitignored local configuration.
/// Never fill a partial override from another project's bundled settings.
Future<ProductionConfig> loadProductionConfig({
  String url = const String.fromEnvironment('SUPABASE_URL'),
  String publishableKey = const String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  ),
  AssetBundle? bundle,
}) async {
  final ProductionConfig config;
  if (url.isNotEmpty || publishableKey.isNotEmpty) {
    config = ProductionConfig(
      url: url.trim(),
      publishableKey: publishableKey.trim(),
    );
  } else {
    try {
      final data = jsonDecode(
        await (bundle ?? rootBundle).loadString('config/supabase.local.json'),
      );
      if (data is! Map<String, dynamic> ||
          data['SUPABASE_URL'] is! String ||
          data['SUPABASE_PUBLISHABLE_KEY'] is! String) {
        throw const FormatException('Konfigurasi server tidak valid.');
      }
      config = ProductionConfig(
        url: (data['SUPABASE_URL'] as String).trim(),
        publishableKey: (data['SUPABASE_PUBLISHABLE_KEY'] as String).trim(),
      );
    } on FlutterError {
      throw const FormatException('Konfigurasi server belum lengkap.');
    } on FormatException {
      // Do not surface JSON source or client settings in an exception message.
      throw const FormatException('Konfigurasi server tidak valid.');
    }
  }
  config.validate();
  return config;
}
