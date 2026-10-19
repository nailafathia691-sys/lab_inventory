import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class AppFailure implements Exception {
  const AppFailure(this.message, {this.uncertain = false});
  final String message;
  final bool uncertain;
  @override
  String toString() => message;
}

AppFailure appFailure(Object error) {
  if (error is AppFailure) return error;
  if (error is TimeoutException) {
    return const AppFailure(
      'Konfirmasi server belum diterima. Coba lagi dengan data yang sama; permintaan tidak akan digandakan.',
      uncertain: true,
    );
  }
  if (error is AuthException) {
    return const AppFailure(
      'Tidak dapat masuk. Periksa email, password, dan koneksi Anda.',
    );
  }
  if (error is PostgrestException) {
    if (['PGRST202', 'PGRST205', '42P01'].contains(error.code)) {
      return const AppFailure(
        'Fitur database belum tersedia. Hubungi pengelola untuk menyelesaikan penyiapan server.',
      );
    }
    if (error.code == 'PGRST116') {
      return const AppFailure(
        'Profil akun belum tersedia atau tidak dapat diakses. Hubungi laboran.',
      );
    }
    final message = switch (error.message) {
      'AUTH_REQUIRED' => 'Sesi berakhir. Silakan masuk kembali.',
      'FORBIDDEN' => 'Akun Anda tidak memiliki izin untuk tindakan ini.',
      'PROFILE_REQUIRED' =>
        'Profil akun belum tersedia atau tidak aktif. Hubungi laboran.',
      'INSUFFICIENT_STOCK' =>
        'Stok terbaru tidak mencukupi. Muat ulang data barang.',
      'ITEM_UNAVAILABLE' =>
        'Barang tidak aktif atau kondisinya belum layak dipinjam.',
      'INVALID_DATES' => 'Periksa tanggal pinjam dan tanggal kembali.',
      'INVALID_INPUT' => 'Periksa kembali jumlah dan kelengkapan formulir.',
      'INVALID_TRANSITION' =>
        'Status transaksi sudah berubah. Muat ulang data terbaru.',
      'NOT_FOUND' => 'Data tidak ditemukan atau sudah tidak tersedia.',
      'REQUEST_CONFLICT' => 'Permintaan sebelumnya memakai data berbeda. Muat ulang status transaksi.',
      _ =>
        error.code == '42501'
            ? 'Akses ditolak. Hubungi laboran untuk memeriksa izin akun.'
            : 'Permintaan ditolak server. Muat ulang data atau hubungi laboran.',
    };
    // A gateway/server error can arrive after the transaction committed.
    final code = error.code ?? '';
    final uncertain =
        !(code == 'P0001' ||
            code == '42501' ||
            code.startsWith('22') ||
            code.startsWith('23') ||
            code == 'PGRST202');
    return AppFailure(message, uncertain: uncertain);
  }
  if (error is FormatException) {
    return const AppFailure(
      'Data akun atau server tidak sesuai. Hubungi laboran.',
    );
  }
  return const AppFailure(
    'Koneksi atau konfirmasi server terganggu. Coba lagi dengan data yang sama.',
    uncertain: true,
  );
}
