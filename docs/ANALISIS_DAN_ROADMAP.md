# Analisis dan roadmap LabInventory

Tanggal peninjauan: 18 Oktober 2026.

Dokumen ini merekam kondisi sebelum perbaikan. Implementasi tahap 1–2 dan batas penerapannya dijelaskan pada [panduan tahap 1–2](TAHAP_1_DAN_2.md) serta [SRD v2](SRD_V2.md); rujukan baris kode di bawah mengacu pada versi sebelum perubahan.

## Penilaian utama

LabInventory sudah memiliki alur dasar yang jelas: katalog, pengajuan, persetujuan, pengembalian, serta dashboard mahasiswa dan laboran. Flutter dan Supabase dapat dipertahankan sebagai fondasi pengembangan. Namun, kondisi implementasi saat ini masih sesuai untuk prototipe/demo; penggunaan operasional membutuhkan perbaikan keamanan, integritas transaksi, dan penanganan kegagalan terlebih dahulu.

Penilaian ini berdasarkan pembacaan kode, konfigurasi Android, README, dokumen SRD, dan analisis statis. Tampilan belum diuji pada perangkat. Database Supabase tidak diakses; RLS, grants, trigger, constraint, backup, dan konfigurasi akun di server belum diverifikasi. Temuan tentang perilaku Flutter terkonfirmasi dari kode; dampak terhadap database disebut bersyarat bila bergantung pada konfigurasi server.

## Hasil verifikasi

- Satu-satunya berkas sumber aplikasi adalah `lib/main.dart`, sepanjang 4.552 baris.
- Tidak ditemukan test aplikasi, migration SQL, definisi RLS, atau workflow CI di repository.
- `flutter analyze --no-pub`: 17 temuan tingkat info berupa penggunaan API deprecated; tidak ada error atau warning dari analyzer. Perintah keluar dengan kode 1 karena temuan info tetap dianggap fatal pada konfigurasi bawaan.
- API yang ditandai antara lain `anonKey`, `withOpacity`, konfigurasi radio `groupValue`/`onChanged`, dan `DropdownButtonFormField.value`.
- Metadata SDK lokal menyebut Flutter 3.47.2 dan Dart 3.13.2. Ini berbeda dari angka versi di beberapa bagian dokumentasi.
- Tidak menjalankan pengujian transaksi, build release, atau perubahan database. Tidak ada test aplikasi yang bisa dijalankan dari repository saat peninjauan.

## Temuan prioritas

P0 = penghalang penggunaan dengan data operasional. P1 = perlu diselesaikan sebelum pilot diperluas. P2 = peningkatan setelah fondasi stabil.

