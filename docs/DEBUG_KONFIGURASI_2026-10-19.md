# Debug layar konfigurasi server — 19 Oktober 2026

**Status terbaru: bug pembacaan konfigurasi sudah diperbaiki pada kode aplikasi dan diverifikasi pada Pixel 7a melalui `flutter run` tanpa dart-define.**

Screenshot sumber: [screenshot pengguna](../../ss/Screenshot%202026-10-19%20030125.png). Pesan yang tampil sebelumnya: **Konfigurasi server belum lengkap. Hubungi pengelola aplikasi.**

## Penyebab dan koreksi perbaikan awal

`main.dart` sebelumnya hanya membaca `String.fromEnvironment`. Menyimpan `config/supabase.local.json` tidak memasukkan nilainya ke build yang dijalankan dengan `flutter run` biasa. Perbaikan awal melalui launcher/flag hanya menyelesaikan jalur peluncuran tersebut. APK yang dibangun tanpa flag tetap menampilkan pesan yang sama.

Pada pengecekan lanjutan, file lokal sudah ada dan berisi URL/public key, tetapi aplikasi yang terpasang di Pixel 7a masih menampilkan error konfigurasi. Kondisi ini direproduksi langsung sebelum pemasangan ulang.

## Perbaikan pada kode

- `lib/core/config_loader.dart` membaca konfigurasi lokal yang dibundel sebagai aset ketika URL dan key tidak diberikan lewat dart-define.
- `lib/main.dart` menunggu loader selesai dan memakai konfigurasi yang sudah divalidasi untuk inisialisasi Supabase.
- `pubspec.yaml` membundel folder `config/`. Folder ini hanya untuk konfigurasi client publik. File lokal tetap diabaikan Git; password/secret/service-role key tidak boleh disimpan dalam folder ini.
- Dart-define lengkap tetap dapat mengganti konfigurasi aset, misalnya untuk staging. Override parsial ditolak agar URL satu proyek tidak digabung dengan key proyek lain.
- Validasi public key tetap berjalan pada kedua sumber. JSON tidak valid, file hilang, serta secret/service-role key ditolak tanpa mencetak isi konfigurasi.
- Profil production VS Code menggunakan entry point yang sama dan tidak memerlukan flag konfigurasi khusus.
- Demo tetap menggunakan entry point terpisah dan tidak membaca konfigurasi Supabase.

## Verifikasi perangkat fisik

Perangkat: **Pixel 7a**, Android **17**, serial `33211JEHN10338`. Package: `com.example.lab_inventory`.

Perintah yang benar-benar diuji:

```powershell
flutter run -d 33211JEHN10338
```

Tidak diberikan `--dart-define` atau `--dart-define-from-file`.

Hasil:

1. Sebelum perbaikan dipasang, hierarchy Android memuat pesan konfigurasi server belum lengkap.
2. Build `assembleProductionDebug` berhasil dalam 34,5 detik dan APK terpasang di ponsel.
3. Log aplikasi mencatat **Supabase init completed**.
4. Isi APK diperiksa: `assets/flutter_assets/config/supabase.local.json` tersedia dan cocok dengan konfigurasi lokal, tanpa menampilkan nilainya pada output pemeriksaan.
5. Sesi akun tersimpan sempat menampilkan penolakan akses profil dari server. Setelah memakai tombol **Keluar dari sesi**, layar **MASUK** tampil.
6. Hierarchy Android mengonfirmasi tombol MASUK pada package production dan tidak lagi memuat pesan konfigurasi sebelumnya.
7. Setelah debugger dilepas, aplikasi dihentikan lalu dibuka kembali langsung melalui activity Android. Cold start juga menampilkan MASUK tanpa pesan konfigurasi. Ini memverifikasi bahwa konfigurasi tetap tersedia pada APK ketika tidak terhubung ke Flutter.

Bukti:

- [Layar login production pada Pixel 7a](evidence/configuration/production-login-pixel7a.png).
- [Hasil pemeriksaan native dan hash APK](evidence/configuration/native-startup-result.json).
- [Penolakan akses profil pada sesi tersimpan](evidence/configuration/production-profile-access-pixel7a.png).

Aplikasi dibiarkan pada layar login. Data aplikasi tidak dihapus; tidak dilakukan perubahan stok, role, atau migration database.

## Test otomatis

- `flutter analyze --no-pub`: **tidak ada temuan**.
- `flutter test --no-pub`: **37 test lulus**.
- Lima test baru mencakup peluncuran tanpa dart-define, prioritas override lengkap, penolakan override parsial, file hilang/JSON rusak, dan penolakan secret/service-role key dari aset.
- `git diff --check`: lulus.
- `git check-ignore config/supabase.local.json`: file lokal tetap diabaikan Git.

## Menjalankan ulang

Konfigurasi lokal sudah tersedia pada workspace ini. Gunakan:

```powershell
flutter run
# Memilih Pixel 7a secara langsung:
flutter run -d 33211JEHN10338
```

Di VS Code, pilih **LabInventory Production (konfigurasi lokal)** lalu F5. Untuk workspace baru, salin contoh konfigurasi terlebih dahulu dan isi URL/public key. Setelah mengganti konfigurasi/aset, hentikan sesi Flutter dan jalankan ulang agar APK yang terpasang ikut diperbarui. Hot reload pada APK lama belum cukup untuk mengganti konfigurasi build/aset.

Launcher `tools/run.ps1` dan `--dart-define-from-file` tetap dapat dipakai, tetapi perbaikan ini sudah diuji tanpa keduanya.

## Batas hasil dan temuan backend

Status terbaru backend: profil/role sudah pulih dan [transaksi penuh sudah diaktifkan](AKTIVASI_TRANSAKSI_2026-10-19.md) setelah rekonsiliasi stok. Catatan penolakan dan mode baca berikut merupakan riwayat pemeriksaan sebelumnya.

Pembaruan lanjutan: profil/role server dan akses baca sudah dipulihkan melalui tahap sementara. Dashboard laboran dengan empat barang telah diverifikasi pada ponsel; lihat [pemulihan login role](PEMULIHAN_LOGIN_ROLE_2026-10-19.md). Catatan penolakan sesi di bawah adalah kondisi sebelum pemulihan tersebut.

Bug konfigurasi startup sudah teratasi pada perangkat fisik. **Login akun asli dan transaksi produksi belum dinyatakan lulus.** Ada penolakan akses profil pada sesi akun tersimpan. Status migration penuh yang tercatat sebelumnya masih menunggu rekonsiliasi stok; lihat [audit database](DATABASE_AUDIT_2026-10-19.md). Penolakan profil tidak diatasi dengan bypass role, membuka RLS, atau memakai service-role key di aplikasi.

Verifikasi awal sebelum perbaikan loader juga pernah berhasil melalui browser dengan flag konfigurasi dan GET `/auth/v1/settings` HTTP 200. Bukti browser lama ada di [login production browser](evidence/configuration/production-login.png); bukti utama untuk bug berulang ini adalah hasil native tanpa flag di atas.
