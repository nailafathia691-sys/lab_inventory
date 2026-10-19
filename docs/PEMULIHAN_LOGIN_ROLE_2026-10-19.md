# Pemulihan sesi admin dan akses mahasiswa

Tanggal: 19 Oktober 2026. Proyek Supabase: `ykbabgphvavzojrsjefh`.

Pembaruan: tahap mode baca dalam laporan ini sudah dilanjutkan ke [aktivasi transaksi penuh](AKTIVASI_TRANSAKSI_2026-10-19.md) setelah rekonsiliasi pengguna. Transaksi kini aktif; dokumen ini mempertahankan riwayat pemulihan profil/role sebelum aktivasi.

## Penyebab yang terverifikasi

Konfigurasi URL/public key sudah terbaca, tetapi database aktif belum mempunyai `public.profiles`. Empat akun Supabase Auth sudah ada. Aplikasi membutuhkan profil server untuk menentukan role sehingga autentikasi dapat berhasil, tetapi pembukaan sesi aplikasi gagal ketika profil dimuat. Pesan kegagalan sebelumnya belum membedakan penyiapan skema dari gangguan koneksi.

Pengguna mengonfirmasi `admin@lab.com` sebagai admin/laboran dan `tes@1.com` sebagai mahasiswa. Kedua email dicocokkan dengan UUID Auth yang ada sebelum role ditetapkan. Password tidak dibaca, diubah, atau diminta.

## Perbaikan yang sudah diterapkan ke database aktif

Script [staged_login_profiles.sql](../supabase/staged_login_profiles.sql) menyediakan tahap login dan baca data sebelum rekonsiliasi stok selesai:

- Membuat dan mengisi profil akun lama; role awal selalu student, tanpa mempercayai role dari signup metadata.
- Operator menetapkan UUID akun `admin@lab.com` sebagai admin berdasarkan konfirmasi pengguna. `tes@1.com` tetap student.
- RLS aktif pada profiles, items, dan borrowings; akses tanpa login tetap ditolak.
- Mahasiswa dapat membaca profil sendiri, inventaris, dan peminjaman sendiri. Admin dapat membaca data peminjaman untuk tugas laboran.
- Semua perubahan tabel langsung dari client, termasuk perubahan role dan stok oleh admin aplikasi, tetap ditolak.
- Saldo barang dan seluruh baris peminjaman dibandingkan sebelum/sesudah dalam transaksi yang sama. Tidak ada perubahan pada empat barang maupun satu peminjaman approved.

Script bersifat idempotent pada tahap ini dan mempertahankan role yang sudah ditetapkan operator. Script menolak diterapkan setelah skema penuh tersedia. Belum ada trigger pembuatan profil untuk akun baru pada tahap sementara ini; akun baru perlu backfill operator sampai migration penuh dipasang.

## Perubahan aplikasi

- Profil server membawa `transactions_enabled=false` selama tahap sementara.
- Aplikasi menampilkan banner **Mode baca: stok lama belum direkonsiliasi. Transaksi belum aktif.**
- Repository menolak pengajuan, tambah barang, dan perubahan status sebelum mengirim permintaan transaksi dari profil mode baca.
- Kesalahan tabel/RPC yang belum tersedia dan profil yang tidak ditemukan sekarang mempunyai pesan khusus, tanpa dilabeli sebagai koneksi umum atau menampilkan detail internal server.
- Migration penuh disesuaikan agar dapat melanjutkan dari tahap login ini. Role operator dipertahankan, dan `transactions_enabled` baru diaktifkan ketika migration penuh yang sudah direkonsiliasi berhasil commit.

## Verifikasi

Pada database aktif, transaksi `READ ONLY` dengan role authenticated dan klaim UUID masing-masing akun menguji hasil berikut, lalu di-rollback:

| Akun/peran | Profil | Barang terlihat | Peminjaman terlihat |
| --- | --- | --- | --- |
| admin@lab.com | admin, aktif | 4 | 1 |
| tes@1.com | student, aktif | 4 | 1 miliknya |
| Mahasiswa lain | student, aktif | 4 | 0, bukan pemilik |

Hak UPDATE profiles/items untuk authenticated dan hak SELECT profiles untuk anon juga diperiksa tetap tidak tersedia. Ini pemeriksaan otorisasi database, bukan login dengan password melalui UI untuk setiap akun.

APK production terbaru dibangun dan dipasang pada Pixel 7a menggunakan `flutter run -d 33211JEHN10338 --no-pub`. Dashboard laboran benar-benar diamati di perangkat dengan Total Barang **4** dan Pending **0**, tanpa pesan kegagalan sesi. [Bukti dashboard](evidence/login-roles/admin-dashboard.png). Banner mode baca juga terlihat pada screenshot.

Pengisian password mahasiswa melalui UI tidak diotomatisasi. Akses baca mahasiswa sudah diverifikasi pada database aktif menggunakan identitas pemilik yang benar. Tidak ada klaim bahwa transaksi produksi atau kedua login dengan password telah diuji end-to-end.

- `flutter analyze --no-pub`: tidak ada temuan.
- `flutter test --no-pub`: **40 test lulus**.
- Test PostgreSQL/PGlite: **37 test lulus**, termasuk lima test tahap login, isolasi pemilik, larangan eskalasi role, saldo tetap, dan kelanjutan migration penuh.
- [Ringkasan hasil](evidence/login-roles/verified-access.json).

## Yang masih menunggu rekonsiliasi

Stok Proyektor Epson tetap 2 dan satu peminjaman approved tetap ada. Arti angka stok lama belum dipastikan melalui pemeriksaan fisik. Oleh karena itu mutation RPC dan transaksi stok belum diaktifkan pada proyek aktif; tahap login ini memulihkan akses baca, bukan menyatakan stok siap pakai sudah benar.

Setelah laboran memverifikasi saldo, ikuti [panduan tahap 1–2](TAHAP_1_DAN_2.md) untuk migration penuh. Jangan memilih mode total/available berdasarkan data demo atau mengurangi stok lama dengan asumsi.
