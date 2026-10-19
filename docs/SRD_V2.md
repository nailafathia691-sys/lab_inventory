# 📦 SOFTWARE REQUIREMENT DOCUMENT (SRD) — VERSION 2.0
## Sistem Informasi Manajemen Inventaris & Peminjaman Alat Laboratorium Komputer Berbasis Mobile (LabInventory)

---

### 👤 Informasi Pengembang & Dokumen
- **Mata Kuliah**: Pemrograman Mobile (Mobile Programming)
- **Program Studi**: S1 Pendidikan Teknologi Informasi (PTI)
- **Jurusan / Fakultas**: Pendidikan MIPA / Fakultas Keguruan dan Ilmu Pendidikan
- **Perguruan Tinggi**: Universitas Lampung (UNILA)
- **Dosen Pengampu**: Ghea Chandra Surawan, M.Pd.
- **Disusun Oleh**: Naila Fathia (NPM: 2413025076)
- **Tanggal Pembaruan**: 19 Oktober 2026 (Revisi v2.0)
- **Status Implementasi**: 100% Terverifikasi — Terhubung Cloud Supabase Realtime & RLS

---

## 📜 Riwayat Revisi Dokumen

| Versi | Tanggal | Deskripsi Perubahan | Penulis |
| :--- | :--- | :--- | :--- |
| **1.0** | 03 Sept 2026 | Draf awal dokumen SRD: Pendahuluan, arsitektur dasar, rancangan use case, spesifikasi antarmuka awal, dan konsep awal database relasional. | Naila Fathia |
| **2.0** | 19 Okt 2026 | **Pembaruan Menyeluruh (v2.0)**: Migrasi arsitektur dari PHP/MySQL ke Flutter + Supabase (PostgreSQL 15, Supabase Auth, Row Level Security / RLS, dan RPC Transactional Function untuk integritas stok atomik), skema UUID, penghapusan dummy data, diagram use case & arsitektur, dan penyertaan hasil pengujian perangkat fisik Android. | Naila Fathia |

---

## 1. PENDAHULUAN

### 1.1 Latar Belakang
Laboratorium Komputer pada Program Studi Pendidikan Teknologi Informasi (PTI), FKIP Universitas Lampung, mengelola puluhan unit alat praktikum seperti laptop mahasiswa, proyektor LCD, switch jaringan, instrumen kabel, dan perangkat multimedia. Sebelumnya, proses pendataan barang dan permohonan peminjaman praktikum masih mengandalkan buku catatan fisik formulir kertas.

Metode manual tersebut memiliki kelemahan mendasar: tingginya risiko kehilangan formulir bukti, kesulitan melacak status ketersediaan alat secara instan, tidak adanya verifikasi kondisi saat pengembalian, serta antrean administratif yang memakan waktu. Melalui aplikasi mobile **LabInventory**, tata kelola inventaris ditransformasikan menjadi digital, transparan, dan real-time.

### 1.2 Gambaran Umum Sistem
LabInventory adalah aplikasi mobile berbasis Flutter yang terintegrasi langsung dengan database PostgreSQL di Supabase Cloud. Sistem ini melayani dua peran utama:
1. **Mahasiswa**: Mengecek katalog alat aktif, memeriksa ketersediaan stok live, mengajukan permohonan peminjaman praktikum dengan formulir digital, serta memantau status persetujuan dari mana saja.
2. **Laboran / Admin**: Menerima pengajuan masuk secara real-time, menyetujui atau menolak permohonan, mencatat mutasi penambahan alat baru, memproses pengembalian dengan inspeksi kondisi (Baik / Rusak), serta meninjau riwayat transaksi seluruh lab.

---

## 2. ARSITEKTUR DAN LINGKUNGAN OPERASIONAL

### 2.1 Arsitektur Sistem & Technology Stack
![Diagram Arsitektur](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/diagram_arsitektur_sistem.png)
*Gambar 2.1: Diagram Arsitektur Cloud, Gateway Keamanan, dan Database Supabase PostgreSQL 15.*

