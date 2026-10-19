# LabInventory — SRD v2 dan keputusan arsitektur

Tanggal: 18 Oktober 2026. Status: acuan implementasi tahap 1–2 di repository.

Dokumen ini menggantikan bagian teknologi, autentikasi, hak akses, skema transaksi, dan perilaku saat gagal pada SRD v1 (`SOFTWARE REQUIREMENT DOCUMENT.docx`). Dokumen v1 tetap menjadi riwayat rancangan awal; PHP/MySQL bukan backend implementasi versi ini.

## Keputusan backend

Flutter untuk Android; Supabase Auth untuk autentikasi; PostgreSQL Supabase untuk data, Row Level Security (RLS), dan fungsi transaksi melalui RPC. Mempertahankan backend ini memusatkan pekerjaan pada koreksi keamanan dan transaksi yang sudah ada. Tidak menambah PHP REST API atau database MySQL paralel.

Aplikasi bersifat online. Gangguan jaringan tidak dianggap sebagai sukses dan tidak diam-diam mengganti data operasional dengan data contoh. Demo adalah aplikasi terpisah dengan repository dalam memori; demo tidak menginisialisasi Supabase.

## Peran dan identitas

| Peran | Hak akses |
| --- | --- |
| Mahasiswa (`student`) | Membaca inventaris aktif, mengajukan peminjaman, membaca profil dan peminjaman milik sendiri |
| Laboran (`admin`) | Membaca inventaris dan transaksi lab, menambah inventaris, menyetujui/menolak pengajuan, mencatat pengembalian, membaca ledger dan audit |
| Tanpa sesi / akun nonaktif / sesi Supabase Anonymous Auth | Tidak dapat membaca data operasional atau menjalankan transaksi |

Pengguna dibuat melalui Supabase Auth oleh pengelola. Akun baru selalu `student`, termasuk jika metadata pendaftaran berisi role lain. Nama/NPM dapat diisi pengelola pada profil server. Perubahan role/aktivasi dilakukan lewat administrasi server yang tepercaya. Tidak ada role yang ditentukan oleh email khusus atau pilihan login.

Client mendapat hak baca terbatas melalui RLS. Client mahasiswa maupun laboran tidak mendapat izin menulis tabel transaksi, stok, role, ledger, atau audit secara langsung; penulisan yang didukung harus melalui RPC yang memeriksa `auth.uid()` serta profil aktif. Role tidak bisa dinaikkan melalui update profil dari client.

Logout menghapus sesi perangkat dan seluruh navigasi terlindungi. Saat sesi dipulihkan, diperbarui, atau profil gagal diverifikasi, aplikasi memeriksa profil server sebelum menampilkan dashboard. Logout lama dan hasil pembacaan profil yang terlambat tidak boleh menimpa sesi baru.

## Aturan peminjaman dan stok

- Satu pengajuan memuat satu jenis barang dan jumlah unit positif.
- Barang harus aktif, berkondisi `Baik` atau `Sangat Baik`, dan memiliki stok mencukupi pada saat pengajuan. Stok diperiksa lagi pada persetujuan.
- Tanggal menggunakan kalender **Asia/Jakarta**. Tanggal pinjam tidak boleh sebelum hari pengajuan; tenggat tidak boleh sebelum tanggal pinjam. Pengembalian pada hari yang sama diperbolehkan.
- `pending` belum menjamin ketersediaan dan tidak mengurangi stok. Beberapa pengajuan dapat menunggu unit yang sama.
- `approved` berarti laboran mengalokasikan/mencadangkan unit dan stok langsung berkurang dalam satu transaksi database.
- `rejected` hanya dapat berasal dari `pending` dan tidak mengubah stok.
- `returned` hanya dapat berasal dari `approved`, dengan hasil inspeksi baik/rusak yang wajib diisi. Semua unit pada satu pengajuan dikembalikan sekaligus pada tahap ini.
- Pengembalian baik menambah stok siap pakai. Pengembalian rusak menambah `stok_rusak` dan tidak menambah stok siap pakai; kondisi kategori barang tidak diubah sehingga unit sehat lainnya tetap dapat dipinjam.
- `tgl_kembali` adalah tenggat, sedangkan `returned_at` adalah waktu pengembalian aktual. `approved_at`, `updated_at`, dan pelaku perubahan dicatat server.
- Persetujuan untuk pengajuan yang tenggatnya sudah lewat ditolak. Persetujuan yang belum diambil tetap mencadangkan stok hingga diselesaikan laboran; pembatalan otomatis/serah terima terpisah belum menjadi bagian tahap ini.
- Transisi kembali ke `pending`, pengembalian dari `pending`, dan perubahan transaksi terminal tidak diperbolehkan.

## Integritas dan kegagalan

Penguncian baris barang dan peminjaman serta pembaruan stok bersyarat mencegah dua persetujuan menggunakan unit terakhir yang sama. Status, stok, ledger, audit, dan hasil permintaan harus commit bersama atau rollback bersama.

Setiap operasi tulis mempunyai UUID permintaan yang disimpan perangkat sebelum request dikirim. Server menyimpan UUID bersama pengguna, jenis operasi, payload, dan hasil. Retry dengan UUID/payload yang sama mengembalikan hasil lama. UUID yang sama dengan payload berbeda ditolak. Kegagalan jaringan/konfirmasi ambigu mempertahankan UUID; keberhasilan atau penolakan definitif menyelesaikan UUID lokal. Pengajuan dengan data yang sengaja berbeda merupakan permintaan baru.

ID permintaan bukan antrean offline. Pengguna perlu membuka ulang formulir dengan data yang sama untuk melanjutkan retry setelah aplikasi dimulai ulang, atau memeriksa riwayat. Data formulir yang belum dikirim tidak disimpan sebagai transaksi lokal. Penghapusan data aplikasi menghapus UUID lokal; hasil yang sudah commit tetap berada di server.

UI membedakan memuat, berhasil, kosong, dan gagal. Gagal simpan mempertahankan formulir dan input; status sukses hanya ditampilkan setelah konfirmasi server yang sah. Kegagalan memuat tidak menjadi daftar kosong maupun stok contoh. Pesan pengguna tidak menyarankan mematikan RLS dan tidak menampilkan detail SQL/token.

## Batas tahap ini

Tahap ini mencakup fondasi keamanan dan transaksi. Edit/arsip inventaris, pemulihan akun lewat UI, pengembalian sebagian, pelepasan reservasi otomatis, notifikasi, pagination, subscription Realtime, pemeliharaan aset, dan signing release dijadwalkan setelahnya.

Skema dan kebijakan server belum dianggap terpasang hanya karena berkas migration tersedia. Penerapan, rekonsiliasi stok lama, penetapan laboran, dan pengujian staging mengikuti [panduan penerapan](TAHAP_1_DAN_2.md).
