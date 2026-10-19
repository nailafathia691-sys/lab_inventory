# Persiapan aktivasi transaksi

Status terbaru: **aktivasi selesai**. Pengguna mengonfirmasi total proyektor 2 unit dengan 1 dicadangkan. Migration diterapkan dengan mode `total`, saldo tersedia menjadi 1, dan transaksi sudah aktif. Lihat [laporan penerapan](AKTIVASI_TRANSAKSI_2026-10-19.md). Bagian berikut adalah catatan persiapan sebelum konfirmasi.

Pengguna meminta aktivasi transaksi setelah penjelasan mode baca. Pertanyaan yang masih diperlukan: angka stok Proyektor Epson 2 berarti saldo tersedia di luar satu unit approved, atau total dua unit yang masih mencakup satu unit approved?

## Yang sudah dilakukan

- Memeriksa ulang database aktif: empat barang, empat profil, satu peminjaman approved satu unit; RPC transaksi penuh belum tersedia dan tidak ada trigger stok/auth tambahan.
- Menyimpan backup lokal privat data profiles/items/borrowings serta metadata kolom, constraint, policy, grants, dan helper role. Backup berada di `.dart_tool/backups/`, diabaikan Git. Tidak mengambil password atau kredensial Auth.
- Merekonstruksi skema dan data backup di PostgreSQL lokal/PGlite, termasuk varchar pelaku lama, kolom tanggal timestamp, constraint lama, profil mode baca, serta role admin yang sudah ditetapkan.
- Menguji migration penuh untuk kedua kemungkinan saldo. Semua role dan baris peminjaman lama dipertahankan. Saldo awal ledger sesuai saldo setelah rekonsiliasi.
- Menjalankan alur lokal tambah barang, pengajuan mahasiswa, approve laboran, pengulangan approve dengan ID sama, dan pengembalian baik. Stok tidak berkurang dua kali pada pengulangan.
- Memastikan mode `review_required` tetap menolak aktivasi dan mempertahankan saldo serta mode baca.
- Menyiapkan dua draft deployment privat di `.dart_tool/deployments/`. Masing-masing memeriksa bahwa data masih sama dengan backup di dalam transaksi sebelum melakukan migration. Jika ada perubahan sejak backup, deployment dibatalkan untuk ditinjau kembali.

## Hasil simulasi saldo

| Mode yang perlu dipilih berdasarkan kondisi fisik | Proyektor | Speaker | HDMI | Laptop |
| --- | --- | --- | --- | --- |
| `available`: stok lama sudah saldo tersedia | 2 | 3 | 6 | 4 |
| `total`: stok lama masih mencakup satu unit approved | 1 | 3 | 6 | 4 |

Kedua hasil adalah simulasi lokal, bukan keputusan atas stok fisik. Tidak ada draft yang dijalankan pada database aktif dalam tahap persiapan ini.

Untuk mengulang simulasi menggunakan backup privat:

```powershell
node tools/database-tests/rehearse-migration.mjs PATH_BACKUP_JSON
```

## Langkah setelah konfirmasi stok

Pilih draft sesuai jawaban fisik, jalankan migration penuh yang sudah diuji, verifikasi saldo/ledger/role/RLS serta RPC dalam transaksi uji yang di-rollback, lalu muat ulang sesi aplikasi dan periksa banner mode baca hilang. Alur transaksi nyata pada unit lab perlu mengikuti ketersediaan fisik; data lama tidak akan dihapus demi melewati validasi.
