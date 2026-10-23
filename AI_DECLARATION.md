# Deklarasi Penggunaan AI — LabInventory

**Nama:** Naila Fathia

**NPM/NIM:** 2413025076

**Program studi:** Pendidikan Teknologi Informasi, Universitas Lampung

**Mata kuliah:** Mobile Programming / Pemrograman Mobile

**Judul aplikasi:** LabInventory — Inventaris dan Peminjaman Barang Laboratorium

> **Status: draf untuk ditinjau pemilik proyek.** Dokumen ini mengikuti bagian C.3 pada `Intruksi Video.pdf`. Identitas dan uraian teknis diambil dari repository. Riwayat percakapan pengembangan belum tersedia sebagai bukti, sehingga atribusi penulisan kode, prompt asli, dan perubahan manual perlu dikonfirmasi sebelum dikumpulkan. Contoh prompt di bawah merupakan rekonstruksi, bukan kutipan riwayat percakapan.

## 1. Tujuan penggunaan AI

AI digunakan sebagai alat bantu yang penggunaannya harus dinyatakan secara terbuka. Bantuan dapat mencakup penjelasan kode, usulan implementasi, penelusuran masalah, dan penyusunan dokumentasi. Keluaran AI tetap perlu diperiksa terhadap kebutuhan aplikasi dan diuji sebelum diterima.

LabInventory menggunakan Flutter/Dart untuk aplikasi serta Supabase Auth dan PostgreSQL untuk autentikasi dan penyimpanan data. Acuan implementasi terkini adalah [SRD v2](docs/SRD_V2.md).

## 2. Daftar alat AI

| Alat | Penggunaan yang dapat dipastikan |
| --- | --- |
| Codex dari OpenAI | Membaca panduan tugas dan berkas proyek untuk membantu menyusun draf `AI_DECLARATION.md` ini. |

**Perlu dilengkapi:** sebutkan alat AI yang benar-benar digunakan selama pengembangan aplikasi beserta tugasnya. Jika Codex juga membantu implementasi, cantumkan modulnya pada bagian berikut. Tambahkan ChatGPT, Copilot, Claude, Gemini, atau alat lain hanya jika memang digunakan.

## 3. Pembagian peran AI dan pengerjaan manual

Tabel berikut memetakan modul yang ada di proyek agar atribusi dapat diisi secara spesifik. Keberadaan kode atau laporan pengujian tidak membuktikan siapa yang menulis atau menjalankannya.

| Modul / pekerjaan | Berkas terkait | Atribusi AI dan manual |
| --- | --- | --- |
| Konsep aplikasi dan kebutuhan mahasiswa/laboran | [SRD v2](docs/SRD_V2.md) | **Konfirmasi:** siapa yang merumuskan kebutuhan dan bagian mana yang dibantu AI. |
| Antarmuka, navigasi, katalog, dan formulir | [main.dart](lib/main.dart) | **Konfirmasi:** rancangan/implementasi AI serta widget atau logika yang ditulis manual. |
| Autentikasi, profil, role, dan logout | [session_controller.dart](lib/auth/session_controller.dart) | **Konfirmasi:** bantuan AI dan perubahan manual pada pengelolaan sesi. |
| Validasi dan akses data peminjaman | [models.dart](lib/core/models.dart), [inventory_repository.dart](lib/data/inventory_repository.dart) | **Konfirmasi:** asal logika validasi dan pemanggilan RPC. |
| Aturan stok, transaksi, dan keamanan database | [migration SQL](supabase/migrations/202610180001_secure_inventory.sql) | **Konfirmasi:** bantuan AI pada SQL serta peninjauan/perubahan manual terhadap aturan stok dan hak akses. |
| Demo dengan data dalam memori | [main_demo.dart](lib/main_demo.dart), [demo_backend.dart](lib/demo/demo_backend.dart) | **Konfirmasi:** pembagian pengerjaan mode demo. |
| Pengujian dan perbaikan tampilan | [test Flutter](test), [test SQL](tools/database-tests/security.test.mjs) | **Konfirmasi:** siapa yang menyusun skenario, membuat skrip, menjalankan pengujian, dan memperbaiki temuan. |
| Penyusunan deklarasi ini | `AI_DECLARATION.md` | Draf dibantu Codex; pemeriksaan dan persetujuan isi dilakukan pemilik proyek sebelum pengumpulan. |

**Modul yang murni ditulis manual:** belum dapat ditetapkan dari bukti yang tersedia. Isi dengan nama berkas/fungsi dan kontribusi sebenarnya. Jika tidak ada modul yang sepenuhnya ditulis manual, nyatakan secara jujur dan jelaskan kontribusi manual dalam penentuan kebutuhan, peninjauan, perubahan kode, atau pengujian.

## 4. Studi kasus prompting

### Kasus 1 — Riwayat dan stok belum diperbarui setelah berpindah tab

**Contoh rumusan prompt (rekonstruksi):**

