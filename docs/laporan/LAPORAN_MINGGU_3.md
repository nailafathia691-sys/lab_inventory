# 📝 LAPORAN PROGRES MINGGU III
## Integrasi Cloud Database Supabase, Autentikasi Role-Based & Security (RLS)

---

### 👤 Identitas Mahasiswa & Informasi Proyek
- **Nama Mahasiswa**: Naila Fathia  
- **NPM**: 2413025076  
- **Mata Kuliah**: Pemrograman Mobile (Mobile Programming)  
- **Program Studi**: S1 Pendidikan Teknologi Informasi (PTI)  
- **Fakultas / Universitas**: FKIP / Universitas Lampung (UNILA)  
- **Dosen Pengampu**: Ghea Chandra Surawan, M.Pd.  
- **Tahap Proyek**: Minggu III (Backend Integration & Security)  
- **Status Capaian**: Selesai 100%  

---

## 1. Deskripsi Pekerjaan Minggu III
Pada Minggu III, aplikasi LabInventory beralih dari prototype visual menjadi aplikasi terkoneksi cloud penuh dengan mengintegrasikan Supabase Cloud Platform (PostgreSQL 15), Supabase Auth, dan otorisasi ketat Row Level Security (RLS).

---

## 2. Arsitektur Cloud & Keamanan Sistem
Arsitektur keamanan ditegakkan di level database engine menggunakan PostgreSQL Row Level Security (RLS). Diagram di bawah mengilustrasikan konektivitas antara klien Flutter dengan lapisan otorisasi dan database Supabase:

![Diagram Arsitektur](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/diagram_arsitektur_sistem.png)
*Gambar 3.1: Diagram Arsitektur Cloud, Gateway Keamanan, dan Database Supabase PostgreSQL 15.*

---

## 3. Rincian Capaian Integrasi Backend
1. **Konektivitas Supabase**: Mengaktifkan package `supabase_flutter: ^2.5.0` dan menghubungkan project ke URL endpoint HTTPS resmi.
2. **Eliminasi Dummy Data**: Menghapus seluruh mock data lokal (dummy data); data barang dan peminjaman murni membaca baris tabel Supabase secara real-time.
3. **Skema Relasional Database**: Menerapkan tabel relasional `profiles`, `items`, dan `borrowings` berbasis Primary Key UUID v4.
4. **Row Level Security (RLS)**: Mahasiswa hanya dapat membaca/menulis transaksinya sendiri (`auth.uid() = user_id`), sedangkan Laboran memiliki akses penuh supervisi.
5. **Autentikasi Token JWT**: Menangani status session login secara otomatis melalui `SessionController` (login, auto-restore token, dan secure logout).
6. **Stabilitas Jaringan**: Menambahkan timeout guard 4 detik dengan blok `try-finally` untuk menjamin dialog loading tidak berputar terus-menerus.

---

## 4. Kredensial Akun Pengujian Resmi Cloud

| Role / Peran | Email Akun | Kata Sandi | Hak Akses & Fitur |
| :--- | :--- | :--- | :--- |
| **Admin / Laboran** | `admin@lab.com` | `admin123` | Akses penuh Dashboard Laboran, Approval Pengajuan, Input Alat Baru, & Pengembalian Alat. |
| **Mahasiswa / Siswa** | `tes@1.com` | `123456` | Akses Katalog Inventaris, Pengajuan Pinjam Alat, Cek Status Peminjaman Saya. |

---

## 5. Bukti Implementasi Cloud & Autentikasi (Tangkapan Layar)

### 5.1 Dashboard Laboran Real-time
![Dashboard Laboran](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/03-admin-approved.png)
*Gambar 3.2: Dashboard laboran live menampilkan metrik ringkasan stok dan daftar antrean pengajuan pending.*

### 5.2 Status Peminjaman Mahasiswa Tersinkronisasi
![Status Pending](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/04-student-pending.png)
*Gambar 3.3: Tampilan riwayat transaksi mahasiswa langsung membaca status 'PENDING' dari tabel borrowings Supabase.*

### 5.3 Form Pendaftaran Inventaris Baru oleh Laboran
![Tambah Barang](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/09-admin-created-item.png)
*Gambar 3.4: Form input penambahan aset lab baru dengan kode otomatis INV-[KAT]-[RANDOM].*

---

## 6. Kendala dan Solusi
- **Kendala 1**: Terjadi error `foreign key violation` saat pengajuan pinjam dikirim karena ID barang pada form masih membaca data contoh integer, sedangkan database Supabase mengharapkan UUID v4.  
  **Solusi**: Memperbarui mapping model data Dart agar secara otomatis mengambil UUID valid dari tabel `items` Supabase sebelum form disubmit.
- **Kendala 2**: Terjadi infinite loading spinner saat koneksi internet lambat pada emulator Android.  
  **Solusi**: Mengimplementasikan `Future.timeout(const Duration(seconds: 4))` dan memastikan dialog spinner ditutup pada blok `finally`.

---

## 7. Rencana Kerja Minggu IV
Mengimplementasikan fungsi transaksi stok atomik (PostgreSQL RPC), alur pengembalian alat dengan verifikasi kondisi fisik (Baik vs Rusak), pengujian perangkat fisik (Physical Device Testing), dan finalisasi laporan.
