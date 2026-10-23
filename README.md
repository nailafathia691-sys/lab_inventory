# LabInventory

Aplikasi Android Flutter untuk inventaris dan peminjaman barang Laboratorium Komputer .

Backend yang dipakai adalah **Supabase Auth dan PostgreSQL**. Acuan terbaru ada di [SRD v2](docs/SRD_V2.md); dokumen Word SRD v1 di root disimpan sebagai riwayat rancangan awal PHP/MySQL.

Status database aktif 19 Oktober 2026: migration penuh sudah diterapkan setelah pengguna memastikan total proyektor 2 unit dan reservasi approved 1 unit. Saldo tersedia proyektor menjadi 1. Transaksi admin/mahasiswa aktif dan banner mode baca tidak lagi tampil setelah sesi dimuat ulang. Lihat [aktivasi dan hasil verifikasi](docs/AKTIVASI_TRANSAKSI_2026-10-19.md).

## Menjalankan demo lokal

Demo menggunakan data dalam memori, tanpa akun Supabase dan tanpa koneksi database operasional. Label aplikasi dan application ID Android berbeda dari aplikasi operasional.

```powershell
flutter pub get
flutter run --flavor demo -t lib/main_demo.dart
```

Pilih peran latihan pada layar demo. Data bertahan selama proses aplikasi berjalan; keluar/masuk sebagai peran lain dalam proses yang sama dapat digunakan untuk mencoba persetujuan dan pengembalian.

Untuk menjalankan demo di Chrome:

```powershell
flutter run -d chrome --web-hostname 127.0.0.1 --web-port 8766 -t lib/main_demo.dart
```

Lihat [hasil pengujian Playwright dan database](docs/PENGUJIAN_PLAYWRIGHT_2026-10-19.md), termasuk skrip pengujian ulang dan bukti layar.

Katalog, detail, dan formulir peminjaman memakai foto ilustrasi lokal untuk proyektor, laptop, kabel HDMI, serta speaker. Sumber dan lisensi tercatat pada [daftar aset](assets/images/inventory/README.md) dan tombol Kredit foto pada aplikasi. Gambar tersebut belum merupakan foto unit fisik laboratorium.

## Menjalankan aplikasi operasional

Varian bawaan adalah `production`, sesuai entry point `lib/main.dart`. Perintah `flutter run` atau `flutter build apk` tanpa `--flavor` kini memilih varian ini. Koneksi server tetap memerlukan konfigurasi lokal di bawah. Untuk demo, gunakan perintah demo di atas atau pilih **LabInventory Demo** pada Run and Debug VS Code lalu tekan F5. Profil **LabInventory Production (konfigurasi lokal)** membutuhkan `config/supabase.local.json` yang sudah diisi.

