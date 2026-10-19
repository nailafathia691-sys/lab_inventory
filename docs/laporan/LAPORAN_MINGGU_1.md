# 📝 LAPORAN PROGRES MINGGU I
## Inisiasi Proyek, Analisis Kebutuhan, Wireframe & Setup Flutter Environment

---

### 👤 Identitas Mahasiswa & Informasi Proyek
- **Nama Mahasiswa**: Naila Fathia  
- **NPM**: 2413025076  
- **Mata Kuliah**: Pemrograman Mobile (Mobile Programming)  
- **Program Studi**: S1 Pendidikan Teknologi Informasi (PTI)  
- **Fakultas / Universitas**: FKIP / Universitas Lampung (UNILA)  
- **Dosen Pengampu**: Ghea Chandra Surawan, M.Pd.  
- **Tahap Proyek**: Minggu I (Inisiasi, Analisis Masalah, & Use Case)  
- **Status Capaian**: Selesai 100%  

---

## 1. Latar Belakang & Identifikasi Permasalahan Lapangan
Laboratorium Komputer pada Program Studi Pendidikan Teknologi Informasi (PTI) FKIP Unila memiliki puluhan aset penting (Laptop Lenovo, Proyektor LCD Epson, Switch Hub, instrumen kabel, dan speaker) yang digunakan intensif untuk perkuliahan praktikum. 

Selama ini, pengelolaan peminjaman masih menggunakan formulir kertas manual yang menimbulkan berbagai kendala:
1. **Risiko Kehilangan Data**: Lembar permohonan fisik mudah terselip, basah, atau robek saat proses praktikum.
2. **Ketiadaan Visibilitas Stok**: Mahasiswa tidak mengetahui ketersediaan alat tanpa mendatangi laboratorium secara fisik.
3. **Ketidakpastian Waktu Pengembalian**: Laboran kesulitan melacak mahasiswa yang terlambat mengembalikan alat praktikum.
4. **Inspeksi Fisik Nihil**: Tidak ada pencatatan resmi mengenai kondisi fisik alat saat dipinjam versus saat dikembalikan.

Oleh karena itu, diinisiasi proyek aplikasi mobile **LabInventory** sebagai solusi digital terintegrasi.

---

## 2. Perancangan Use Case & Alur Kerja Sistem
Sistem membagi hak akses ke dalam 2 aktor utama: Mahasiswa (peminjam) dan Laboran (administrator). Diagram di bawah ini mengilustrasikan pembagian use case dan batasan sistem aplikasi:

![Diagram Use Case](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/diagram_usecase_sistem.png)
*Gambar 1.1: Diagram Use Case & Pembagian Peran Aplikasi Mobile LabInventory.*

Alur peminjaman dirancang menjadi 4 langkah terstruktur:
1. **Langkah 1 (Pilih Alat)**: Mahasiswa mengecek ketersediaan unit dan spesifikasi pada katalog digital.
2. **Langkah 2 (Isi Formulir)**: Mahasiswa menentukan jumlah unit, memilih rentang tanggal kalender (DatePicker WIB), dan mengisi tujuan praktikum.
3. **Langkah 3 (Verifikasi & Ambil)**: Laboran menyetujui pengajuan di sistem dan mahasiswa mengambil alat dengan verifikasi KTM fisik di laboratorium.
4. **Langkah 4 (Pengembalian)**: Laboran menginspeksi kondisi fisik alat (Baik atau Rusak) dan mengonfirmasi pengembalian di sistem.

---

## 3. Setup Environment Flutter & Aset Aplikasi
Pada minggu ini telah diselesaikan instalasi serta konfigurasi Flutter SDK (^3.13) dan Dart SDK (^3.0). Aplikasi telah dikonfigurasi dengan launcher icon Android kustom berlogo resmi LabInventory Unila:

![App Launcher Icon](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/assets/images/app_icon.png)
*Gambar 1.2: Ikon Launcher Resmi Aplikasi LabInventory pada Perangkat Android.*

---

## 4. Struktur Direktori Proyek Hasil Inisiasi
```text
lab_inventory/
├── android/app/src/main/
│   ├── AndroidManifest.xml   # Izin jaringan (INTERNET, ACCESS_NETWORK_STATE) & label
│   └── res/mipmap-*/         # Icon launcher aplikasi
├── assets/images/            # Logo Unila & LabInventory
├── lib/
│   └── main.dart             # Entry point awal Flutter
├── pubspec.yaml              # Konfigurasi dependensi dasar
└── README.md                 # Dokumentasi pengantar proyek
```

---

## 5. Kendala dan Solusi Teknis
- **Kendala**: Muncul peringatan deprecation Gradle pada Android Studio saat inisiasi build awal.
- **Solusi**: Memperbarui konfigurasi `gradle-wrapper.properties` ke versi 8.0+ dan menetapkan `compileSdkVersion 34` serta `targetSdkVersion 34` pada `build.gradle` sehingga kompilasi berjalan lancar tanpa error.

---

## 6. Kesimpulan & Rencana Minggu II
Fase inisiasi, analisis kebutuhan, perancangan use case, dan setup environment pada Minggu I telah berhasil diselesaikan dengan baik (100%). Pada Minggu II, pekerjaan dilanjutkan ke implementasi antarmuka pengguna (UI/UX) Material Design 3, Bottom Navigation Bar (4 tab Mahasiswa dan 5 tab Laboran), Animated Splash Screen, serta katalog inventaris real-time.