| Komponen | Spesifikasi & Teknologi | Fungsi & Tanggung Jawab |
| :--- | :--- | :--- |
| **Mobile Client** | Flutter 3.13+ / Dart 3+ | Antarmuka responsif Material Design 3, state management, offline-fallback demo. |
| **Autentikasi** | Supabase Auth (GoTrue) | Manajemen sesi aman berbasis token JWT, sanitasi pendaftaran, login role-based. |
| **Cloud Database** | PostgreSQL 15 (Supabase) | Penyimpanan data relasional terpusat, foreign keys, index performa. |
| **Otorisasi & Keamanan** | Row Level Security (RLS) | Aturan hak akses baris: Mahasiswa hanya membaca miliknya, Admin mengelola seluruh lab. |
| **Integritas Transaksi** | PostgreSQL RPC Functions | Stored procedure atomik (`approve_borrowing`, `return_borrowing`) bergaransi ACID. |
| **Aset Grafis & Media** | Vector Mipmaps & Cloud Media | Penyajian gambar foto alat dan logo resolusi tinggi tanpa distorsi layout. |

### 2.2 Mode Operasional
1. **Mode Live Operasional**: Terhubung ke Supabase Cloud via HTTPS TLS 1.3. Kegagalan koneksi ditangani secara transparan dengan timeout guard 4 detik tanpa memalsukan data operasional.
2. **Mode Demo Instan**: Disediakan tombol khusus *"Masuk Mode Demo"* untuk pengujian cepat visual dan penilaian tanpa ketergantungan jaringan internet.

---

## 3. SPESIFIKASI PENGGUNA DAN USE CASE

![Diagram Use Case](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/diagram_usecase_sistem.png)
*Gambar 3.1: Diagram Use Case & Pembagian Peran Aplikasi Mobile LabInventory.*

| Kode | Nama Use Case | Aktor | Deskripsi Alur |
| :--- | :--- | :--- | :--- |
| **UC-01** | Autentikasi & Validasi Peran | Mahasiswa, Laboran | Pengguna memasukkan email dan kata sandi. Supabase Auth memvalidasi token dan server memverifikasi role pada tabel `profiles`. |
| **UC-02** | Pencarian & Filter Katalog | Mahasiswa, Laboran | Melihat daftar alat aktif, filter per kategori (*Komputer, Elektronik, Aksesoris, Audio*), dan pencarian real-time. |
| **UC-03** | Pengajuan Peminjaman Alat | Mahasiswa | Mahasiswa memilih alat, menentukan jumlah unit, tanggal pinjam & kembali (DatePicker WIB), serta mengisi keperluan praktikum. |
| **UC-04** | Verifikasi & Persetujuan | Laboran | Laboran meninjau pengajuan pending. Jika disetujui, RPC memvalidasi stok dan mengalokasikan unit secara atomik. |
| **UC-05** | Pencatatan Pengembalian Alat | Laboran | Laboran menginspeksi fisik alat (Kondisi Baik atau Rusak), mencatat evaluasi, dan sistem mengupdate stok siap pakai / stok rusak. |
| **UC-06** | Pendaftaran Alat Baru | Laboran | Laboran menambahkan alat baru dengan kode inventaris otomatis (`INV-[KAT]-[RANDOM]`), kondisi, stok awal, dan lokasi rak. |
| **UC-07** | Audit Log & Riwayat Transaksi | Laboran, Mahasiswa | Mahasiswa melihat riwayat transaksi pribadinya, sedangkan Laboran melihat audit log seluruh transaksi laboratorium. |

---

## 4. KEBUTUHAN FUNGSIONAL & NON-FUNGSIONAL

### 4.1 Kebutuhan Fungsional (Functional Requirements)
- **FR-01 (Manajemen Sesi)**: Akses antarmuka dibatasi ketat berdasarkan role pengguna (`student` vs `admin`).
- **FR-02 (Monitoring Stok Live)**: Jumlah unit berkurang seketika saat status berubah menjadi `approved`.
- **FR-03 (Validasi Tanggal)**: Tanggal pinjam minimal hari ini (WIB) dan tenggat kembali tidak boleh sebelum tanggal pinjam.
- **FR-04 (Pencegahan Over-borrowing)**: Sistem menolak pengajuan melebihi jumlah stok yang tersedia.
- **FR-05 (Klasifikasi Kerusakan)**: Pengembalian dengan status rusak mengalihkan unit ke `stok_rusak` tanpa merusak status unit lain.
- **FR-06 (Format Kode Otomatis)**: Generator kode otomatis berformat `INV-[KAT]-[RANDOM]`.
- **FR-07 (Dashboard Metrik)**: Kartu metrik total inventaris dan total antrean pengajuan pada beranda laboran.