Pengaturan ini memakai [`default-flavor` resmi Flutter](https://docs.flutter.dev/tools/pubspec#default-flavor-field) untuk menghindari error `Gradle build failed to produce an .apk file` ketika Flutter mencari APK tanpa varian pada proyek yang menghasilkan APK demo/production.

1. Gunakan Flutter dengan Dart yang memenuhi `pubspec.yaml`. Perubahan ini diverifikasi menggunakan Flutter 3.47.2 / Dart 3.13.2.
2. Siapkan Supabase dan terapkan migration sesuai [panduan tahap 1–2](docs/TAHAP_1_DAN_2.md). Aplikasi baru membutuhkan skema, policy, dan RPC dari migration; tidak ada fallback ke operasi database lama.
3. Salin `config/supabase.example.json` menjadi `config/supabase.local.json`, lalu isi URL proyek dan **publishable key**. Legacy anon key juga didukung. File lokal diabaikan Git. Jangan memasukkan secret/service-role key ke aplikasi.
4. Buat akun melalui Supabase Auth. Akun baru berperan mahasiswa; penetapan laboran dilakukan pengelola di server, bukan lewat form login.

```powershell
flutter pub get
flutter run --flavor production -t lib/main.dart --dart-define-from-file=config/supabase.local.json
```

Di PowerShell, `./tools/run.ps1` otomatis menyertakan file konfigurasi lokal tersebut. Gunakan `./tools/run.ps1 -Device chrome` atau `-Device SERIAL_ADB` untuk memilih perangkat; tambahkan `-Demo` untuk demo tanpa database. Di VS Code, pilih **LabInventory Production (konfigurasi lokal)** lalu F5 untuk koneksi Supabase.

`flutter run` biasa sekarang membaca `config/supabase.local.json` yang dibundel sebagai aset aplikasi. URL dan public key yang diberikan lewat `--dart-define-from-file` tetap diutamakan sebagai satu pasangan; override yang hanya mengisi salah satunya ditolak agar konfigurasi dua proyek tidak tercampur. Folder `config/` khusus konfigurasi client yang boleh masuk APK, tanpa password pengguna atau secret/service-role key. File lokal tetap diabaikan Git.

Lihat [hasil debug layar konfigurasi dan bukti login production](docs/DEBUG_KONFIGURASI_2026-10-19.md).

Tidak tersedia password demo atau tombol masuk tanpa autentikasi pada build operasional. Role diambil dari profil server. Kegagalan simpan ditampilkan sebagai kegagalan; formulir tetap terbuka agar dapat dicoba ulang.

## Aturan transaksi

| Peristiwa | Perubahan stok |
| --- | --- |
| Pengajuan `pending` | Tidak berubah |
| Persetujuan `pending → approved` | Stok dicadangkan/dikurangi secara atomik |
| Penolakan `pending → rejected` | Tidak berubah |
| Pengembalian baik `approved → returned` | Stok siap pakai bertambah |
| Pengembalian rusak `approved → returned` | Stok rusak bertambah; stok siap pakai tidak bertambah |

Permintaan berulang dengan ID yang sama mengembalikan hasil sebelumnya. Persetujuan/pengembalian yang sudah selesai tidak mengubah stok dua kali jika dikirim dengan ID baru. Perubahan stok mencatat ledger dan audit dalam transaksi yang sama.

Pembacaan data memakai query/refetch dan tombol muat ulang; subscription Supabase Realtime belum diimplementasikan. Edit/arsip inventaris, pagination, pemulihan akun lewat UI, notifikasi, dan kesiapan distribusi release merupakan tahap berikutnya.

## Pengujian

Alur mahasiswa dan laboran sudah diuji pada Redmi 12 melalui Playwright Android. Lihat [laporan perangkat fisik dan bukti layar](docs/PENGUJIAN_DEVICE_2026-10-19.md) serta [panduan kendali native](tools/device-tests/README.md). Pengujian perangkat memakai demo lokal dalam memori.

```powershell
flutter analyze --no-pub
flutter test --no-pub
npm.cmd --prefix tools/database-tests ci --ignore-scripts --no-audit --no-fund
npm.cmd --prefix tools/database-tests test
```

Test SQL memakai PostgreSQL berbasis WASM (PGlite) tanpa menghubungi Supabase. Test memeriksa SQL, grants, RLS, validasi, rollback, ledger, dan idempotensi. Uji dua koneksi bersamaan serta integrasi Supabase Auth/Data API harus dilengkapi di staging sebelum produksi; lihat panduan tahap 1–2.

## Struktur

```text
lib/auth/                 autentikasi dan siklus sesi
lib/core/                 konfigurasi, model, validasi, error
lib/data/                 repository RPC dan ID permintaan persisten
lib/demo/                 backend demo dalam memori
lib/main.dart             bootstrap operasional dan UI
lib/main_demo.dart        entry point demo
supabase/migrations/      skema, RLS, RPC transaksi, ledger, audit
supabase/preflight.sql    pemeriksaan awal database yang sudah ada
test/                     test unit, repository, dan antarmuka
tools/database-tests/     test SQL lokal
docs/                     analisis, kebutuhan, dan prosedur penerapan
```

Pengembang awal: Naila Fathia, NPM 2413025076, Pendidikan Teknologi Informasi, Universitas Lampung. Proyek dikembangkan untuk mata kuliah Pemrograman Mobile.