| ID | Prioritas | Temuan dan bukti | Dampak dan perbaikan |
| --- | --- | --- | --- |
| SEC-01 | P0 | `main.dart:595–598`: tujuan dashboard ditentukan oleh email tertentu atau pilihan role pada form. `611–656`: kredensial uji tetap membuka dashboard ketika autentikasi gagal. `820–840`: mode demo membuka dashboard admin tanpa autentikasi. | Pengguna dapat membuka antarmuka admin tanpa role yang diverifikasi. Akses tulis sebenarnya masih bergantung pada server. Hapus bypass dari build operasional; ambil role dari sumber server yang tidak bisa diubah mahasiswa, lalu terapkan izin pada database dan navigasi. |
| SEC-02 | P0 | `1372` dan `4001`: dashboard/riwayat mahasiswa memanggil `getBorrowings()` tanpa `userId`, padahal parameter tersedia pada `260–271`. Kebijakan RLS tidak tersedia di repository. | Semua baris yang diizinkan server masuk ke layar mahasiswa. Jika RLS longgar, data mahasiswa lain berpotensi terlihat. Terapkan RLS berdasarkan `auth.uid()`, filter pengguna aktif pada query, dan uji dua akun mahasiswa serta satu laboran. Filter Flutter saja tidak cukup sebagai otorisasi. |
| SEC-03 | P0 | Logout pada `988–999` dan `1275–1283` hanya mengganti halaman; tidak ditemukan `supabase.auth.signOut()`. Splash selalu mengarah ke login. `295–296` mengganti pengguna tanpa sesi dengan UUID nol. | Sesi sebelumnya dapat tetap aktif meskipun layar sudah kembali ke login; mode demo dapat berjalan memakai sesi lama. Implementasikan logout sesungguhnya, bersihkan state pengguna, kelola perubahan sesi, dan tolak transaksi tanpa pengguna terautentikasi. |
| DATA-01 | P0 | `218–231`: permintaan katalog yang kosong/gagal diganti empat barang bawaan. `279–281`: kegagalan membaca peminjaman menjadi daftar kosong. | Data contoh dan kegagalan koneksi dapat terbaca sebagai kondisi lab yang sah. Pisahkan state memuat, kosong, gagal, dan berhasil. Mode demo harus memakai sumber data terpisah dan label yang jelas. |
| DATA-02 | P0 | `3111–3123`, `3374–3377`, dan `3536–3542`: penulisan gagal tetap diberi pesan tersimpan/berhasil secara lokal; tidak ditemukan implementasi penyimpanan lokal untuk transaksi tersebut. `3117` bahkan menyarankan mematikan RLS. | Pengguna dapat menganggap peminjaman atau barang sudah tercatat padahal belum. Hapus pesan sukses pada kegagalan, pertahankan input, berikan aksi coba lagi, dan perbaiki policy tanpa mematikan RLS. |
| DATA-03 | P0 | `318–333`: persetujuan/pengembalian hanya memperbarui status dan catatan. Tidak ditemukan transaksi stok, RPC, atau migration trigger di repository. | Aplikasi belum menunjukkan jaminan konsistensi antara stok dan peminjaman. Trigger server mungkin ada, tetapi belum terverifikasi. Implementasikan atau audit transaksi server yang mengubah status dan stok/reservasi secara atomik serta mencegah persetujuan atau pengembalian ganda. |
| DATA-04 | P0 | `3067–3097`: validasi tanggal hanya memeriksa keberadaan nilai. `3130`: kalender mengizinkan tanggal sejak 2020. Batas jumlah mengandalkan stok pada objek layar (`3225`). | Tanggal kembali sebelum tanggal pinjam dan stok yang sudah berubah belum ditangani. Validasi tanggal, jumlah positif, ketersediaan terbaru, dan kondisi barang pada server; ulangi validasi yang relevan di form untuk umpan balik cepat. |
| DATA-05 | P1 | `328–333`: update dianggap sukses tanpa meminta baris hasil atau memverifikasi perubahan. Tidak ada pemeriksaan status awal maupun kunci permintaan. | Update yang tidak mengenai baris dapat dianggap berhasil; request berulang setelah timeout berpotensi menduplikasi aksi. Gunakan hasil transaksi server yang eksplisit, pemeriksaan status awal, dan idempotency key. |
| ARCH-01 | P1 | Model, akses database, autentikasi, semua layar, dan widget berada di satu berkas; `InventoryService` statis mengakses client global. | Perubahan mudah memengaruhi banyak alur dan sulit diuji terpisah. Pisahkan per fitur, repository/service, serta controller/view model dengan dependensi yang dapat diganti saat test. |
| UX-01 | P1 | `1208–1218` dan `1629–1637`: nama/NPM tetap. `1827`: label lab buka tetap. `1399–1440`: pengumuman berupa teks tetap. | Identitas dan informasi operasional tidak mengikuti pengguna atau keadaan lab. Ambil profil terautentikasi, sediakan konfigurasi jam/penutupan, dan kelola pengumuman sebagai data. |
| FEAT-01 | P1 | SRD meminta CRUD inventaris dan filter kondisi; kode hanya menyediakan tambah/baca serta filter nama/kategori. `3634–3639` menerima deskripsi, tetapi `saveItem()` tidak mengirimkannya. | Kebutuhan utama belum lengkap dan input deskripsi hilang. Lengkapi edit, arsip/nonaktif, filter kondisi, serta penyimpanan deskripsi; lindungi histori barang yang sudah dipinjam. |
| PERF-01 | P1 | Query memakai `.select()` tanpa pagination; pencarian dilakukan setelah seluruh barang dimuat. Tidak ditemukan subscription Realtime. `IndexedStack` mempertahankan state halaman. | Volume data besar dapat memperlambat layar atau menghasilkan daftar terpotong oleh batas API. Perubahan antarhalaman/perangkat tidak otomatis sinkron. Terapkan pagination, filter server, indeks yang sesuai, dan invalidasi/refetch atau subscription terukur. |
| QA-01 | P1 | Dependency `flutter_test` tersedia, tetapi tidak ditemukan test atau CI. | Belum ada bukti otomatis bahwa hak akses dan transaksi tetap benar setelah perubahan. Prioritaskan test otorisasi database, transaksi stok bersamaan, kegagalan jaringan, dan alur inti. |
| REL-01 | P1 | `android/app/build.gradle.kts`: application ID masih `com.example.lab_inventory`; release menggunakan signing debug. Konfigurasi Supabase tetap di sumber. | Distribusi dan pemisahan lingkungan belum siap. Tetapkan ID organisasi, signing release, versi rilis, dan lingkungan development/staging/production. |
| DOC-01 | P1 | SRD menyebut PHP REST API/MySQL serta provider/http; kode memakai Supabase. README mengklaim tanpa data dummy dan realtime, sementara ada fallback barang tetap dan tidak ada subscription. README memuat kredensial uji. | Acuan implementasi dan hasil aktual berbeda. Tetapkan keputusan arsitektur, revisi SRD/README, dokumentasikan skema/policy yang benar, dan pisahkan akun demo dari operasional. |