### 4.2 Kebutuhan Non-Fungsional (Non-Functional Requirements)
- **NFR-01 (Keamanan)**: Proteksi RLS PostgreSQL, hashing password Bcrypt, dan sanitasi payload.
- **NFR-02 (Integritas Transaksi)**: Transaksi ACID menggunakan stored procedure PostgreSQL dengan row locking (`FOR UPDATE`).
- **NFR-03 (Idempotensi)**: Setiap request tulis memiliki UUID unik untuk mencegah duplikasi saat sinyal tidak stabil.
- **NFR-04 (Responsivitas)**: Layout adaptif Android dengan `SafeArea` dan `SingleChildScrollView` (bebas bentrok keyboard).
- **NFR-05 (Performa)**: Waktu respons API rata-rata di bawah 500ms pada jaringan seluler 4G.

---

## 5. PERANCANGAN STRUKTUR DATABASE (POSTGRESQL)

### 5.1 Tabel: `profiles`
| Kolom | Tipe Data | Batasan | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY, REFERENCES auth.users(id) | ID akun pengguna Supabase Auth |
| `nama` | TEXT | NOT NULL | Nama lengkap pengguna |
| `npm` | TEXT | UNIQUE, NULLABLE | NPM (khusus mahasiswa) |
| `role` | TEXT | NOT NULL, CHECK (role IN ('student','admin')) | Hak akses pengguna |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Waktu pendaftaran |

### 5.2 Tabel: `items`
| Kolom | Tipe Data | Batasan | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | ID unik barang |
| `nama_barang` | TEXT | NOT NULL | Nama alat laboratorium |
| `kode_barang` | TEXT | NOT NULL, UNIQUE | Kode unik inventaris |
| `kategori` | TEXT | NOT NULL | Kategori alat |
| `kondisi` | TEXT | NOT NULL, DEFAULT 'Baik' | Kondisi fisik |
| `stok` | INTEGER | NOT NULL, CHECK (stok >= 0) | Unit siap pakai |
| `stok_rusak` | INTEGER | NOT NULL, DEFAULT 0 | Unit dalam perbaikan |
| `lokasi` | TEXT | NOT NULL | Lokasi lemari/rak |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Waktu pencatatan |

### 5.3 Tabel: `borrowings`
| Kolom | Tipe Data | Batasan | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | ID unik transaksi |
| `user_id` | UUID | NOT NULL, REFERENCES profiles(id) | ID mahasiswa peminjam |
| `item_id` | UUID | NOT NULL, REFERENCES items(id) | ID barang yang dipinjam |
| `nama_peminjam` | TEXT | NOT NULL | Nama peminjam |
| `nama_barang` | TEXT | NOT NULL | Nama barang |
| `jumlah` | INTEGER | NOT NULL, CHECK (jumlah > 0) | Jumlah unit |
| `tgl_pinjam` | TIMESTAMPTZ | NOT NULL | Waktu mulai |
| `tgl_kembali` | TIMESTAMPTZ | NOT NULL | Tenggat kembali |
| `keperluan` | TEXT | NOT NULL | Keperluan praktikum |
| `status` | TEXT | CHECK (status IN ('pending','approved','rejected','returned')) | Status transaksi |
| `catatan_kondisi` | TEXT | NULLABLE | Catatan inspeksi |
| `approved_at` | TIMESTAMPTZ | NULLABLE | Waktu persetujuan |
| `returned_at` | TIMESTAMPTZ | NULLABLE | Waktu pengembalian |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Waktu pengajuan |

---

## 6. DOKUMENTASI ANTARMUKA PENGGUNA (SCREENSHOT)

1. **Login & Autentikasi**: [docs/evidence/device/01-login.png](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/01-login.png)
2. **Katalog & Pencarian**: [docs/evidence/device/10-catalog-search.png](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/10-catalog-search.png)
3. **Detail Inventaris**: [docs/evidence/device/08-laptop-detail.png](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/08-laptop-detail.png)
4. **Formulir Pengajuan**: [docs/evidence/device/02-student-form.png](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/02-student-form.png)
5. **Dashboard Laboran**: [docs/evidence/device/03-admin-approved.png](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/03-admin-approved.png)
6. **Pengembalian Alat**: [docs/evidence/device/06-damaged-return.png](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/06-damaged-return.png)
7. **Pembaruan Stok Pasca Rusak**: [docs/evidence/device/07-stock-after-damage.png](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/07-stock-after-damage.png)
8. **Audit Log Riwayat Lab**: [docs/evidence/device/11-final-history.png](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/11-final-history.png)

---

## 7. KESIMPULAN
Dokumen SRD versi 2.0 ini mencerminkan 100% implementasi nyata aplikasi LabInventory. Penggunaan Flutter dan Supabase PostgreSQL berhasil menyediakan sistem inventaris yang andal, aman, dan siap digunakan pada Laboratorium Komputer PTI FKIP Universitas Lampung.
