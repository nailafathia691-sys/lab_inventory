# 📦 LabInventory - Sistem Inventaris & Peminjaman Laboratorium Komputer PTI

Aplikasi mobile berbasis Flutter dan Supabase yang dirancang khusus untuk memodernisasi manajemen inventaris dan alur peminjaman alat pada **Laboratorium Komputer Program Studi Pendidikan Teknologi Informasi (PTI), FKIP Universitas Lampung**.

---

## 👤 Informasi Mahasiswa / Pengembang

- **Nama**: Naila Fathia  
- **NPM**: 2413025076  
- **Program Studi**: S1 Pendidikan Teknologi Informasi (PTI)  
- **Fakultas**: Keguruan dan Ilmu Pendidikan (FKIP)  
- **Universitas**: Universitas Lampung (UNILA)  
- **Mata Kuliah**: Pemrograman Mobile (Mobile Programming)  

---

## 📱 Gambaran Umum Aplikasi

**LabInventory** mentransformasi proses pencatatan inventaris lab komputer yang sebelumnya manual (menggunakan formulir kertas / buku fisik) menjadi sistem digital terpusat yang transparan, terstruktur, dan mudah diakses langsung melalui smartphone.

Aplikasi ini melayani dua peran utama (*roles*):
1. **Mahasiswa**: Mengecek ketersediaan stok barang secara real-time, melihat spesifikasi alat, mengajukan permohonan pinjam praktikum, memantau alur & status persetujuan, serta melihat tenggat waktu pengembalian.
2. **Laboran / Admin**: Memverifikasi pengajuan peminjaman (*approve/reject*), mengelola stok dan kondisi fisik inventaris, mencatat pengembalian alat, serta meninjau riwayat transaksi seluruh laboratorium.

---

## ✨ Fitur-Fitur Utama

### 🎓 1. Fitur Mahasiswa (Student Flow)
- **Animated Splash Screen**: Animasi intro logo resmi Universitas Lampung & transisi halus.
- **Autentikasi Fleksibel**:
  - Login via Supabase Auth.
  - **Mode Demo (Tanpa Akun)** untuk presentasi & penilaian cepat tanpa hambatan jaringan.
- **Mobile Bottom Navigation Bar (4 Tab)**:
  - 🏠 **Beranda**:
    - *Hero Banner* informatif dengan status operasional lab (*"Lab Buka"*).
    - Status peminjaman aktif & tenggat pengembalian real-time.
    - Pintasan cepat (*Katalog*, *Ajukan*, *Riwayat*, *Tata Tertib*).
    - Filter kategori cepat (*Komputer*, *Proyektor*, *Kabel*, *Audio*).
    - **Panduan Visual Alur Peminjaman (4 Langkah)**:
      1. Pilih Alat di Katalog
      2. Isi Formulir Pengajuan
      3. Verifikasi & Ambil di Lab (Bawa KTM Fisik)
      4. Pengembalian & Cek Kondisi
    - Informasi jam operasional (Senin–Jumat, 08:00–16:00 WIB) & lokasi (Gedung FKIP Lt. 2).
    - Dialog interaktif tata tertib dan pengumuman lab.
  - 📦 **Katalog Inventaris**: Daftar seluruh aset lab lengkap dengan badge kondisi, lokasi rak, stok real-time, dan fitur pencarian/filter.
  - 📝 **Formulir Peminjaman**: Pemilihan jumlah unit, pemilih tanggal pinjam/kembali (*DatePicker*), serta input keperluan akademik.
  - 🕒 **Peminjaman Saya**: Jejak riwayat pengajuan dengan status (*Pending*, *Approved*, *Rejected*, *Returned*).
  - 👤 **Profil Pengguna**: Rincian identitas mahasiswa (Nama, NPM, Prodi, Hak Akses) & fitur *Logout*.

---

### 🛠️ 2. Fitur Laboran / Admin (Administrator Flow)
- **Mobile Bottom Navigation Bar (5 Tab)**:
  - 📊 **Dashboard Laboran**: Ringkasan statistik total alat, unit dipinjam, pengajuan pending, dan kondisi aset lab.
  - 📦 **Katalog & Manajemen Alat**: Monitoring stok, lokasi lemari/rak, serta tombol tambah barang baru (*Floating Action Button*).
  - ➕ **Tambah Inventaris Baru**: Pembuatan kode barang otomatis (*Auto-generate code: `INV-[KAT]-[RANDOM]`*), input nama, kategori, kondisi, stok, dan lokasi penyimpanan.
  - 📋 **Approval Pengajuan**: Verifikasi peminjaman masuk dengan opsi *Setujui* atau *Tolak* yang langsung terhubung ke database.
  - 📜 **Riwayat Transaksi**: Audit log lengkap keluar-masuk inventaris lab.
  - 👤 **Profil Laboran**: Pengelolaan akun admin laboratorium.

