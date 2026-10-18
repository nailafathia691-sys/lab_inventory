# 📦 LabInventory - Sistem Inventaris & Peminjaman Laboratorium Komputer PTI

Aplikasi mobile berbasis **Flutter** dan **Supabase Cloud Database (PostgreSQL)** yang dirancang khusus untuk memodernisasi manajemen inventaris serta alur peminjaman alat pada **Laboratorium Komputer Program Studi Pendidikan Teknologi Informasi (PTI), FKIP Universitas Lampung**.

---

## 👤 Informasi Mahasiswa / Pengembang

- **Nama**: Naila Fathia  
- **NPM**: 2413025076  
- **Program Studi**: S1 Pendidikan Teknologi Informasi (PTI)  
- **Jurusan**: Pendidikan Matematika dan Ilmu Pengetahuan Alam (PMIPA)  
- **Fakultas**: Keguruan dan Ilmu Pendidikan (FKIP)  
- **Universitas**: Universitas Lampung (UNILA)  
- **Mata Kuliah**: Pemrograman Mobile (Mobile Programming)  
- **Dosen Pengampu**: Tim Dosen PTI FKIP Unila  

---

## 📱 Gambaran Umum Aplikasi

**LabInventory** mentransformasi proses pencatatan inventaris lab komputer yang sebelumnya manual (menggunakan buku formulir fisik) menjadi sistem digital terpusat yang transparan, terstruktur, dan dapat diakses langsung melalui smartphone secara real-time.

Aplikasi ini melayani dua peran pengguna (*multi-role system*):
1. **Mahasiswa**: Mengecek ketersediaan stok barang secara real-time dari database cloud, melihat spesifikasi alat, mengajukan permohonan peminjaman praktikum, memantau alur & status persetujuan, serta melihat tenggat waktu pengembalian.
2. **Laboran / Admin**: Memverifikasi pengajuan peminjaman (*approve/reject*), mengelola stok dan kondisi fisik inventaris, memproses pengembalian alat (*return*), serta meninjau riwayat transaksi seluruh laboratorium.

> [!NOTE]
> Seluruh data inventaris barang (`items`) dan permohonan peminjaman (`borrowings`) telah **100% terhubung secara live & real-time ke Supabase PostgreSQL Cloud Database** tanpa menggunakan data dummy/tiruan.

---

## ✨ Fitur-Fitur Utama Aplikasi

### 🎓 1. Alur & Antarmuka Mahasiswa (Student Flow)

- **Animated Splash Screen**: Animasi intro logo resmi Universitas Lampung dengan transisi halus (*Scale & Fade Transition*).
- **Autentikasi Fleksibel**:
  - Login via Supabase Auth (Email & Password).
  - **Mode Demo Instan (Tanpa Akun)** untuk pengujian dan penilaian praktis tanpa kendala koneksi akun.
- **Mobile Bottom Navigation Bar (4 Tab)**:
  1. 🏠 **Beranda (Dashboard Mahasiswa)**:
     - *Hero Banner* informatif dengan status operasional lab (*"Lab Buka"*).
     - *Status Card* peminjaman aktif & tenggat pengembalian real-time dari database.
     - Pintasan cepat (*Katalog*, *Ajukan*, *Riwayat*, *Tata Tertib*).
     - Filter kategori cepat (*Komputer*, *Proyektor*, *Kabel*, *Audio*).
     - **Panduan Visual Alur Peminjaman (4 Langkah Interaktif)**:
       1. Pilih Alat di Katalog
       2. Isi Formulir Pengajuan
       3. Verifikasi & Ambil di Lab (Wajib Bawa KTM Fisik)
       4. Pengembalian & Cek Kondisi Fisik
     - Informasi jam operasional (Senin–Jumat, 08:00–16:00 WIB) & lokasi (Gedung FKIP Lt. 2).
     - Dialog interaktif tata tertib laboratorium & modal pengumuman lab.
  2. 📦 **Inventaris (Katalog Alat Real-time)**:
     - Daftar seluruh aset lab dari tabel Supabase `items`.
     - Badge kondisi fisik (*Sangat Baik*, *Baik*, *Perlu Perbaikan*), lokasi rak, dan stok live.
     - Fitur pencarian (*search bar*) nama barang dan filter per kategori (*Elektronik, Komputer, Aksesoris*).
     - **Detail Barang & Formulir Peminjaman**: Pemilihan jumlah unit, pemilih rentang tanggal pinjam & kembali (*DatePicker*), serta input keperluan akademik.
  3. 🕒 **Peminjaman (Peminjaman Saya)**:
     - Jejak riwayat pengajuan peminjaman mahasiswa langsung dari tabel Supabase `borrowings`.
     - Status badge informatif (*PENDING*, *APPROVED*, *REJECTED*, *RETURNED*).
     - Empty state bersih jika belum ada riwayat transaksi.
  4. 👤 **Profil (Identitas Mahasiswa)**:
     - Rincian identitas mahasiswa (Nama: Naila Fathia, NPM: 2413025076, Prodi: PTI FKIP Unila).
     - Informasi hak akses, kontak pengembang, dan tombol *Logout*.