```text
Pada LabInventory, setelah mahasiswa mengajukan peminjaman, tab riwayat
masih menampilkan data lama. Setelah laboran menyetujui, stok pada tab
inventaris juga belum berubah. Periksa penggunaan IndexedStack dan
pengambilan data. Usulkan perbaikan agar tab menampilkan data terbaru
tanpa menghilangkan filter atau pencarian yang sedang dipakai.
```

**Kondisi awal yang terdokumentasi:** halaman dalam `IndexedStack` mempertahankan hasil query lama. Riwayat sempat terlihat kosong setelah pengajuan dan inventaris belum menampilkan saldo setelah persetujuan. Kondisi ini belum dapat diatribusikan sebagai keluaran AI tanpa riwayat prompt/kode awal.

**Perbaikan yang tercatat:** halaman mengambil ulang data saat tab dipilih, sedangkan state filter dan pencarian dipertahankan. Mekanisme ini menggunakan query ulang; subscription Supabase Realtime belum diimplementasikan.

**Hasil pemeriksaan terdokumentasi:** pengajuan tampil sebagai `pending` saat tab peminjaman dibuka. Pada demo, stok awal 2 tetap 2 saat pengajuan, menjadi 1 setelah persetujuan, dan kembali 2 setelah pengembalian baik. Lihat [laporan pengujian Playwright](docs/PENGUJIAN_PLAYWRIGHT_2026-10-19.md).

**Lengkapi dari pengalaman sebenarnya:**

- **Prompt asli dan hasil awal AI:** tempel cuplikan percakapan atau ringkasan keluaran AI yang benar-benar diterima.
- **Penyesuaian manual:** sebutkan fungsi/baris yang diubah sendiri dan alasan perubahan. Jika perbaikannya juga dibantu AI, nyatakan bantuan tersebut.

### Kasus 2 — Tombol formulir tertutup navigasi sistem Android

**Contoh rumusan prompt (rekonstruksi):**

```text
Saat LabInventory dijalankan pada Redmi 12 dengan Android 15, tombol
KIRIM pada formulir peminjaman tertutup area navigasi sistem. Periksa
penempatan SafeArea pada pembungkus aplikasi dan formulir. Usulkan
perbaikan untuk mode demo dan operasional, lalu jelaskan cara memeriksa
bahwa tombol tetap berada di area layar yang dapat disentuh.
```

**Kondisi awal yang terdokumentasi:** tombol KIRIM tertutup area navigasi sistem. Ketukan di area tersebut sempat memicu tombol Home Android. Kondisi ini belum dapat dinyatakan sebagai kesalahan keluaran AI tanpa bukti percakapan dan versi kode terkait.

**Perbaikan yang tercatat:** pembungkus aplikasi menggunakan `SafeArea` bagian bawah dan padding atas yang berulang pada demo dihilangkan. Perbaikan berlaku untuk entry point operasional dan demo.

**Hasil pemeriksaan terdokumentasi:** dua regression test memeriksa posisi tombol dengan inset sistem. Pemeriksaan pada perangkat fisik dilakukan menggunakan mode demo. Bukti sebelum/sesudah tersedia pada [laporan pengujian perangkat](docs/PENGUJIAN_DEVICE_2026-10-19.md).

**Lengkapi dari pengalaman sebenarnya:**

- **Prompt asli dan hasil awal AI:** cantumkan instruksi serta saran atau kode awal yang diterima.
- **Penyesuaian manual:** jelaskan perubahan yang benar-benar dikerjakan sendiri dan cara memeriksanya pada perangkat.

## 5. Evaluasi kritis terhadap bantuan AI

Kasus di atas menunjukkan bahwa kode perlu diperiksa melalui alur pengguna dan perangkat sasaran. Tampilan yang sudah terbuka belum menjamin datanya terbaru; formulir yang terlihat benar pada satu ukuran layar juga dapat bermasalah ketika bertemu area navigasi sistem.

Untuk LabInventory, pemeriksaan mencakup konsistensi stok, validasi formulir, pembatasan akses mahasiswa/laboran, penanganan kegagalan, dan kenyamanan antarmuka. Keputusan menerima atau mengubah saran AI perlu dijelaskan dengan alasan teknis dan bukti pengujian.

Hasil pengujian dalam dokumen ini merujuk laporan yang sudah ada, bukan pengujian ulang saat deklarasi disusun. Pengujian demo dalam memori juga perlu dibedakan dari pengujian autentikasi dan transaksi Supabase. Perkembangan aktivasi transaksi server tercatat dalam [laporan aktivasi](docs/AKTIVASI_TRANSAKSI_2026-10-19.md).

## 6. Pernyataan tanggung jawab

Setelah meninjau dan melengkapi deklarasi ini, saya bertanggung jawab atas kebenaran atribusi penggunaan AI, pemahaman alur program, serta keputusan implementasi yang saya kumpulkan. Saya akan menjelaskan batas kontribusi AI dan kontribusi saya sesuai proses pengerjaan sebenarnya.

**Nama:** Naila Fathia

**Tanggal persetujuan:** [isi setelah isi dokumen diperiksa]