---

## 🏗️ Arsitektur & Teknologi

| Komponen | Teknologi |
| :--- | :--- |
| **Framework Utama** | [Flutter](https://flutter.dev/) (Channel Stable, Dart SDK ^3.13) |
| **Desain Antarmuka** | Material Design 3, Curated Unila Navy Palette (`0xFF0F3B7A`), Responsive Layout |
| **Navigasi** | Bottom Navigation Bar + IndexedStack (Preserve State) |
| **Backend & Database** | [Supabase](https://supabase.com/) (PostgreSQL Database & Realtime API) |
| **Autentikasi** | Supabase Auth (Email & Password) + Fallback Demo Mode |
| **Aset Grafis** | Custom Logo & Adaptive Launcher Icon Android Mipmaps |

---

## 🗄️ Struktur Database (Supabase PostgreSQL)

### Tabel `items` (Daftar Inventaris Alat)
| Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `uuid` / `text` | Primary Key |
| `nama_barang` | `text` | Nama alat laboratorium |
| `kode_barang` | `text` | Kode unik inventaris (cth: `INV-KOM-4120`) |
| `kategori` | `text` | Komputer, Elektronik, Aksesoris, Audio |
| `kondisi` | `text` | Sangat Baik, Baik, Rusak Ringan |
| `stok` | `integer` | Jumlah unit yang tersedia |
| `lokasi` | `text` | Posisi lemari / rak di ruang lab |
| `created_at` | `timestamptz` | Waktu pencatatan aset |

### Tabel `borrowings` (Pengajuan & Transaksi Peminjaman)
| Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `uuid` / `text` | Primary Key |
| `user_id` | `uuid` | ID mahasiswa peminjam |
| `item_id` | `text` | Referensi ke barang yang dipinjam |
| `nama_peminjam` | `text` | Nama lengkap peminjam |
| `nama_barang` | `text` | Nama barang yang dipinjam |
| `jumlah` | `integer` | Jumlah unit yang diajukan |
| `tgl_pinjam` | `date` / `timestamptz` | Tanggal mulai peminjaman |
| `tgl_kembali` | `date` / `timestamptz` | Batas tanggal pengembalian |
| `keperluan` | `text` | Alasan / peruntukan peminjaman |
| `status` | `text` | `pending`, `approved`, `rejected`, `returned` |
| `catatan_kondisi` | `text` | Catatan pengecekan saat kembali |
| `created_at` | `timestamptz` | Waktu permohonan dibuat |

---

## 🚀 Panduan Menjalankan Aplikasi

### 1. Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.13 ke atas)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Emulator Android atau Device fisik (USB Debugging aktif)

### 2. Langkah Instalasi

1. **Clone repository ini**:
   ```bash
   git clone https://github.com/nailafathia691-sys/lab_inventory.git
   cd lab_inventory
   ```

2. **Unduh dependensi pub**:
   ```bash
   flutter pub get
   ```

3. **Verifikasi tidak ada error sintaks**:
   ```bash
   flutter analyze --no-fatal-infos
   ```

4. **Jalankan aplikasi di emulator / device**:
   ```bash
   flutter run
   ```

---

## 📂 Struktur Folder Proyek

```text
lab_inventory/
├── android/                  # Konfigurasi native Android & Launcher Mipmaps
│   └── app/src/main/
│       ├── AndroidManifest.xml   # Label "LabInventory" & Internet Permission
│       └── res/mipmap-*/         # Ikon aplikasi resmi LabInventory
├── assets/images/            # Logo & grafis visual
│   ├── app_icon.png          # Ikon launcher square
│   └── lab_inventory_logo.png# Lambang utama aplikasi
├── lib/
│   └── main.dart             # Kode utama (Service, Screens, BottomNav, Dashboard)
├── pubspec.yaml              # Dependensi pustaka & pendaftaran aset
└── README.md                 # Dokumentasi proyek
```

---

## 📄 Lisensi & Hak Cipta

Proyek ini dikembangkan oleh **Naila Fathia (NPM: 2413025076)** untuk memenuhi tugas mata kuliah **Pemrograman Mobile**, Program Studi Pendidikan Teknologi Informasi, Jurusan Pendidikan MIPA, Fakultas Keguruan dan Ilmu Pendidikan, **Universitas Lampung**.
