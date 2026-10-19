# Penerapan perbaikan tahap 1–2

## Status dan hasil

Status terbaru: **migration penuh sudah diterapkan** pada proyek aktif dengan mode `total` setelah konfirmasi pengguna. Transaksi dan profil baru aktif, stok proyektor tersedia 1. [Laporan aktivasi dan verifikasi server](AKTIVASI_TRANSAKSI_2026-10-19.md). Keterangan menunggu rekonsiliasi berikut adalah riwayat tahap sebelumnya; prosedur migration di dokumen ini tetap menjadi panduan untuk lingkungan baru dan tidak untuk dijalankan ulang pada skema aktif.

Pembaruan login: tahap sementara [staged_login_profiles.sql](../supabase/staged_login_profiles.sql) sudah diterapkan pada database aktif untuk profil dan akses baca kedua role, tanpa perubahan saldo/status. [Laporan pemulihan](PEMULIHAN_LOGIN_ROLE_2026-10-19.md) mencatat verifikasi live. Migration transaksi penuh di bawah tetap menunggu rekonsiliasi fisik. Jangan menerapkan ulang tahap sementara pada skema penuh.

Implementasi di repository menggunakan keputusan [SRD v2](SRD_V2.md): Flutter + Supabase, reservasi stok pada persetujuan, dan pengembalian rusak dipisahkan dari stok siap pakai.

Perubahan mencakup role dari profil server; penghapusan bypass login dan fallback barang; logout dan penjagaan seluruh navigasi; filter peminjaman mahasiswa; pesan gagal yang jujur; validasi tanggal/jumlah; RPC transaksi stok; ledger/audit; serta UUID permintaan persisten untuk retry. Demo memiliki entry point, repository, banner, label, dan application ID Android terpisah.

**Migration transaksi penuh belum diterapkan.** Pada 19 Oktober 2026, akses operator dashboard Supabase berhasil digunakan untuk pemeriksaan live dan penerapan `202610180000_legacy_access_guard.sql`, tanpa perubahan stok/status. Akses publik sudah ditutup dan client sementara hanya dapat membaca data sesuai kepemilikan. Pengguna menyatakan saldo stok lama belum diketahui; migration penuh menunggu rekonsiliasi fisik. Bukti dan batas penerapan ada di [audit database aktif](DATABASE_AUDIT_2026-10-19.md).

Verifikasi lokal pada 18 Oktober 2026:

- `flutter analyze --no-pub`: tidak ada temuan.
- `flutter test --no-pub`: 28 test lulus.
- `npm.cmd --prefix tools/database-tests test`: 29 test SQL lulus.
- `flutter build apk --debug --flavor demo -t lib/main_demo.dart --no-pub`: berhasil menghasilkan `build/app/outputs/flutter-apk/app-demo-debug.apk`.
- Belum menjalankan aplikasi pada perangkat atau pengujian dua koneksi terhadap Supabase staging/produksi.

Verifikasi tambahan pada 19 Oktober: 32 test SQL lokal lulus; akses Data API tanpa login ditolak; isolasi antar-akun diuji pada database aktif dalam transaksi hanya-baca. Hasil 29 test SQL di atas adalah catatan verifikasi sebelum audit live dan penambahan guard/kompatibilitas legacy.

## Menyiapkan database staging

1. Gunakan proyek Supabase staging terpisah. Simpan backup/export database lama dan hasil `supabase/preflight.sql` sebelum perubahan apa pun pada proyek lama.
2. Tinjau kolom, foreign key, policy, grants tingkat tabel/kolom, RPC, dan trigger yang ada. Migration mendukung bentuk UUID yang tercantum dalam SRD v2. Bentuk ID text/integer, data tidak valid, atau trigger stok lama perlu migration penyesuaian yang ditinjau terlebih dahulu.
3. Jalankan migration `supabase/migrations/202610180001_secure_inventory.sql` sekali melalui Supabase SQL Editor sebagai pengelola. Berkas sudah memiliki `begin`/`commit`; jangan mengambil sebagian potongannya atau menonaktifkan RLS untuk melewati kegagalan.
4. Jika proyek dikelola dengan Supabase CLI, catat migration ini melalui workflow migration yang digunakan proyek dan uji pada staging dahulu. Jangan menjalankan file yang sama lagi pada database yang sudah berhasil dimigrasikan.

