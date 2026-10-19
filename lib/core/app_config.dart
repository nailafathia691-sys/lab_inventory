import 'dart:convert';

class ProductionConfig {
  const ProductionConfig({required this.url, required this.publishableKey});
  final String url;
  final String publishableKey;

  void validate() {
    final uri = Uri.tryParse(url);
    final validUrl =
        uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'https' ||
            (uri.scheme == 'http' &&
                ['localhost', '127.0.0.1', '10.0.2.2'].contains(uri.host)));
    if (!validUrl || publishableKey.isEmpty) {
      throw const FormatException('Konfigurasi server belum lengkap.');
    }
    if (publishableKey.startsWith('sb_publishable_')) return;
    // A legacy anon JWT is also a public client key. Reject service-role keys
    // even if an operator accidentally puts one into the client configuration.
    try {
      final parts = publishableKey.split('.');
      if (parts.length == 3) {
        final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );
        if (payload is Map && payload['role'] == 'anon') return;
      }
    } catch (_) {
      /* invalid client key */
    }
    throw const FormatException(
      'Gunakan publishable key atau anon key untuk aplikasi.',
    );
  }
}
