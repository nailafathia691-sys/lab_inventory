# Pemeriksaan dan pembatasan akses database aktif

Tanggal: 19 Oktober 2026, Asia/Jakarta.

Status terbaru: migration transaksi penuh sudah diterapkan dengan mode `total` setelah rekonsiliasi dikonfirmasi pengguna. Proyektor tersedia 1, reservasi lama tetap 1, dan transaksi kedua role aktif. Lihat [laporan aktivasi](AKTIVASI_TRANSAKSI_2026-10-19.md). Catatan pembatasan dan saldo belum terverifikasi di bawah adalah riwayat sebelum aktivasi ini.

Pembaruan setelah audit awal: `staged_login_profiles.sql` sudah diterapkan untuk memulihkan profil, role admin yang dikonfirmasi pengguna, dan akses baca admin/mahasiswa. Saldo/status lama tetap sama dan transaksi belum aktif. Lihat [hasil pemulihan login](PEMULIHAN_LOGIN_ROLE_2026-10-19.md). Bagian kondisi sebelum perubahan di bawah tetap menjadi riwayat audit awal.

Proyek: `ykbabgphvavzojrsjefh` — nailafathia691-sys's Project.
Akses operator berhasil melalui sesi dashboard Supabase akun `nailafathia691-sys`. Akun GitHub lokal `codpor` hanya memiliki akses baca ke repository; kredensial GitHub tidak digunakan sebagai kredensial PostgreSQL. Tidak ada token atau password yang disalin ke repository.

## Kondisi sebelum perubahan

- Tabel publik hanya `items` dan `borrowings`; `profiles` belum ada.
- Terdapat 4 barang, 4 akun Auth, dan 1 peminjaman `approved`.
- `borrowings`: RLS nonaktif, dengan izin baca/tulis pada role `anon` dan `authenticated`.
- `items`: RLS aktif tetapi tidak mempunyai policy.
- Tidak ditemukan trigger pada `items`, `borrowings`, atau `auth.users`, maupun fungsi publik `SECURITY DEFINER` non-extension.
- `borrowings.updated_by` bertipe `varchar`, bukan UUID. Migration penuh sudah disesuaikan untuk mengonversi UUID valid/kolom kosong tanpa menghapus nilai; label pelaku yang tidak valid tetap memerlukan peninjauan operator.
- Pemeriksaan data tidak menemukan stok null, tanggal tidak valid, jumlah tidak positif, keperluan kosong, referensi yatim, atau nilai `updated_by` non-UUID yang terisi.

| Barang | Nilai stok tersimpan | Unit dalam pengajuan approved |
| --- | --- | --- |
| Proyektor Epson | 2 | 1 |
| Laptop Lenovo | 4 | 0 |
| Kabel HDMI | 6 | 0 |
| Speaker Aktif 15 inci | 3 | 0 |

Peminjaman approved adalah 1 unit Proyektor Epson untuk 20–30 Oktober 2026. Pengguna menyatakan bahwa arti saldo stok lama belum diketahui dan memerlukan pemeriksaan fisik. Angka di atas tidak dinyatakan sebagai stok siap pakai yang sudah direkonsiliasi.

## Perubahan yang sudah diterapkan

`supabase/migrations/202610180000_legacy_access_guard.sql` sudah dijalankan secara transaksional melalui SQL Editor operator:

- RLS aktif pada kedua tabel.
- Semua izin baca/tulis role `anon` dicabut.
- Client yang login hanya memperoleh hak SELECT; perubahan tabel langsung ditolak, termasuk dari akun aplikasi yang sebelumnya dianggap admin oleh UI lama.
- Inventaris dapat dibaca oleh pengguna terautentikasi non-anonymous.
- Peminjaman hanya dapat dibaca oleh akun pemiliknya, dengan `user_id = auth.uid()`.
- Sesi Supabase Anonymous Auth tidak memperoleh data.
- Tidak ada saldo stok, status peminjaman, atau role akun yang diubah. Pemeriksaan sebelum/sesudah menunjukkan saldo dan jumlah reservasi sama.

Pengamanan ini bersifat sementara selama rekonsiliasi stok. **Akses tulis aplikasi dibatasi sampai migration transaksi penuh diterapkan.** Pengelola masih dapat mengakses database melalui dashboard operator. Migration guard aman dijalankan ulang sebelum migration penuh; setelah skema penuh tersedia, guard tidak mengubah policy baru.

## Bukti verifikasi

- Metadata live: RLS kedua tabel aktif; `anon` tidak mempunyai SELECT/INSERT/UPDATE/DELETE; `authenticated` hanya mempunyai SELECT.
- Permintaan HTTP GET nyata ke Data API `items` dan `borrowings`, menggunakan public anon key proyek, sama-sama ditolak dengan HTTP 401 dan kode PostgreSQL `42501`.
- Uji SQL pada database aktif dengan role/JWT pengguna dalam transaksi `READ ONLY` yang di-rollback: pemilik melihat transaksi sendiri; akun berbeda tidak melihat transaksi pemilik; sesi anonymous-auth tidak melihat inventaris maupun peminjaman. Tidak dilakukan login dengan password demo.
- Script uji baca tersimpan di `supabase/verify_legacy_access.sql`.
- Test lokal PostgreSQL/PGlite: 32 lulus, termasuk guard yang idempotent, saldo tetap, pembatasan antar-akun, dan kompatibilitas kolom pelaku legacy.

Uji ini memverifikasi pembatasan database yang sudah diterapkan. Uji dua koneksi untuk reservasi stok belum dijalankan pada proyek aktif karena fungsi transaksi penuh belum dipasang.

## Pekerjaan yang masih memerlukan data fisik

Migration `202610180001_secure_inventory.sql` **belum diterapkan**. Header tetap `review_required`; mode `total` maupun `available` tidak dipilih tanpa kepastian pengguna.

Laboran perlu mencocokkan total unit Proyektor Epson milik lab dengan 1 unit yang sudah dicadangkan pada pengajuan tersebut, lalu menetapkan saldo siap pakai. Jika angka 2 adalah total sebelum reservasi, saldo setelah reservasi adalah 1. Jika angka 2 sudah saldo tersedia setelah reservasi, nilainya tetap 2. Jangan menebak berdasarkan data demo atau mengurangi stok dua kali.

Setelah saldo diverifikasi, lanjutkan backup dan penerapan migration penuh, penetapan profil laboran yang benar, serta uji transaksi/stok di staging sesuai `TAHAP_1_DAN_2.md`.