Migration mengganti seluruh policy dan grants client pada tabel yang dikelolanya. Penulisan client langsung akan ditolak setelah migration; versi aplikasi lama yang masih melakukan insert/update langsung tidak kompatibel. Jadwalkan peralihan serentak aplikasi/database dan hentikan penulisan versi lama selama penerapan.

## Rekonsiliasi data lama

Migration sengaja berhenti dan rollback pada kondisi yang tidak dapat ditentukan dengan aman:

| Kode | Tindakan pengelola |
| --- | --- |
| `LEGACY_SCHEMA_REVIEW_REQUIRED` | Periksa tipe ID dan susun konversi/penyesuaian foreign key yang mempertahankan data. |
| `LEGACY_TRIGGER_REVIEW_REQUIRED` | Audit trigger inventaris/peminjaman lama; satukan aturan stok agar tidak dijalankan dua kali. |
| `LEGACY_RPC_REVIEW_REQUIRED` | Audit fungsi `SECURITY DEFINER` publik lama; cabut akses atau pindahkan fungsi yang tidak aman, kemudian sesuaikan migration secara sadar. |
| `LEGACY_AUTH_TRIGGER_REVIEW_REQUIRED` | Satukan trigger pembuatan profil yang sudah ada dengan aturan bahwa semua akun baru berperan student. |
| `LEGACY_ORPHANS_REVIEW_REQUIRED` | Cocokkan peminjaman dengan akun Auth dan barang yang benar. UUID pengguna nol dari demo lama tidak boleh dianggap sebagai peminjam sah. Jangan hapus transaksi hanya agar migration lolos. |
| `LEGACY_ACTOR_REVIEW_REQUIRED` | Cocokkan label `updated_by` lama yang bukan UUID dengan akun yang benar; jangan menghapus catatan pelaku untuk melewati pemeriksaan. |
| `LEGACY_STOCK_REVIEW_REQUIRED` | Cocokkan unit fisik dan peminjaman aktif, lalu pilih mode stok yang benar pada header migration. |
| Kegagalan constraint/NOT NULL/unique | Koreksi data dengan jejak perubahan; jangan menghapus constraint keamanan sebagai jalan pintas. |

Untuk proyek yang sudah mempunyai `items` dan `borrowings`, mulai dari query baca berikut:

```sql
select status, count(*) from public.borrowings group by status;
select i.id, i.nama_barang, i.stok,
  coalesce(sum(b.jumlah) filter (where b.status = 'approved'), 0) as units_approved
from public.items i left join public.borrowings b on b.item_id = i.id
group by i.id, i.nama_barang, i.stok;
select b.id, b.user_id, b.item_id from public.borrowings b
left join auth.users u on u.id = b.user_id
left join public.items i on i.id = b.item_id
where u.id is null or i.id is null;
```

Jika ada peminjaman `approved`, ubah **hanya setelah rekonsiliasi** nilai `lab_inventory.legacy_stock_mode` pada header salinan migration yang akan diterapkan:

- `available`: angka `stok` lama sudah mengecualikan unit yang disetujui; angka tidak dikurangi lagi.
- `total`: angka `stok` lama masih termasuk unit yang disetujui; migration mengurangi unit aktif satu kali. Nilai negatif akan ditolak constraint.
- `review_required`: nilai bawaan; migration menolak meneruskan ketika masih ada peminjaman approved yang belum ditinjau.

Ledger dimulai dari saldo yang sudah direkonsiliasi. Histori audit sebelum migration tidak direkayasa: transaksi lama dicatat sebagai baseline, sedangkan tindakan baru mencatat audit sesungguhnya. Tanggal legacy bertipe timestamp dikonversi menjadi tanggal kalender Asia/Jakarta dalam transaksi migration.

## Akun dan role

Semua akun baru/backfill yang belum mempunyai profil dibuat sebagai `student`. Tidak ada promosi otomatis berdasarkan email atau metadata role. Buat/invite akun dari Supabase Auth, verifikasi identitasnya, lalu ubah profil dari SQL Editor operator:

```sql
-- Ganti placeholder dengan UUID akun yang benar dari Supabase Auth.
update public.profiles
set role = 'admin', nama = 'Nama Laboran', npm = 'NIP_TERVERIFIKASI'
where id = 'UUID_AKUN_LABORAN'::uuid
returning id, nama, role, is_active;
```