---

### 🛠️ 2. Alur & Antarmuka Laboran / Admin (Administrator Flow)

- **Mobile Bottom Navigation Bar (5 Tab)**:
  1. 📊 **Dashboard Laboran**:
     - Kartu metrik ringkasan real-time (*Total Barang* dan *Pengajuan Pending* dari Supabase).
     - Tombol aksi cepat: **Tambah Barang** dan **Pengembalian Alat**.
     - Daftar antrean pengajuan pending dengan tombol aksi langsung **Setujui** (*Approve*) atau **Tolak** (*Reject*).
  2. 📦 **Inventaris & Manajemen Alat**:
     - Monitoring stok seluruh aset lab secara real-time.
     - Tombol Tambah Barang Baru (*Floating Action Button*).
  3. 📋 **Pengajuan (Approval Screen)**:
     - Verifikasi peminjaman masuk dari mahasiswa.
     - Aksi *Setujui* atau *Tolak* yang langsung memperbarui status baris di tabel `borrowings` Supabase.
  4. 📜 **Riwayat (Riwayat Transaksi Lab)**:
     - Audit log lengkap transaksi peminjaman seluruh laboratorium secara transparan.
  5. 👤 **Profil Laboran**:
     - Pengelolaan informasi akun admin/laboran Lab Komputer PTI.
- **Fitur Tambahan Laboran**:
  - ➕ **Tambah Inventaris Baru**: Form pendaftaran alat dengan pembuatan kode barang otomatis (*Auto-generate code: `INV-[KAT]-[RANDOM]`*), nama, kategori, kondisi, stok, dan lokasi rak.
  - 🔄 **Proses Pengembalian Barang (Return Item)**: Pemilihan peminjaman aktif dari database, inspeksi kondisi fisik (*Normal / Baik* atau *Rusak*), input catatan laboran, dan konfirmasi pengembalian barang.

---

## 🏗️ Arsitektur & Teknologi

