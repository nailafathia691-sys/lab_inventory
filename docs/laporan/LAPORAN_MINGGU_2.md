# 📝 LAPORAN PROGRES MINGGU II
## Implementasi Antarmuka UI/UX (Material Design 3), Bottom Navigation & Katalog

---

### 👤 Identitas Mahasiswa & Informasi Proyek
- **Nama Mahasiswa**: Naila Fathia  
- **NPM**: 2413025076  
- **Mata Kuliah**: Pemrograman Mobile (Mobile Programming)  
- **Program Studi**: S1 Pendidikan Teknologi Informasi (PTI)  
- **Fakultas / Universitas**: FKIP / Universitas Lampung (UNILA)  
- **Dosen Pengampu**: Ghea Chandra Surawan, M.Pd.  
- **Tahap Proyek**: Minggu II (Desain & Slicing Antarmuka)  
- **Status Capaian**: Selesai 100%  

---

## 1. Rincian Capaian & Aktivitas Minggu II
Pada minggu kedua, fokus pekerjaan adalah mewujudkan antarmuka visual mobile berbasis Material Design 3 dengan palet warna resmi Universitas Lampung:

1. **Design System & Palet Warna**:
   - Warna Primer: Unila Navy (`0xFF0F3B7A`).
   - Warna Sekunder / Aksen: Sapphire Blue (`0xFF1E60B8`).
   - Warna Background / Kartu: Slate Clean (`0xFFF8FAFC`).
2. **Animated Splash Screen**:
   - Membangun transisi intro halus (*Scale & Fade Transition*) menggunakan lambang resmi Universitas Lampung sebelum berpindah ke layar login.
3. **Pola Navigasi Mobile (Bottom Navigation Bar)**:
   - Menggunakan `IndexedStack` untuk mempertahankan state data (*preserve state*) saat pengguna berpindah tab.
   - **Tab Mahasiswa (4 Tab)**:
     1. 🏠 *Beranda*: Hero banner status buka lab, kartu status pinjaman aktif, panduan 4 langkah, dan tata tertib lab.
     2. 📦 *Inventaris*: Katalog alat lengkap, filter kategori (*Komputer, Elektronik, Aksesoris, Audio*), dan pencarian real-time.
     3. 🕒 *Peminjaman*: Riwayat pengajuan peminjaman pribadi dengan badge status (`PENDING`, `APPROVED`, `REJECTED`, `RETURNED`).
     4. 👤 *Profil*: Rincian identitas mahasiswa (Nama: Naila Fathia, NPM: 2413025076) dan tombol logout.
   - **Tab Laboran / Admin (5 Tab)**:
     1. 📊 *Dashboard*: Kartu metrik ringkasan (Total Alat, Antrean Pending) dan aksi cepat tambah barang/pengembalian.
     2. 📦 *Inventaris*: Monitoring stok alat dan Floating Action Button (FAB) pendaftaran alat baru.
     3. 📋 *Pengajuan*: Antrean verifikasi permohonan pinjam masuk.
     4. 📜 *Riwayat*: Audit log seluruh transaksi peminjaman lab.
     5. 👤 *Profil Admin*: Informasi akun pengelola laboratorium.
4. **Halaman Formulir Peminjaman Alat**:
   - Pemilihan jumlah unit, pemilih rentang tanggal pinjam & kembali (*DatePicker* kalender WIB), serta input alasan kebutuhan praktikum.
5. **Mode Demo Instan (Tanpa Akun)**:
   - Menambahkan opsi *In-Memory Demo Mode* pada halaman login agar dosen dan penguji dapat menguji antarmuka tanpa kendala jaringan.

---

## 2. Bukti Implementasi Antarmuka (Tangkapan Layar)

### 2.1 Halaman Login & Demo Mode
![Login UI](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/01-login.png)
*Tampilan autentikasi mobile dilengkapi opsi masuk instan Mode Demo.*

### 2.2 Katalog Alat & Pencarian
![Katalog Alat](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/10-catalog-search.png)
*Katalog alat dengan pencarian cepat nama barang dan chip filter per kategori.*

### 2.3 Rincian Alat & Lokasi Rak
![Detail Alat](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/08-laptop-detail.png)
*Informasi detail spesifikasi teknis, kondisi fisik, dan lokasi lemari/rak di laboratorium.*

### 2.4 Formulir Digital Pengajuan Peminjaman
![Formulir Pinjam](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/02-student-form.png)
*Formulir pengajuan peminjaman dengan DatePicker kalender dan input keperluan.*

---

## 3. Kendala dan Solusi
- **Kendala**: Tampilan formulir pengajuan tertutup oleh keyboard virtual Android saat pengguna mengetik keperluan praktikum, sehingga tombol submit berada di luar area pandang.
- **Solusi**: Membungkus seluruh layout form dengan `SafeArea` dan `SingleChildScrollView` (`docs/evidence/device/05-form-safe-area-fixed.png`), sehingga saat keyboard muncul, seluruh bidang form otomatis bergeser ke atas secara proporsional.

---

## 4. Rencana Kerja Minggu III
Menghubungkan antarmuka ke Cloud Backend Supabase (PostgreSQL 15), mengimplementasikan Supabase Auth, menerapkan Row Level Security (RLS), dan membuang seluruh data dummy lokal.