Catatan keamanan: `supabaseAnonKey` adalah jenis key untuk client, sehingga keberadaannya dalam aplikasi bukan bukti kebocoran secret server. Pemindahan konfigurasi ke `--dart-define` membantu pemisahan lingkungan, tetapi tidak menyembunyikan nilai dalam aplikasi yang didistribusikan. Perlindungan data tetap bergantung pada grants, RLS, dan otorisasi server. Jangan menaruh `service_role` atau secret key di Flutter. Lihat [panduan API key Supabase](https://supabase.com/docs/guides/getting-started/api-keys).

## Keputusan produk dan arsitektur

1. Jadikan Android untuk satu laboratorium sebagai batas MVP, dengan dua role: mahasiswa dan laboran.
2. Rekomendasi teknis: pertahankan Flutter + Supabase agar pekerjaan fokus pada koreksi fondasi. Jika PHP/MySQL merupakan syarat penilaian yang wajib, keputusan ini harus diselaraskan sebelum refactor; perpindahan backend merupakan pekerjaan tambahan tersendiri.
3. Perlakukan MVP sebagai aplikasi online. Saat jaringan gagal, tampilkan kegagalan yang bisa dicoba ulang. Penyimpanan offline dan sinkronisasi baru ditambahkan jika ada kebutuhan nyata serta aturan konflik yang jelas.
4. Pisahkan demo dari data operasional melalui konfigurasi build dan repository demo terpisah. Demo tidak boleh menjalankan operasi pada Supabase produksi.
5. Tetapkan kapan unit dipesan dan kapan dianggap dipinjam. Rekomendasi awal: persetujuan mencadangkan stok; serah terima dicatat terpisah bila dibutuhkan lab. Pembatalan/kedaluwarsa persetujuan harus melepas cadangan tepat satu kali.

## Fondasi data yang perlu disiapkan

Struktur awal yang disarankan, menyesuaikan hasil audit skema server:

- `auth.users`: autentikasi dikelola Supabase Auth; tidak membuat tabel password tambahan.
- `profiles`: nama, NPM/NIP, dan identitas pengguna. Role disimpan atau ditetapkan melalui mekanisme server yang hanya dapat dikelola pihak berwenang; mahasiswa tidak dapat memperbarui role sendiri.
- `items`: katalog, kode unik, kategori, deskripsi, lokasi, dan status aktif.
- `borrowings`: pengguna, barang, jumlah, tenggat, status, waktu persetujuan/pengembalian, pelaku aksi, serta alasan penolakan.
- `inventory_movements` atau mekanisme ledger setara: penambahan, pencadangan, pelepasan, pengembalian layak pakai, dan kerusakan. Tetapkan satu sumber kebenaran agar ledger dan angka stok tidak berbeda.
- `audit_events`: catatan tindakan penting yang tidak dapat diedit mahasiswa, berisi pelaku, objek, waktu server, aksi, dan perubahan yang relevan. Daftar status transaksi saat ini belum setara dengan audit perubahan.

Tambahkan foreign key, kode inventaris unik, jumlah positif, stok tidak negatif, aturan tanggal, serta pembatasan transisi status. Bedakan tenggat pengembalian dari waktu kembali aktual. Barang rusak tidak otomatis kembali menjadi stok siap pinjam. Pelacakan per unit/nomor seri dapat menyusul bila dibutuhkan untuk aset bernilai tinggi.

Persetujuan dan pengembalian dijalankan melalui transaksi server/RPC yang:

1. Memverifikasi pengguna aktif dan wewenang laboran dari server.
2. Mengunci atau memperbarui data secara kondisional agar request bersamaan tidak memakai stok yang sama.
3. Memeriksa status awal, jumlah, dan ketersediaan unit.
4. Memperbarui peminjaman, stok/reservasi, serta audit dalam satu transaksi.
5. Memakai kunci permintaan unik agar pengulangan request tidak menggandakan efek.
6. Mengembalikan ID dan status hasil secara eksplisit; Flutter tidak menebak keberhasilan.

Pembatasan akses langsung ke tabel harus selaras dengan mekanisme tersebut agar client tidak dapat melewati aturan transaksi. Audit grants dan policy setiap operasi, bukan hanya menyembunyikan tombol. Rujukan: [Row Level Security Supabase](https://supabase.com/docs/guides/database/postgres/row-level-security).

## Struktur kode sasaran

```text
lib/
  main.dart
  app/                 # bootstrap, tema, navigasi, pengelolaan sesi
  core/                # konfigurasi, hasil/error bersama, utilitas
  features/
    auth/              # repository, controller, layar login/pemulihan akun
    profile/           # identitas pengguna terautentikasi
    inventory/         # model, repository, controller, katalog dan manajemen
    borrowing/         # pengajuan dan riwayat mahasiswa
    administration/    # approval, pengembalian, ringkasan laboran
  shared/widgets/      # komponen yang benar-benar dipakai lintas fitur
supabase/
  migrations/          # skema, constraint, policy, fungsi transaksi
  tests/               # otorisasi dan integritas database
test/                  # unit dan widget
integration_test/      # alur inti pada lingkungan uji
```

Refactor bertahap per alur; pertahankan perilaku yang sudah benar. Gunakan satu pendekatan pengelolaan state yang konsisten, misalnya controller berbasis ChangeNotifier/Provider. Pilihan package bukan syarat profesionalitas; pemisahan tanggung jawab dan kemudahan pengujian yang menjadi tujuan. Rujukan: [rekomendasi arsitektur Flutter](https://docs.flutter.dev/app-architecture/recommendations).

## Tahapan pelaksanaan

Estimasi awal: 6–8 minggu untuk satu pengembang yang terbiasa Flutter/Supabase dan bekerja penuh waktu. Estimasi harus disesuaikan setelah skema server diperiksa; perpindahan ke PHP/MySQL tidak termasuk.

| Tahap | Waktu | Pekerjaan utama | Kriteria selesai |
| --- | --- | --- | --- |
| 0. Selaraskan kebutuhan | 1–2 hari | Putuskan backend, aturan stok, status, identitas akun, dan batas MVP. Audit konfigurasi server secara sah; ekspor skema/policy menjadi migration. | SRD dan backlog mengikuti implementasi yang disepakati; kondisi RLS/trigger/constraint diketahui. |
| 1. Tutup masalah P0 | Minggu 1–2 | Hapus bypass login, pisahkan demo, implementasikan role server, RLS dan logout. Perbaiki pesan kegagalan, validasi, transaksi stok, serta idempotensi. Tambahkan test keamanan dan transaksi bersama perbaikannya. | Mahasiswa tidak dapat mengambil data pengguna lain atau melakukan aksi laboran melalui API; gagal simpan tidak pernah dilaporkan berhasil; request bersamaan tidak membuat stok berlebih. |
| 2. Rapikan dan lengkapi MVP | Minggu 3–4 | Pisahkan fitur/repository/controller, profil dinamis, edit/arsip barang, deskripsi, alasan penolakan, serta catatan pengembalian yang terstruktur. Tambahkan pemulihan akun sesuai metode provisioning pengguna. | Alur mahasiswa dan laboran berjalan end-to-end di staging; data bertahan setelah aplikasi dibuka ulang dan konsisten antarperangkat. |
| 3. Tingkatkan pengalaman dan kinerja | Minggu 5 | Pagination/filter server, pembaruan antarhalaman, penanda terlambat, detail transaksi, informasi operasional yang akurat, konsistensi komponen, serta pemeriksaan aksesibilitas. | Tidak ada overflow pada perangkat sasaran dan pembesaran teks; daftar ribuan data tetap dapat ditelusuri; status terbaru terlihat setelah aksi. |
| 4. Siapkan rilis dan pilot | Minggu 6–8 | CI, perbaikan deprecation, signing release, monitoring error, backup/restore, dokumentasi instalasi, dan uji penerimaan bersama laboran/mahasiswa. Jalankan pilot terbatas dan koreksi temuannya. | Seluruh kriteria rilis di bawah terpenuhi dan pengguna laboratorium menyetujui hasil uji penerimaan. |

## Pengujian yang paling bernilai

| Skenario | Hasil wajib |
| --- | --- |
| Pengunjung tanpa sesi meminta data pribadi atau mengubah inventaris | Ditolak server, termasuk saat request dibuat langsung di luar UI. |
| Mahasiswa A meminta transaksi mahasiswa B atau mencoba menjadi admin | Ditolak; role tidak bisa dinaikkan lewat form, metadata yang dapat diedit sendiri, atau update profil. |
| Kredensial salah atau layanan autentikasi gagal | Tetap pada alur login dengan pesan yang jelas; tidak membuka dashboard operasional. |
| Logout, lalu membuka mode demo | Sesi operasional berakhir; data demo terisolasi. |
| Dua laboran menyetujui pengajuan untuk unit terakhir secara bersamaan | Total unit yang dicadangkan tidak melebihi stok; request yang kalah mendapat hasil konflik. |
| Persetujuan/pengembalian yang sama dikirim dua kali | Efek stok dan audit bisnis tidak digandakan. |
| Timeout terjadi setelah server mungkin menyimpan | Status dapat diperiksa menggunakan ID/kunci permintaan; retry aman dan tidak membuat transaksi baru. |
| Jumlah nol/negatif, tanggal terbalik, barang rusak/nonaktif | Ditolak server dan diberi penjelasan di form. |
| Barang dikembalikan rusak | Transaksi tercatat kembali, tetapi unit rusak tidak menambah stok siap pakai. |
| Jaringan putus saat simpan atau memuat daftar | Form/input tetap tersedia; pesan kegagalan berbeda dari data kosong; tidak ada klaim tersimpan lokal tanpa penyimpanan nyata. |
| Database memiliki ribuan transaksi | Pagination, pencarian, dan hitungan dashboard tetap benar tanpa bergantung pada satu hasil `.select()` yang dibatasi API. |

## Kriteria siap digunakan secara profesional

- Semua masalah P0 terselesaikan dan diuji di staging dengan skema/policy yang sama seperti produksi.
- Test database mencakup otorisasi dan perubahan stok bersamaan; test aplikasi mencakup alur inti serta kegagalan simpan.
- CI menjalankan analisis statis dan test setiap perubahan; target akhir tidak ada error, warning, maupun deprecation yang belum ditangani.
- Application ID organisasi dan signing release disiapkan; material signing disimpan terpisah dari repository. Ikuti [panduan rilis Android Flutter](https://docs.flutter.dev/deployment/android).
- Lingkungan demo/development/staging terpisah dari produksi; key server tidak masuk aplikasi.
- Monitoring mencatat error dan konteks teknis tanpa password/token atau data pribadi berlebihan; ada penanggung jawab penanganan gangguan.
- Backup memiliki jadwal, tujuan pemulihan yang disepakati, dan bukti uji restore pada lingkungan terpisah.
- Akun uji tidak memberi akses ke data operasional; akses admin dikelola dan kredensial demo yang pernah dipublikasikan tidak digunakan kembali untuk produksi.
- Dokumen kebutuhan, panduan pengguna, konfigurasi SDK, skema, dan prosedur rilis sesuai implementasi aktual.
- Pilot dengan mahasiswa dan laboran menghasilkan bukti transaksi berhasil, penolakan benar, pengembalian benar, dan stok cocok dengan kondisi fisik.

## Peningkatan lanjutan setelah MVP stabil

1. Pengingat tenggat dan keterlambatan, dengan jadwal dan penerima yang dapat ditentukan laboratorium.
2. QR/barcode serta identitas per unit untuk aset yang perlu dilacak satu per satu.
3. Laporan CSV/PDF peminjaman, kerusakan, dan pemanfaatan alat berdasarkan kebutuhan laporan laboran.
4. Pemeliharaan, foto kondisi, pengembalian sebagian, dan stok opname dengan histori penyesuaian.
5. Reservasi berbasis rentang waktu, SSO institusi, atau beberapa laboratorium jika skala operasional memang memerlukannya.

Urutan kerja terdekat: selaraskan backend dan aturan stok, audit keamanan database, lalu selesaikan bypass autentikasi dan pesan penyimpanan yang keliru. Perluasan fitur mengikuti hasil perbaikan tersebut.
