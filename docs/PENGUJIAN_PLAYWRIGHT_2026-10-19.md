# Pengujian Playwright dan Database — 19 Oktober 2026

Tanggal: 19 Oktober 2026 (Asia/Jakarta).

Aplikasi dijalankan menggunakan Flutter di Chrome:

```powershell
flutter run -d chrome --web-hostname 127.0.0.1 --web-port 8766 -t lib/main_demo.dart --no-pub
```

Alamat lokal: http://127.0.0.1:8766/. Pengujian UI memakai viewport 412 × 915; tampilan inventaris juga diperiksa pada 1280 × 800.

## Ruang lingkup

UI yang diuji adalah **demo lokal dalam memori**, dengan kode antarmuka Flutter yang sama dan repository demo terpisah. Pengujian database asli dilakukan melalui SQL Editor Supabase yang terautentikasi serta permintaan HTTP baca ke Data API. Hasil ini belum merupakan uji integrasi login dan transaksi produksi dari browser hingga database.

## Hasil Playwright

| Alur | Hasil yang diverifikasi |
| --- | --- |
| Masuk mahasiswa demo | Identitas mahasiswa dan navigasi tampil |
| Pencarian inventaris | Kata Laptop menyembunyikan proyektor; mengosongkan pencarian mengembalikan daftar |
| Validasi tanggal kosong | Pengajuan ditahan dengan pesan pilih tanggal |
| Validasi keperluan kosong | Pengajuan ditahan dengan pesan isi keperluan |
| Batas jumlah (pemeriksaan interaktif) | Minus nonaktif pada 1; plus nonaktif ketika jumlah mencapai stok 2 |
| Pengajuan | Status pending terlihat ketika tab Peminjaman dibuka, tanpa Refresh manual |
| Stok pending | Tetap 2 |
| Keluar dan masuk laboran | Kembali ke layar login lalu membuka dashboard laboran |
| Persetujuan | Stok 2 → 1; saldo terbaru terlihat ketika tab Inventaris dibuka |
| Pengembalian baik | Riwayat menjadi returned; stok 1 → 2 |
| Penolakan pengajuan berikutnya | Riwayat menjadi rejected; stok tetap 2 |
| Pengembalian rusak | Setelah persetujuan stok 1; setelah pengembalian rusak stok siap pakai tetap 1 |
| Teks keperluan panjang | Terbungkus pada layar ponsel tanpa RenderFlex overflow |
| Console setelah perbaikan | 0 error dan 0 warning pada sesi pengujian ulang |

Dua skrip skenario mengembalikan `passed: true`. Skrip pertama mencatat urutan stok `[2, 2, 1, 2]`; skrip kedua memverifikasi saldo penolakan 2 dan saldo setelah pengembalian rusak 1. Angka tersebut adalah data demo.

## Temuan yang diperbaiki

1. Tab yang memakai IndexedStack mempertahankan hasil query lama. Riwayat sempat menampilkan data kosong setelah pengajuan, dan inventaris masih menampilkan saldo sebelum persetujuan. Saat tab dipilih, halaman data kini mengambil ulang data; posisi filter/pencarian tetap berada pada state halaman yang sama.
2. InfoLine pada formulir pengembalian meluber 32 piksel ke kanan pada layar ponsel. Nilai kini diberi lebar fleksibel dan dapat membungkus teks.
3. Teks kosong pada demo menyebut Supabase dan deskripsi dashboard menyatakan real-time. Teks kini menjelaskan status pengguna dan mekanisme muat ulang.
4. Shell web ditambahkan agar proyek dapat dijalankan menggunakan `flutter run -d chrome`.

Dua test regresi ditambahkan untuk riwayat setelah perpindahan tab dan teks panjang pada lebar 346 piksel. Subscription Realtime belum diimplementasikan; perubahan oleh perangkat lain tetap memerlukan query ulang.

## Pemeriksaan database asli

Project Supabase: `ykbabgphvavzojrsjefh`.

- Uji role/JWT di `supabase/verify_legacy_access.sql` dijalankan ulang melalui Playwright dalam transaksi **READ ONLY**, kemudian ROLLBACK. Pemilik dapat membaca pinjamannya, pengguna berbeda tidak dapat membaca pinjaman pemilik, dan sesi Anonymous Auth tidak melihat inventaris maupun pinjaman.
- RLS aktif pada items dan borrowings. Role anon tidak memiliki SELECT/INSERT/UPDATE/DELETE; authenticated hanya memiliki SELECT.
- GET nyata ke Data API items dan borrowings dengan public anon key ditolak: HTTP 401, kode database 42501.
- Seluruh pemeriksaan data yang dijalankan menghasilkan 0 masalah: stok null, tanggal invalid, jumlah tidak positif, keperluan kosong, referensi yatim, dan updated_by terisi yang bukan UUID.
- Saldo dan reservasi cocok dengan audit sebelumnya: Proyektor Epson 2 (approved 1), Laptop Lenovo 4, Kabel HDMI 6, Speaker Aktif 3. Tidak ada transaksi demo masuk ke database asli.

Migration transaksi penuh belum diterapkan. Stok lama masih memerlukan pemeriksaan fisik sesuai jawaban pengguna; mode `review_required` tetap dipertahankan. Profil/role server dan RPC transaksi produksi belum dapat diuji sebagai alur UI menyeluruh pada proyek tersebut. Uji dua koneksi serentak juga masih perlu dijalankan pada staging setelah migration tersedia.

## Verifikasi otomatis

- `flutter analyze --no-pub`: tidak ada masalah.
- `flutter test --no-pub`: **30 lulus**.
- `npm.cmd --prefix tools/database-tests test`: **32 lulus**.

Test SQL lokal memakai PGlite dan memeriksa grants/RLS, role server, validasi, idempotensi, rollback, stok terakhir, pengembalian baik/rusak, ledger, serta kompatibilitas migration legacy. Test tersebut bukan bukti konkurensi dua koneksi pada Supabase.

## Mengulang pengujian dan bukti

Dengan Flutter Chrome masih berjalan, jalankan file fungsi berikut memakai tool Playwright `browser_run_code_unsafe` dengan parameter `filename`:

1. [demo-flow.js](../tools/playwright/demo-flow.js), yang memuat ulang demo.
2. [demo-alternatives.js](../tools/playwright/demo-alternatives.js), tanpa reload setelah skrip pertama.

Skrip mengaktifkan semantics Flutter dan menggunakan klik serta keyboard biasa. Fokus diberikan sebelum mengetik karena input HTML Flutter baru dibuat setelah fokus. Selector teks gabungan menangani baris baru pada semantics.

Bukti layar:

- [Pengajuan pending](evidence/playwright-student-pending.png)
- [Pengembalian dengan teks panjang](evidence/playwright-return-phone.png)
- [Riwayat returned](evidence/playwright-admin-returned.png)
- [Stok pulih menjadi 2](evidence/playwright-stock-restored.png)
- [Pilihan kondisi rusak](evidence/playwright-damaged-return.png)
- [Stok tetap 1 setelah rusak](evidence/playwright-stock-after-damage.png)
- [Inventaris pada desktop](evidence/playwright-desktop.png)

Langkah operasional berikutnya tetap rekonsiliasi stok fisik, penerapan migration dan penetapan laboran di server, kemudian uji integrasi serta konkurensi di staging. Tidak ada kredensial atau password yang disimpan dalam laporan atau skrip skenario.

