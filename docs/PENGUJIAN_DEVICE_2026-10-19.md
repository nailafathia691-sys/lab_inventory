# Pengujian Android fisik — 19 Oktober 2026

**Status akhir: aplikasi berhasil dijalankan dengan `flutter run` dan alur dua role berhasil diuji melalui Playwright Android pada Redmi 12.**

Pengujian memakai demo lokal dalam memori, package `com.example.lab_inventory.demo`. Database produksi tidak diubah. Pemilihan role demo belum membuktikan autentikasi atau otorisasi Supabase produksi.

## Perangkat dan aplikasi

- Redmi 12 / 23053RN02A, Android 15 API 35, arm64.
- Serial ADB: `6acc03487d78`; SDK platform-tools 37.0.1.
- Playwright 1.64.1, driver Android 1001; kendali native melalui `AndroidDevice`.
- APK: `build/app/outputs/flutter-apk/app-demo-debug.apk`.
- SHA-256 APK yang diuji: `982d90f139a9e5fa1a61f1345e77ff210d85377aeafd89f9deae2b8917bb1a2d`.

Perintah peluncuran setelah APK dibangun:

```powershell
flutter run -d 6acc03487d78 --flavor demo -t lib/main_demo.dart --no-pub --use-application-binary=build/app/outputs/flutter-apk/app-demo-debug.apk
```

## Hasil alur

Stok awal Proyektor Demo adalah 2. Perubahan berikut diamati pada UI Android dengan pergantian mahasiswa dan laboran dalam proses aplikasi yang sama.

| Pemeriksaan | Hasil yang diamati |
| --- | --- |
| Mahasiswa masuk, katalog, detail | Berhasil; gambar proyektor dan laptop tampil |
| Pengajuan tanpa tanggal | Pesan validasi tampil; formulir tetap terbuka |
| Pengajuan valid pertama | Status `PENDING`; stok tetap 2 |
| Laboran menyetujui | Status `APPROVED`; stok menjadi 1 |
| Pengembalian kondisi baik | Status `RETURNED`; stok kembali 2 |
| Pengajuan kedua ditolak | Status `REJECTED`; stok tetap 2 |
| Pengajuan ketiga disetujui | Stok menjadi 1 |
| Pengembalian kondisi rusak | Pilihan rusak tercentang, pengembalian selesai; stok siap pakai tetap 1 |
| Pencarian katalog | Kata `laptop` menampilkan kartu Laptop Demo |
| Tambah barang tanpa nama/stok valid | Pesan validasi tampil |
| Laboran tambah barang | `USB Hub Uji Android`, stok 1, muncul di katalog |
| Logout dan pergantian role | Berhasil kembali ke layar MASUK dan masuk dengan role lain |
| Riwayat akhir | Tiga transaksi: `RETURNED`, `REJECTED`, `RETURNED` |

Pada akhir pengujian, demo dibiarkan terbuka pada riwayat peminjaman mahasiswa. Data latihan hilang ketika proses aplikasi ditutup.

## Perbaikan dari temuan perangkat

Tombol KIRIM tertutup area navigasi sistem Android 15. Ketukan di area tersebut sempat memicu Home Android. Pembungkus aplikasi sekarang memakai `SafeArea` bagian bawah; padding atas berulang pada demo juga dihilangkan.

- [Sebelum perbaikan](evidence/device/02-student-form-before-safe-area.png).
- [Sesudah perbaikan](evidence/device/05-form-safe-area-fixed.png).

Perbaikan area bawah berlaku pada entry point operasional dan demo. Dua regression test memeriksa posisi tombol dengan inset sistem untuk kedua mode; pemeriksaan fisik dilakukan pada mode demo.

## Validasi dan bukti

- `flutter analyze --no-pub`: bersih.
- `flutter test --no-pub`: **32 test lulus**, termasuk regression test area aman.
- Ringkasan log native: **18 checkpoint berhasil**, **13 PNG valid**.
- [Ringkasan checkpoint dan hash APK](evidence/device/native-checkpoints.json).
- [Log aksi lengkap](evidence/device/actions.jsonl).
- [Pengajuan pending](evidence/device/04-student-pending.png), [persetujuan laboran](evidence/device/03-admin-approved.png).
- [Pilihan pengembalian rusak](evidence/device/06-damaged-return.png), [stok sesudah pengembalian rusak](evidence/device/07-stock-after-damage.png).
- [Detail laptop](evidence/device/08-laptop-detail.png), [barang tambahan](evidence/device/09-admin-created-item.png), [hasil pencarian](evidence/device/10-catalog-search.png).
- [Riwayat laboran](evidence/device/11-final-history.png), [riwayat mahasiswa terakhir](evidence/device/12-student-final-history.png).

Log mentah tetap menyimpan **32 aksi gagal** dari percobaan sambungan, selector sebelum animasi selesai, dan pencocokan teks pencarian. Keyboard memasukkan `laptop` dengan huruf kecil; pemeriksaan akhir menerima perbedaan kapitalisasi dan hasil filter diperiksa pada screenshot. Angka checkpoint bukan klaim bahwa semua percobaan aksi berhasil. Skrip ringkasan membaca observasi yang berhasil, tanpa menjalankan ulang alur.

## Kendala perangkat dan pemulihan

Awalnya perangkat beberapa kali `unauthorized` atau terputus saat pemasangan. Pengguna mengizinkan debugging selalu dan mengaktifkan Instal lewat USB. APK aplikasi serta dua APK driver kemudian berhasil dipasang dengan `adb install --no-streaming`.

Transfer screenshot besar sempat menghasilkan PNG terpotong dan memutus sambungan. Helper sekarang membaca file screenshot perangkat dalam potongan base64 8 KiB, lalu memeriksa panjang dan penanda PNG sebelum menyimpannya. Polling selector dan jeda animasi juga ditambahkan. Ini perilaku yang diamati pada kombinasi perangkat/host ini; penyebab USB secara pasti belum ditetapkan. Tidak dilakukan perubahan driver Windows atau penonaktifan keamanan perangkat.

Panduan pengulangan: [tools/device-tests](../tools/device-tests/README.md). API mengikuti [dokumentasi resmi Playwright AndroidDevice](https://playwright.dev/docs/api/class-androiddevice).

## Batas pengujian dan pekerjaan berikutnya

Pengujian ini memverifikasi UI dan stok demo dalam memori. Login Supabase asli, RLS, transaksi Data API, perebutan stok dari dua koneksi, serta ledger barang rusak produksi belum diuji di perangkat. Performa build release belum dinilai.

Migration transaksi penuh pada database aktif masih menunggu rekonsiliasi stok fisik untuk peminjaman lama berstatus approved, sesuai [audit database](DATABASE_AUDIT_2026-10-19.md). Setelah stok dipastikan, terapkan migration sesuai panduan dan jalankan alur yang sama pada staging dengan akun mahasiswa/laboran asli sebelum penggunaan operasional.