Pastikan tepat satu akun yang benar diperbarui. Tinjau role admin yang sudah ada sebelum deployment. Akun demo lama yang password-nya pernah dipublikasikan perlu dinonaktifkan/diganti kredensialnya oleh pengelola sebelum dipakai untuk operasional. Sesuaikan pengaturan pendaftaran/invitation Supabase dengan kebijakan laboratorium; layar registrasi publik belum ditambahkan.

`service_role`/secret key hanya untuk server/operator. Konfigurasi Flutter hanya menerima publishable key atau legacy anon key. Pembatasan data tetap ditegakkan melalui grants dan RLS, bukan kerahasiaan public key.

## Menjalankan aplikasi

Operasional, setelah migration dan akun siap:

```powershell
Copy-Item config/supabase.example.json config/supabase.local.json
# Isi URL proyek staging dan public key pada file lokal.
flutter pub get
flutter run --flavor production -t lib/main.dart --dart-define-from-file=config/supabase.local.json
```

Demo tanpa konfigurasi Supabase:

```powershell
flutter run --flavor demo -t lib/main_demo.dart
```

Flavor demo memakai akhiran application ID `.demo`, sehingga dapat dipasang berdampingan dengan operasional. Data demo dalam memori tidak membaca/menulis sesi atau database Supabase. Logout mahasiswa demo kemudian login laboran demo dalam proses yang sama untuk memproses pengajuannya.

## Verifikasi sebelum penerapan produksi

Jalankan test otomatis sesuai README. Test Flutter memeriksa sesi, konfigurasi key, validasi, cakupan query mahasiswa, RPC/idempotensi client, penjagaan navigasi, dan formulir gagal simpan. Test SQL PGlite menjalankan PostgreSQL nyata dalam satu koneksi: grants, RLS, RPC, constraint, rollback, perhitungan stok, audit, dan penolakan migration legacy.

Lengkapi pengujian staging berikut sebelum peralihan produksi:

1. Login dua mahasiswa dan satu laboran melalui Supabase Auth asli. Mahasiswa A tidak boleh membaca baris mahasiswa B, termasuk saat melakukan query API tanpa filter pengguna.
2. Coba operasi langsung API pada `profiles`, `items`, `borrowings`, ledger, dan audit memakai token mahasiswa maupun laboran. Insert/update/delete harus ditolak; aksi yang didukung berjalan melalui RPC.
3. Buat barang dengan satu unit dan dua pengajuan pending. Jalankan persetujuan dari **dua koneksi PostgreSQL berbeda**. Satu berhasil, yang lain gagal `INSUFFICIENT_STOCK`; saldo akhir nol, satu peminjaman tetap pending, dan hanya satu gerakan reservasi tercatat.
4. Ulangi request yang sama ketika koneksi terputus sesudah server mungkin commit. Gunakan UUID permintaan yang sama; transaksi dan gerakan stok tidak boleh bertambah dua kali.
5. Kembalikan unit baik lalu uji unit rusak. Pastikan saldo siap pakai, `stok_rusak`, status, waktu kembali aktual, serta audit cocok.
6. Buka halaman detail/dialog lalu akhiri sesi; seluruh halaman terlindungi harus hilang. Login ulang dengan akun berbeda dan pastikan data lama tidak ditampilkan.
7. Cocokkan stok database dengan inventaris fisik dan lakukan uji penerimaan laboran.

Test dua koneksi tidak dapat digantikan oleh `Promise.all` pada PGlite karena engine pengujian lokal memakai satu koneksi. Pengujian tersebut dan integrasi Auth/Data API masih menjadi syarat deployment, bukan hasil yang sudah diklaim dari test lokal.

## Pemulihan jika penerapan bermasalah

Jika migration gagal sebelum commit, PostgreSQL rollback seluruh perubahan dalam file; periksa penyebabnya di staging. Jika migration sudah commit, jangan menyalakan kembali aplikasi lama atau mematikan RLS. Hentikan penulisan, simpan perubahan terbaru, dan lakukan perbaikan maju yang ditinjau atau restore backup dengan rekonsiliasi transaksi sesudah backup. Prosedur backup dan restore produksi harus diuji oleh operator.
