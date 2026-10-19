# Aktivasi transaksi produksi — 19 Oktober 2026

**Selesai: migration penuh sudah diterapkan pada Supabase aktif dan mode baca dinonaktifkan untuk profil aktif.**

Pengguna mengonfirmasi total Proyektor Epson **2 unit**, dengan **1 unit approved/dicadangkan**. Karena stok lama masih mencakup unit tersebut, deployment menggunakan mode `total`: saldo tersedia menjadi **1**.

## Penerapan

- Database terbaru diperiksa dan dibandingkan dengan backup privat yang sudah disiapkan. Data masih cocok sebelum penerapan.
- Draft deployment berasal dari `202610180001_secure_inventory.sql` yang sudah diuji pada salinan lokal skema/data aktual. Draft memakai mode `total` dan memeriksa ulang snapshot di dalam transaksi dengan penguncian tabel sebelum perubahan skema.
- Migration dijalankan sekali melalui SQL Editor operator pada proyek `ykbabgphvavzojrsjefh`.
- Role admin dan mahasiswa dipertahankan. Empat profil memperoleh `transactions_enabled=true`.
- RPC tambah barang, pengajuan, dan pemrosesan peminjaman aktif; ledger, audit, idempotensi, RLS, dan trigger profil akun baru sudah tersedia.
- Peminjaman proyektor lama tetap approved satu unit. Saldo awal ledger proyektor adalah 1; histori reservasi lama tidak direkayasa menjadi transaksi baru.

Saldo tepat setelah migration: Proyektor **1**, Speaker **3**, HDMI **6**, Laptop **4**. Satu peminjaman lama dan empat barang tetap ada.

Backup dan draft deployment ada dalam `.dart_tool/backups/` dan `.dart_tool/deployments/`, diabaikan Git. Password/kredensial Auth tidak diambil. Tabel riwayat migration Supabase CLI belum ada; penerapan ini tercatat sebagai penerapan manual melalui laporan dan bukti verifikasi. Jangan menjalankan ulang migration penuh pada skema yang sudah aktif.

## Verifikasi server aktif

[Script verifikasi](../supabase/verify_transaction_activation.sql) menjalankan RPC sebenarnya sebagai role authenticated dengan klaim UUID akun admin/mahasiswa yang benar, lalu me-rollback data pengujian. Ini bukan penggantian password atau login bypass pada aplikasi.

Hasil yang lulus:

- Pengajuan pending tidak mengurangi stok.
- Retry pengajuan menghasilkan transaksi yang sama.
- Mahasiswa tidak bisa menyetujui transaksi dan tidak melihat peminjaman pengguna lain.
- Approve mengurangi stok tepat satu kali, termasuk retry dengan ID sama dan ID baru.
- Pengajuan saat stok habis ditolak.
- Penolakan tidak mengurangi stok.
- Pengembalian baik menambah stok tepat satu kali, termasuk retry.
- Pengembalian rusak menambah stok rusak dan tidak menambah stok siap pakai.
- Saldo ledger cocok dengan saldo barang.
- RLS aktif; akses tanpa login dan perubahan tabel langsung dari client tetap ditolak.
- Peminjaman proyektor lama tetap approved dan stok tersedia tetap 1.

Setelah rollback diperiksa ulang: barang **4**, peminjaman **1**, opening ledger **4**, audit baseline **1**, operation request **0**. Tidak ada baris pengujian yang tertinggal. Sequence kode barang dapat maju saat pengujian RPC karena alokasi nomor PostgreSQL tidak ikut rollback.

Ada satu kesalahan referensi variabel pada draft query verifikasi awal; query tersebut gagal dan transaksi uji tidak di-commit. Referensinya diperbaiki dengan label blok, lalu seluruh pemeriksaan server lulus. Migration yang sudah berhasil tidak dijalankan ulang.

[Hasil server](evidence/transaction-activation/server-verification.json) dan [pemeriksaan akhir](evidence/transaction-activation/current-state.json).

## Verifikasi aplikasi dan aktivitas setelah aktivasi

Aplikasi production pada Pixel 7a dibuka ulang untuk memuat profil terbaru. Dashboard laboran berhasil dibuka. Setelah itu akun mahasiswa juga diamati pada perangkat; banner mode baca sudah tidak tampil dan katalog menunjukkan Proyektor Epson tersedia **1**.

- [Katalog dan saldo proyektor](evidence/transaction-activation/projector-stock-one.png).
- [Riwayat mahasiswa setelah aktivasi](evidence/transaction-activation/student-history-active.png).

Selama verifikasi, muncul transaksi operasional baru untuk satu Speaker Aktif. Audit server mencatat `borrowing_requested` lalu `borrowing_approved` oleh akun admin. Saldo speaker menjadi **2** dan ledger tetap cocok. Transaksi operasional ini dipertahankan dan tidak termasuk baris uji rollback.

Saldo terakhir yang diamati: Proyektor **1**, Speaker **2**, HDMI **6**, Laptop **4**; terdapat **2 peminjaman approved**. Ini berbeda dari snapshot tepat setelah migration karena transaksi operasional baru tersebut.

Pengujian ini membuktikan RPC server dan tampilan akun aktif pada perangkat. Pengisian password kedua akun secara otomatis serta uji dua koneksi serentak belum dilakukan pada tahap ini. Uji lokal sebelumnya mencakup 40 test Flutter, 37 test SQL, dan simulasi migration pada data aktual; tidak ada perubahan kode Flutter yang diperlukan untuk aktivasi server ini.

## Menggunakan aplikasi

Mahasiswa dapat mengajukan peminjaman. Laboran dapat menambah barang, menyetujui/menolak pengajuan, dan memproses pengembalian melalui RPC. Sesi yang masih menyimpan profil mode baca perlu dibuka ulang atau keluar/masuk agar mengambil pengaturan terbaru.

File migration di repository tetap memakai nilai aman `review_required` untuk lingkungan lain. Keputusan `total` hanya diterapkan pada salinan deployment proyek ini berdasarkan konfirmasi pengguna.