| Komponen | Spesifikasi & Teknologi |
| :--- | :--- |
| **Framework Utama** | [Flutter](https://flutter.dev/) (Channel Stable, Dart SDK ^3.13) |
| **Desain Antarmuka** | Material Design 3, Unila Navy & Sapphire Palette (`0xFF0F3B7A`, `0xFF1E60B8`), Responsive Layout |
| **Pola Navigasi** | Mobile Bottom Navigation Bar + `IndexedStack` (Preserve State antar-tab) |
| **Backend & Cloud Database** | [Supabase](https://supabase.com/) (PostgreSQL Database & Realtime API) |
| **Autentikasi** | Supabase Auth (Email & Password) + Mode Demo Instan |
| **Ikon & Aset Grafis** | Custom Launcher Icon Android Adaptive Mipmaps & Lambang Unila |

---

## 🗄️ Skema Database (Supabase PostgreSQL)

### 1. Tabel `items` (Daftar Inventaris Laboratorium)
| Kolom | Tipe Data | Deskripsi |
| :--- | :--- | :--- |
| `id` | `uuid` / `text` | Primary Key unik barang |
| `nama_barang` | `text` | Nama peralatan lab (cth: *Laptop Lenovo, Proyektor Epson*) |
| `kode_barang` | `text` | Kode unik inventaris (cth: `INV-CMP-0008`, `INV-ELK-0012`) |
| `kategori` | `text` | Kategori alat (*Komputer, Elektronik, Aksesoris*) |
| `kondisi` | `text` | Kondisi fisik (*Sangat Baik, Baik, Perlu Perbaikan*) |
| `stok` | `integer` | Jumlah stok unit yang tersedia |
| `lokasi` | `text` | Posisi lemari / rak di ruang laboratorium |
| `created_at` | `timestamptz` | Waktu pencatatan aset |

### 2. Tabel `borrowings` (Pengajuan & Transaksi Peminjaman)
| Kolom | Tipe Data | Deskripsi |
| :--- | :--- | :--- |
| `id` | `uuid` / `text` | Primary Key unik transaksi peminjaman |
| `user_id` | `uuid` | ID akun peminjam |
| `item_id` | `uuid` / `text` | Foreign Key ke baris barang di tabel `items` |
| `nama_peminjam` | `text` | Nama lengkap peminjam |
| `nama_barang` | `text` | Nama alat yang dipinjam |
| `jumlah` | `integer` | Jumlah unit yang diajukan |
| `tgl_pinjam` | `timestamptz` | Tanggal mulai peminjaman |
| `tgl_kembali` | `timestamptz` | Tanggal batas pengembalian |
| `keperluan` | `text` | Keperluan praktikum / kegiatan akademik |
| `status` | `text` | Status peminjaman (`pending`, `approved`, `rejected`, `returned`) |
| `catatan_kondisi` | `text` | Catatan hasil inspeksi kondisi saat barang dikembalikan |
| `created_at` | `timestamptz` | Waktu pengajuan dibuat |

---

## 🚀 Panduan Menjalankan Aplikasi

### 1. Prasyarat Sistem
- **Flutter SDK** (versi 3.13.0 atau yang lebih baru)
- **Dart SDK** (versi 3.0.0 atau yang lebih baru)
- **Android Studio** / **VS Code** dengan ekstensi Flutter & Dart
- **Perangkat Android** (USB Debugging aktif) atau **Android Emulator**

### 2. Langkah-Langkah Instalasi

1. **Clone repository ini**:
   ```bash
   git clone https://github.com/nailafathia691-sys/lab_inventory.git
   cd lab_inventory
   ```

2. **Unduh seluruh package dependensi**:
   ```bash
   flutter pub get
   ```

3. **Verifikasi kepatuhan kode (Code Analysis)**:
   ```bash
   flutter analyze --no-fatal-infos
   ```

4. **Jalankan aplikasi di perangkat / emulator**:
   ```bash
   flutter run
   ```

### 3. 🔐 Akun Uji Coba / Testing Credentials

Tersedia akun pengujian aktif yang terdaftar langsung di **Supabase Authentication** untuk memudahkan proses demo dan penilaian aplikasi:

| Role / Peran | Email | Password | Keterangan |
| :--- | :--- | :--- | :--- |
| 🛡️ **Admin / Laboran** | `admin@lab.com` | `admin123` | Akses penuh dashboard laboran, verifikasi pengajuan, input barang & pengembalian |
| 🎓 **Mahasiswa / Siswa** | `tes@1.com` | `123456` | Akses katalog inventaris, pengajuan pinjam alat, status & riwayat peminjaman |

> [!TIP]
> Kredensial di atas dapat dimasukkan langsung pada formulir login sesuai perannya. Selain itu, tersedia pula tombol **"Masuk Mode Demo (Tanpa Akun)"** untuk penilaian cepat tanpa perlu mengetik akun.

### 4. Petunjuk Pengujian Aplikasi (Uji Alur Lengkap)
1. **Login sebagai Mahasiswa / Siswa**:
   - Ketik email `tes@1.com` dan password `123456`, pilih role **Mahasiswa**, lalu tekan tombol **MASUK**.
   - Buka tab **Inventaris**, pilih salah satu barang (contoh: *Proyektor Epson* atau *Laptop Lenovo*), lalu tekan tombol **"Pinjam Alat"**.
   - Masukkan jumlah unit, pilih tanggal pinjam dan tanggal kembali, isi keperluan praktikum, lalu tekan **"Kirim Pengajuan"**.
   - Pengajuan akan tersimpan langsung di database cloud Supabase dengan status `pending`.

2. **Login sebagai Admin / Laboran**:
   - Logout dari profil mahasiswa, kemudian masuk dengan email `admin@lab.com` dan password `admin123`, pilih role **Admin / Laboran**, lalu tekan **MASUK**.
   - Di **Dashboard Laboran** atau tab **Pengajuan**, permohonan pinjam dari mahasiswa tadi akan langsung muncul secara real-time.
   - Tekan tombol **"Setujui"** -> status peminjaman di Supabase langsung berubah menjadi `approved`.

3. **Proses Pengembalian Barang**:
   - Masih pada akun Laboran di halaman **Dashboard**, tekan tombol aksi cepat **"Pengembalian"**.
   - Pilih barang yang sedang dipinjam dari daftar peminjaman aktif, tentukan kondisi fisik (*Normal / Baik* atau *Rusak*), masukkan catatan laboran, lalu tekan **"KONFIRMASI KEMBALI"**.
   - Status peminjaman otomatis terupdate menjadi `returned` di database Supabase dan tercatat pada riwayat transaksi lab.

---

## 📂 Struktur Direktori Proyek

```text
lab_inventory/
├── android/                  # Konfigurasi native Android & Launcher Mipmaps
│   └── app/src/main/
│       ├── AndroidManifest.xml   # Label "LabInventory" & Internet Permission
│       └── res/mipmap-*/         # Ikon aplikasi resmi LabInventory
├── assets/images/            # Logo & grafis visual
│   ├── app_icon.png          # Ikon launcher aplikasi
│   └── lab_inventory_logo.png# Lambang utama aplikasi
├── lib/
│   └── main.dart             # Kode utama (Model, Service Supabase, Screens, Nav)
├── pubspec.yaml              # Dependensi pustaka & pendaftaran aset
└── README.md                 # Dokumentasi resmi proyek
```

---

## 📄 Lisensi & Hak Cipta

Proyek aplikasi ini dikembangkan oleh **Naila Fathia (NPM: 2413025076)** untuk memenuhi tugas ujian / tugas besar mata kuliah **Pemrograman Mobile**, Program Studi Pendidikan Teknologi Informasi, Jurusan Pendidikan Matematika dan Ilmu Pengetahuan Alam, Fakultas Keguruan dan Ilmu Pendidikan, **Universitas Lampung**.
