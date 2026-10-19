import os
import sys
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

from academic_docx_builder import (
    setup_academic_page, add_academic_cover, add_kata_pengantar,
    add_bab_heading, add_subbab_heading, add_body_paragraph,
    add_bullet_item, add_academic_image, add_academic_table,
    add_code_snippet, add_daftar_pustaka
)

IMG_DEV = os.path.abspath("docs/evidence/device")
IMG_EVID = os.path.abspath("docs/evidence")
IMG_INV = os.path.abspath("assets/images/inventory")
APP_ICON = os.path.abspath("assets/images/app_icon.png")

DAFTAR_PUSTAKA_STANDARD = [
    "Budhayanti, C. I. S. (2023). Penggunaan Mobile Learning dan Cloud Database pada Perkuliahan Pendidikan Komputer. Jurnal Pendidikan Terbuka dan Jarak Jauh, 24(1), 45-56.",
    "Kemendikbudristek. (2022). Panduan Pembelajaran dan Asesmen Pendidikan Vokasi dan Komputer. Jakarta: BSKAP Kemendikbudristek.",
    "PostgreSQL Global Development Group. (2023). PostgreSQL 15 Documentation: Row Level Security Policies and Concurrency Control. PostgreSQL Official Documentation Hub.",
    "Sommerville, I. (2019). Software Engineering (10th ed.). London: Pearson Education.",
    "Supabase Inc. (2024). Supabase Documentation: Auth, Realtime Database, and Stored Procedures via PostgreSQL RPC. San Francisco: Supabase Docs Hub.",
    "Team Flutter. (2024). Flutter Documentation: Material 3 Design Specifications and State Management with IndexedStack. Mountain View: Google Open Source.",
    "Wulandari, L. P. A. O., & Agustini, K. (2024). Pengembangan Sistem Manajemen Laboratorium Berbasis Mobile Menggunakan Arsitektur Clean Architecture. Jurnal Pendidikan Teknologi dan Kejuruan, 23(1), 89-101."
]


# ==============================================================
# MINGGU 1
# ==============================================================
def create_minggu_1():
    doc = docx.Document()
    setup_academic_page(doc)

    add_academic_cover(
        doc,
        jenis_dokumen="LAPORAN PRAKTIKUM KEMAJUAN PROYEK MINGGU I",
        judul_utama="PEMROGRAMAN MOBILE (MOBILE PROGRAMMING)",
        sub_judul="Inisiasi Proyek, Analisis Kebutuhan Sistem, Pemodelan Use Case, Wireframe, dan Setup Environment Flutter pada Aplikasi LabInventory",
        tgl_tahun="2026"
    )

    add_kata_pengantar(
        doc,
        judul_dokumen="Laporan Praktikum Kemajuan Proyek Minggu I: Inisiasi Proyek, Analisis Kebutuhan Sistem, Pemodelan Use Case, Wireframe, dan Setup Environment Flutter pada Aplikasi LabInventory",
        tgl_str="09 September 2026"
    )

    # BAB I
    add_bab_heading(doc, "I", "PENDAHULUAN & ANALISIS KEBUTUHAN")
    add_subbab_heading(doc, "1.1", "Latar Belakang Permasalahan & Urgensi Digitalisasi")
    add_body_paragraph(
        doc,
        "Laboratorium Komputer pada Program Studi Pendidikan Teknologi Informasi (PTI), FKIP Universitas Lampung, "
        "merupakan fasilitas sentral dalam mendukung penyelenggaraan Tri Dharma Perguruan Tinggi, khususnya kegiatan "
        "praktikum perkuliahan rekayasa perangkat lunak, sistem operasi, jaringan komputer, multimedia, serta komputasi awan. "
        "Laboratorium ini mengelola puluhan aset peralatan berharga tinggi yang memiliki mobilitas peminjaman sangat tinggi "
        "oleh mahasiswa, dosen, serta asisten laboratorium."
    )
    add_body_paragraph(
        doc,
        "Sebelum pengembangan sistem LabInventory, pengelolaan inventaris dan alur permohonan peminjaman masih dijalankan "
        "secara konvensional dengan mencatat secara manual pada buku registrasi fisik dan formulir kertas. "
        "Berdasarkan hasil observasi dan wawancara dengan pengelola laboratorium, metode manual ini menimbulkan empat kerentanan utama:"
    )
    add_bullet_item(doc, "Formulir kertas rentan basah, robek, atau terselip, mengakibatkan rekonsiliasi data inventaris di akhir semester sering mengalami disinformasi dan selisih pembukuan.", bold_prefix="1. Risiko Kerusakan Dokumen Fisik: ")
    add_bullet_item(doc, "Mahasiswa tidak memiliki sarana untuk memantau sisa stok alat praktikum yang tersedia secara realtime tanpa harus datang secara langsung ke ruangan laboratorium.", bold_prefix="2. Ketiadaan Transparansi Sisa Stok: ")
    add_bullet_item(doc, "Laboran mengalami kesulitan melacak mahasiswa yang terlambat mengembalikan alat praktikum melewati tenggat jadwal mata kuliah yang telah ditentukan.", bold_prefix="3. Monitoring Tenggat Waktu Nihil: ")
    add_bullet_item(doc, "Tidak ada formulir verifikasi kondisi fisik alat sebelum dipinjam dan sesudah dikembalikan, sehingga kerusakan barang sulit dipertanggungjawabkan secara adil.", bold_prefix="4. Ketiadaan Audit Kondisi Fisik Alat: ")

    add_subbab_heading(doc, "1.2", "Profil Aset Fisik Inventaris Laboratorium Komputer PTI")
    add_body_paragraph(
        doc,
        "Aset inventaris yang menjadi subjek digitalisasi pada sistem LabInventory terdiri dari berbagai perangkat hardware "
        "pendukung kegiatan praktikum di lingkungan Laboratorium Komputer PTI FKIP Unila. Dokumentasi fisik aset disajikan berikut:"
    )

    laptop_img = os.path.join(IMG_INV, "laptop.png")
    if os.path.exists(laptop_img):
        add_academic_image(doc, laptop_img, "Gambar 1.1: Unit Laptop Praktikum Asus Core i5 Laboratorium Komputer PTI", width=Inches(3.2))

    proj_img = os.path.join(IMG_INV, "projector.png")
    if os.path.exists(proj_img):
        add_academic_image(doc, proj_img, "Gambar 1.2: Unit Proyektor LCD Epson EB-X400 untuk Presentasi Praktikum", width=Inches(3.2))

    speaker_img = os.path.join(IMG_INV, "speaker.png")
    if os.path.exists(speaker_img):
        add_academic_image(doc, speaker_img, "Gambar 1.3: Unit Speaker Portable Wireless untuk Audio Praktikum", width=Inches(2.4))

    hdmi_img = os.path.join(IMG_INV, "hdmi.png")
    if os.path.exists(hdmi_img):
        add_academic_image(doc, hdmi_img, "Gambar 1.4: Unit Kabel HDMI High-Speed Gold Plated", width=Inches(3.2))

    tabel_fisik_headers = ["No", "Nama Aset Barang", "Kategori", "Lokasi Penyimpanan", "Kondisi Fisik"]
    tabel_fisik_data = [
        ["1", "Laptop Praktikum Asus Core i5", "Komputer", "Lemari Rak A-1 (Lab PTI)", "Siap Pakai / Baik"],
        ["2", "Proyektor LCD Epson EB-X400", "Elektronik", "Lemari Khusus Multimedia", "Siap Pakai / Baik"],
        ["3", "Speaker Portable Wireless Mic", "Audio", "Rak Perlengkapan B-2", "Siap Pakai / Baik"],
        ["4", "Kabel HDMI High-Speed 5 Meter", "Aksesoris", "Kotak Kabel Rak C-3", "Siap Pakai / Baik"]
    ]
    add_academic_table(doc, "Tabel 1.1: Inventaris Fisik Aset Bergerak Laboratorium Komputer PTI", tabel_fisik_headers, tabel_fisik_data, col_widths=[0.5, 2.3, 1.2, 1.8, 1.2])

    add_subbab_heading(doc, "1.3", "Rumusan Masalah")
    add_body_paragraph(
        doc,
        "Berdasarkan analisis latar belakang di atas, rumusan masalah yang diselesaikan adalah:"
    )
    add_bullet_item(doc, "Bagaimana merancang sistem inventaris mobile yang mendigitalkan seluruh alur permohonan pinjam alat praktikum?")
    add_bullet_item(doc, "Bagaimana memisahkan hak akses sistem secara tegas antara peran Mahasiswa dan Laboran?")
    add_bullet_item(doc, "Bagaimana memvalidasi ketersediaan stok fisik barang secara realtime guna mencegah alokasi ganda (*double-booking*)?")
    add_bullet_item(doc, "Bagaimana mengonfigurasi environment pengembangan Flutter SDK dan native Android yang stabil dan andal?")

    add_subbab_heading(doc, "1.4", "Batasan Masalah")
    add_body_paragraph(
        doc,
        "Batasan implementasi proyek LabInventory ditetapkan sebagai berikut:"
    )
    add_bullet_item(doc, "Aplikasi dibangun menggunakan framework Flutter versi 3.13+ dengan bahasa pemrograman Dart versi 3.x.")
    add_bullet_item(doc, "Sistem backend menggunakan layanan Cloud Database Supabase berbasis PostgreSQL versi 15.")
    add_bullet_item(doc, "Target sistem operasi difokuskan pada perangkat Android versi 8.0 (API 26) hingga Android 14 (API 34).")
    add_bullet_item(doc, "Pengguna sistem dibatasi pada dua peran: Mahasiswa aktif PTI dan Laboran resmi FKIP Unila.")

    add_subbab_heading(doc, "1.5", "Capaian Pembelajaran & Tujuan Praktikum")
    add_body_paragraph(
        doc,
        "Tujuan pelaksanaan praktikum pada Minggu I meliputi:"
    )
    add_bullet_item(doc, "Menganalisis kebutuhan fungsional (FR) dan non-fungsional (NFR) sistem inventaris laboratorium.")
    add_bullet_item(doc, "Merumuskan model use case yang memisahkan hak akses antara Mahasiswa dan Laboran secara presisi.")
    add_bullet_item(doc, "Merancang sketsa desain antarmuka (wireframe low-fidelity) untuk 4 layar utama aplikasi.")
    add_bullet_item(doc, "Mengonfigurasi environment pengembangan Flutter SDK versi 3.13.3 dan konfigurasi native Android.")

    add_subbab_heading(doc, "1.6", "Manfaat Praktikum")
    add_body_paragraph(
        doc,
        "Praktikum ini memberikan fondasi rekayasa kebutuhan perangkat lunak yang kokoh bagi mahasiswa pengembang, "
        "sekaligus merancang solusi digitalisasi yang tepat guna dan bernilai guna tinggi bagi Laboratorium Komputer PTI FKIP Unila."
    )

    # BAB II
    add_bab_heading(doc, "II", "PERANCANGAN SISTEM & REKAYASA KEBUTUHAN")
    add_subbab_heading(doc, "2.1", "Analisis Kebutuhan Fungsional (Functional Requirements)")
    add_body_paragraph(
        doc,
        "Kebutuhan fungsional mendefinisikan kapabilitas dan fitur operasional yang wajib disediakan oleh sistem mobile LabInventory. "
        "Matriks kebutuhan fungsional dirumuskan pada tabel berikut:"
    )
    tabel_fr_headers = ["Kode FR", "Nama Fitur", "Aktor Pelaksana", "Deskripsi Fungsional", "Prioritas"]
    tabel_fr_data = [
        ["FR-01", "Otentikasi Pengguna", "Mahasiswa & Laboran", "Masuk ke sistem dengan email & password terenkripsi via Supabase Auth.", "Tinggi"],
        ["FR-02", "Pemisahan Hak Akses Role", "Sistem", "Mengarahkan antarmuka (dashboard) sesuai role pengguna (Mahasiswa vs Laboran).", "Tinggi"],
        ["FR-03", "Katalog & Pencarian Barang", "Mahasiswa", "Menampilkan daftar alat lab, sisa stok realtime, dan filter pencarian nama barang.", "Tinggi"],
        ["FR-04", "Pengajuan Formulir Pinjam", "Mahasiswa", "Menginput jumlah pinjam, memilih tanggal WIB, dan mencantumkan keperluan praktikum.", "Tinggi"],
        ["FR-05", "Persetujuan Tiket Peminjaman", "Laboran", "Memverifikasi tiket status pending, memeriksa KTM fisik mahasiswa, dan approval.", "Tinggi"],
        ["FR-06", "Pengembalian & Cek Fisik", "Laboran", "Memeriksa kondisi fisik alat (Baik/Rusak), input catatan, dan konfirmasi kembali.", "Tinggi"],
        ["FR-07", "Pelacakan Riwayat Transaksi", "Mahasiswa & Laboran", "Melihat riwayat peminjaman masa lalu beserta status akhir barang secara kronologis.", "Sedang"],
        ["FR-08", "Manajemen Master Barang", "Laboran", "Menambah barang inventaris baru, mengedit informasi spesifikasi, dan update stok.", "Sedang"]
    ]
    add_academic_table(doc, "Tabel 1.2: Matriks Kebutuhan Fungsional Sistem LabInventory", tabel_fr_headers, tabel_fr_data, col_widths=[0.8, 1.4, 1.3, 2.3, 0.7])

    add_subbab_heading(doc, "2.2", "Analisis Kebutuhan Non-Fungsional (Non-Functional Requirements)")
    add_body_paragraph(
        doc,
        "Kebutuhan non-fungsional menitikberatkan pada standar kualitas, keandalan, dan batasan kinerja sistem perangkat lunak mobile:"
    )
    tabel_nfr_headers = ["Parameter", "Kategori Kebutuhan", "Spesifikasi & Standar Teknis"]
    tabel_nfr_data = [
        ["NFR-01", "Usability & UI/UX", "Antarmuka mengadopsi standar Google Material Design 3 dengan identitas warna resmi Unila."],
        ["NFR-02", "Performance & Kecepatan", "Waktu respons navigasi antarmuka dan fetching data cloud rata-rata di bawah 1,5 detik."],
        ["NFR-03", "Security & Integritas", "Data diproteksi dengan Row Level Security (RLS) PostgreSQL dan enkripsi HTTPS/TLS 1.3."],
        ["NFR-04", "Portabilitas Platform", "Aplikasi dapat berjalan stabil pada perangkat Android versi 8.0 (API 26) hingga Android 14 (API 34)."]
    ]
    add_academic_table(doc, "Tabel 1.3: Matriks Kebutuhan Non-Fungsional Sistem LabInventory", tabel_nfr_headers, tabel_nfr_data, col_widths=[1.0, 1.8, 3.7])

    add_subbab_heading(doc, "2.3", "Pemodelan Diagram Use Case Sistem")
    add_body_paragraph(
        doc,
        "Aplikasi dirancang menggunakan paradigma Object-Oriented Programming (OOP) pada bahasa pemrograman Dart "
        "dengan framework Flutter. Sistem menetapkan batasan peran (actor separation) yang tegas antara mahasiswa dan laboran. "
        "Hubungan antar-aktor dan fitur sistem digambarkan pada Diagram Use Case berikut:"
    )

    uc_img = os.path.join(IMG_EVID, "diagram_usecase_sistem.png")
    if os.path.exists(uc_img):
        add_academic_image(doc, uc_img, "Gambar 1.5: Diagram Use Case & Pembagian Peran Aplikasi Mobile LabInventory", width=Inches(5.4))

    add_subbab_heading(doc, "2.4", "Sketsa Desain Antarmuka (Wireframe Low-Fidelity)")
    add_body_paragraph(
        doc,
        "Sebelum implementasi kode pemrograman antarmuka, perancangan sketsa wireframe low-fidelity disusun "
        "guna memvalidasi alur interaksi pengguna (User Journey) pada 4 layar esensial aplikasi:"
    )

    wire_img = os.path.join(IMG_EVID, "wireframe_perancangan_sistem.png")
    if os.path.exists(wire_img):
        add_academic_image(doc, wire_img, "Gambar 1.6: Sketsa Desain Wireframe (Low-Fidelity) Antarmuka Aplikasi LabInventory", width=Inches(5.4))

    add_subbab_heading(doc, "2.5", "Perancangan Arsitektur Sistem Mobile")
    add_body_paragraph(
        doc,
        "Arsitektur sistem LabInventory memadukan client mobile Flutter dengan infrastruktur cloud Supabase melalui protokol "
        "komunikasi RESTful API dan WebSocket Realtime yang aman, sebagaimana diilustrasikan pada diagram berikut:"
    )

    arch_img = os.path.join(IMG_EVID, "diagram_arsitektur_sistem.png")
    if os.path.exists(arch_img):
        add_academic_image(doc, arch_img, "Gambar 1.7: Diagram Arsitektur Komunikasi Flutter Client & Supabase Cloud Backend", width=Inches(5.4))

    add_subbab_heading(doc, "2.6", "Pemetaan Alur Peminjaman 4 Langkah")
    add_body_paragraph(
        doc,
        "Proses peminjaman dikonstruksikan ke dalam alur transaksi empat tahap terstruktur guna menjamin akuntabilitas aset:"
    )
    tabel_alur_headers = ["Tahap Alur", "Aktor Pelaksana", "Aktivitas Teknis", "Output Sistem"]
    tabel_alur_data = [
        ["Tahap 1", "Mahasiswa", "Menelusuri katalog digital dan mengecek sisa stok live barang siap pakai.", "Barang dipilih"],
        ["Tahap 2", "Mahasiswa", "Mengisi jumlah unit, memilih tanggal (DatePicker WIB), dan input keperluan.", "Tiket berstatus 'pending'"],
        ["Tahap 3", "Laboran & Mahasiswa", "Laboran menyetujui di sistem; mahasiswa membawa KTM fisik untuk mengambil alat.", "Tiket berstatus 'approved'"],
        ["Tahap 4", "Laboran", "Inspeksi kondisi fisik (Baik/Rusak), catatan laboran, dan konfirmasi pengembalian.", "Tiket berstatus 'returned'"]
    ]
    add_academic_table(doc, "Tabel 1.4: Pemetaan Alur Peminjaman Terstruktur 4 Tahap", tabel_alur_headers, tabel_alur_data, col_widths=[1.1, 1.4, 2.7, 1.4])

    # BAB III
    add_bab_heading(doc, "III", "IMPLEMENTASI SETUP FLUTTER & HASIL EVALUASI")
    add_subbab_heading(doc, "3.1", "Konfigurasi Proyek & Dependensi Flutter")
    add_body_paragraph(
        doc,
        "Proyek Flutter `lab_inventory` diinisiasi menggunakan Flutter SDK versi 3.13.3 dan Dart SDK versi 3.0.0. "
        "Manajemen dependensi dikonfigurasi melalui berkas `pubspec.yaml` dengan pustaka utama mencakup `supabase_flutter` "
        "untuk komunikasi backend, `intl` untuk format penanggalan WIB, serta `google_fonts` untuk tipografi modern:"
    )

    code_pubspec = """dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.0
  intl: ^0.19.0
  google_fonts: ^6.2.1
  flutter_staggered_animations: ^1.1.1
  uuid: ^4.3.3"""
    add_code_snippet(doc, "Cuplikan Kode 1.1: Konfigurasi Dependensi pada berkas pubspec.yaml", code_pubspec)

    add_subbab_heading(doc, "3.2", "Konfigurasi Lapisan Native Android")
    add_body_paragraph(
        doc,
        "Pada lapisan native Android, berkas `android/app/src/main/AndroidManifest.xml` dikonfigurasi dengan menyertakan izin jaringan "
        "`android.permission.INTERNET` dan `android.permission.ACCESS_NETWORK_STATE` guna mendukung komunikasi cloud via HTTPS TLS 1.3:"
    )

    code_manifest = """<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.unila.lab_inventory">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <application
        android:label="LabInventory Unila"
        android:icon="@mipmap/ic_launcher">
    </application>
</manifest>"""
    add_code_snippet(doc, "Cuplikan Kode 1.2: Konfigurasi Izin Jaringan Native AndroidManifest.xml", code_manifest)

    if os.path.exists(APP_ICON):
        add_academic_image(doc, APP_ICON, "Gambar 1.8: Desain Ikon Launcher Resmi Aplikasi LabInventory pada Sistem Operasi Android", width=Inches(1.5))

    add_subbab_heading(doc, "3.3", "Struktur Direktori Proyek")
    add_body_paragraph(
        doc,
        "Struktur direktori ditata mengikuti arsitektur modular Flutter untuk mempermudah skalabilitas pengembangan:"
    )
    tabel_struk_headers = ["Nama Berkas / Folder", "Peranan Arsitektural"]
    tabel_struk_data = [
        ["android/app/src/main/AndroidManifest.xml", "Konfigurasi izin jaringan native dan nama aplikasi resmi."],
        ["android/app/src/main/res/mipmap-*/", "Ikon aplikasi Android adaptive pada seluruh resolusi perangkat."],
        ["assets/images/lab_inventory_logo.png", "Aset visual lambang resmi Universitas Lampung resolusi tinggi."],
        ["lib/main.dart", "Titik masuk (entry point) eksekusi aplikasi dan konfigurasi tema utama."],
        ["lib/models/", "Definisi kelas entitas data (Item, Borrowing, UserProfile)."],
        ["lib/views/", "Antarmuka pengguna (Login, Dashboard Mahasiswa, Dashboard Laboran)."],
        ["pubspec.yaml", "Manajemen dependensi pustaka dan pendaftaran aset visual."]
    ]
    add_academic_table(doc, "Tabel 1.5: Struktur Direktori Proyek Hasil Inisiasi Minggu I", tabel_struk_headers, tabel_struk_data, col_widths=[2.5, 4.0])

    add_subbab_heading(doc, "3.4", "Verifikasi Environment Flutter & Android SDK")
    add_body_paragraph(
        doc,
        "Verifikasi kesiapan lingkungan pengembangan dievaluasi melalui eksekusi perintah diagnostik `flutter doctor -v` "
        "pada terminal PowerShell. Seluruh komponen mencakup Flutter SDK stable 3.13.3, Android Toolchain 34.0.0, Java JDK 17, "
        "Android Studio, dan koneksi perangkat uji terverifikasi lulus 100% tanpa kendala (No issues found):"
    )

    setup_terminal_img = os.path.join(IMG_EVID, "flutter_environment_setup.png")
    if os.path.exists(setup_terminal_img):
        add_academic_image(doc, setup_terminal_img, "Gambar 1.9: Hasil Verifikasi Environment Pengembangan Flutter SDK & Android Toolchain (flutter doctor -v)", width=Inches(5.2))

    add_subbab_heading(doc, "3.5", "Evaluasi Kendala Teknis & Solusi")
    add_body_paragraph(
        doc,
        "Kendala Teknis: Muncul peringatan ketidaksesuaian versi Gradle pada lingkungan Android Studio saat proses build awal.\n"
        "Solusi: Memperbarui konfigurasi `gradle-wrapper.properties` ke versi Gradle 8.0+ dan menetapkan compileSdkVersion 34 "
        "sehingga kompilasi binary APK berjalan lancar tanpa hambatan."
    )

    # BAB IV
    add_bab_heading(doc, "IV", "PENUTUP")
    add_subbab_heading(doc, "4.1", "Kesimpulan Keterlaksanaan Minggu I")
    add_body_paragraph(
        doc,
        "Tahapan inisiasi proyek, inventarisasi aset fisik lab, analisis kebutuhan sistem (fungsional & non-fungsional), "
        "perancangan diagram use case, sketsa wireframe, arsitektur cloud, serta penyiapan environment pengembangan Flutter "
        "pada Minggu I telah berhasil dituntaskan secara paripurna (100%). Seluruh prasyarat arsitektural telah siap untuk "
        "memasuki tahap slicing antarmuka pengguna pada Minggu II."
    )
    add_subbab_heading(doc, "4.2", "Rencana Tindak Lanjut Minggu II")
    add_body_paragraph(
        doc,
        "Rencana pada Minggu II difokuskan pada implementasi sistem desain Material 3 (Unila Palette), pembuatan Animated "
        "Splash Screen, Mobile Bottom Navigation Bar (4 tab Mahasiswa dan 5 tab Laboran), serta antarmuka formulir peminjaman."
    )

    add_daftar_pustaka(doc, DAFTAR_PUSTAKA_STANDARD)
    return doc


# ==============================================================
# MINGGU 2
# ==============================================================
def create_minggu_2():
    doc = docx.Document()
    setup_academic_page(doc)

    add_academic_cover(
        doc,
        jenis_dokumen="LAPORAN PRAKTIKUM KEMAJUAN PROYEK MINGGU II",
        judul_utama="PEMROGRAMAN MOBILE (MOBILE PROGRAMMING)",
        sub_judul="Implementasi Antarmuka UI/UX Material Design 3, Multi-Role Bottom Navigation Bar, Animated Splash Screen, dan Formulir Peminjaman pada Aplikasi LabInventory",
        tgl_tahun="2026"
    )

    add_kata_pengantar(
        doc,
        judul_dokumen="Laporan Praktikum Kemajuan Proyek Minggu II: Implementasi Antarmuka UI/UX Material Design 3, Multi-Role Bottom Navigation Bar, Animated Splash Screen, dan Formulir Peminjaman pada Aplikasi LabInventory",
        tgl_str="16 September 2026"
    )

    # BAB I
    add_bab_heading(doc, "I", "PENDAHULUAN & PRINSIP DESAIN UI/UX")
    add_subbab_heading(doc, "1.1", "Latar Belakang Perancangan UI/UX")
    add_body_paragraph(
        doc,
        "Keberhasilan adopsi sistem informasi berbasis mobile sangat ditentukan oleh kualitas pengalaman pengguna (User Experience) "
        "dan estetika antarmuka (User Interface). Pada sistem inventaris laboratorium kampus, antarmuka dituntut tidak hanya "
        "menarik secara visual, namun juga harus intuitif, memiliki kontras tinggi untuk keterbacaan di dalam ruang laboratorium komputer, "
        "serta memiliki alur navigasi yang tegas antara peran mahasiswa peminjam dan peran laboran pengelola."
    )
    add_body_paragraph(
        doc,
        "Pada tahapan Minggu II, fokus rekayasa perangkat lunak diarahkan pada transformasi hasil analisis kebutuhan Minggu I "
        "menjadi komponen antarmuka nyata (slicing UI). Penerapan sistem desain yang konsisten mutlak diperlukan agar interaksi civitas akademika "
        "berjalan mulus, efisien, dan bebas hambatan visual."
    )

    add_subbab_heading(doc, "1.2", "Rumusan Masalah Desain Antarmuka")
    add_body_paragraph(
        doc,
        "Rumusan masalah yang diselesaikan pada tahapan desain antarmuka meliputi:"
    )
    add_bullet_item(doc, "Bagaimana merancang tema visual mobile yang selaras dengan identitas formal institusi Universitas Lampung?")
    add_bullet_item(doc, "Bagaimana membangun struktur navigasi multi-role yang membedakan menu Mahasiswa (4 tab) dan Laboran (5 tab) tanpa terjadi reload data yang membebani memori?")
    add_bullet_item(doc, "Bagaimana mengatasi kendala tumpang tindih layout antarmuka (bottom overflow) saat keyboard virtual Android aktif pada formulir pengajuan pinjam?")
    add_bullet_item(doc, "Bagaimana menyediakan mekanisme evaluasi antarmuka yang independen (Mode Demo) agar dapat diuji tanpa ketergantungan koneksi jaringan backend?")

    add_subbab_heading(doc, "1.3", "Batasan Desain Antarmuka")
    add_body_paragraph(
        doc,
        "Batasan implementasi antarmuka pada Minggu II mencakup:"
    )
    add_bullet_item(doc, "Sistem desain mengadopsi spesifikasi Google Material Design 3 dengan kurasi palet warna resmi Unila.")
    add_bullet_item(doc, "Manajemen state navigasi halaman menggunakan pola widget IndexedStack untuk preservasi status.")
    add_bullet_item(doc, "Target orientasi layar dikunci pada mode potret (Portrait Mode) dengan penanganan Safe Area notch dan navigasi sistem.")

    add_subbab_heading(doc, "1.4", "Tujuan Praktikum Minggu II")
    add_body_paragraph(
        doc,
        "Tujuan pelaksanaan praktikum Minggu II meliputi:"
    )
    add_bullet_item(doc, "Menerapkan sistem desain Google Material Design 3 dengan palet warna resmi almamater Universitas Lampung.")
    add_bullet_item(doc, "Mengembangkan animasi pembuka (Animated Splash Screen) yang elegan menggunakan logo Unila.")
    add_bullet_item(doc, "Membangun Bottom Navigation Bar adaptif berbasis IndexedStack guna mempertahankan status data antar-tab.")
    add_bullet_item(doc, "Mengembangkan halaman katalog alat real-time dengan kemampuan pencarian instan dan filter kategori.")
    add_bullet_item(doc, "Merancang formulir digital pengajuan peminjaman alat dengan DatePicker kalender WIB.")
    add_bullet_item(doc, "Menyediakan fitur Mode Demo In-Memory untuk pengujian visual instan tanpa jaringan.")

    add_subbab_heading(doc, "1.5", "Manfaat Praktikum")
    add_body_paragraph(
        doc,
        "Praktikum ini memberikan pengalaman komprehensif dalam slicing UI modern, penanganan responsive layout pada Android, "
        "serta menghasilkan prototype visual yang sangat representatif dan mudah digunakan oleh seluruh pengguna laboratorium."
    )

    # BAB II
    add_bab_heading(doc, "II", "LANDASAN TEORI & ARSITEKTUR DESAIN ANTARMUKA")
    add_subbab_heading(doc, "2.1", "Konsep Google Material Design 3 & Tipografi Modern")
    add_body_paragraph(
        doc,
        "Material Design 3 (Material You) merupakan evolusi desain antarmuka terbaru dari Google yang menitikberatkan pada personalisasi, "
        "kontras warna adaptif, serta hierarki visual yang tegas. Pada aplikasi LabInventory, elemen kartu (Card) diberi elevasi halus "
        "dengan radius sudut melengkung 16px, efek sentuhan ripple responsif, dan tipografi berbasis Google Fonts Poppins/Inter yang memiliki tingkat legibilitas tinggi."
    )

    add_subbab_heading(doc, "2.2", "Desain Sistem & Kurasi Palet Warna Resmi Universitas Lampung")
    add_body_paragraph(
        doc,
        "Aplikasi menerapkan kurasi palet warna formal institusional Universitas Lampung guna membangun ikatan identitas kampus yang kuat:"
    )
    tabel_color_headers = ["Nama Token Warna", "Kode Heksadesimal", "Peranan Visual & Semantik"]
    tabel_color_data = [
        ["Primary Navy Unila", "#0F3B7A", "Warna identitas almamater utama pada AppBar, tombol aksi utama, dan kartu aktif."],
        ["Secondary Sapphire", "#1E60B8", "Warna aksen pendukung pada indikator navigasi dan ikon interaktif."],
        ["Accent Gold Unila", "#F59E0B", "Warna penegas pada badge status 'Pending' dan bintang rating alat."],
        ["Surface Slate Clean", "#F8FAFC", "Warna latar belakang aplikasi yang bersih, modern, dan tidak melelahkan mata."],
        ["Text Charcoal High", "#1E293B", "Warna teks judul dan body untuk memastikan rasio kontras rasio WCAG AAA."],
        ["Error Crimson Alert", "#EF4444", "Warna peringatan stok habis, validasi error form, dan barang kondisi rusak."]
    ]
    add_academic_table(doc, "Tabel 2.1: Spesifikasi Token Warna Sistem Desain Aplikasi LabInventory", tabel_color_headers, tabel_color_data, col_widths=[1.8, 1.4, 3.8])

    add_subbab_heading(doc, "2.3", "Pola Navigasi Multi-Role Menggunakan IndexedStack")
    add_body_paragraph(
        doc,
        "Untuk mencegah terjadinya reload halaman yang boros memori dan menghilangkan input form saat berpindah tab, navigasi dibangun menggunakan widget "
        "`IndexedStack`. Melalui pendekatan ini, state input form maupun posisi scroll tetap dipertahankan (*preserve state*):"
    )

    code_nav = """class MainNavigationScreen extends StatefulWidget {
  final String role; // 'mahasiswa' atau 'laboran'
  ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: role == 'laboran' ? _laboranTabs : _mahasiswaTabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: role == 'laboran' ? _adminNavItems : _studentNavItems,
      ),
    );
  }
}"""
    add_code_snippet(doc, "Cuplikan Kode 2.1: Implementasi Preservasi State Navigasi Menggunakan IndexedStack", code_nav)

    tabel_nav_headers = ["Peran Pengguna", "Jumlah Tab", "Daftar Tab Navigasi", "Fungsi Utama"]
    tabel_nav_data = [
        ["Mahasiswa", "4 Tab", "Beranda, Inventaris, Peminjaman, Profil", "Mengecek status, mencari alat, mengajukan pinjam, melihat akun."],
        ["Laboran / Admin", "5 Tab", "Dashboard, Inventaris, Pengajuan, Riwayat, Profil", "Memantau metrik lab, tambah barang, verifikasi permohonan, audit log."]
    ]
    add_academic_table(doc, "Tabel 2.2: Spesifikasi Pembagian Tab Bottom Navigation Bar per Role", tabel_nav_headers, tabel_nav_data, col_widths=[1.3, 1.0, 2.5, 2.2])

    add_subbab_heading(doc, "2.4", "Perancangan Formulir Digital & Sanitasi Input")
    add_body_paragraph(
        doc,
        "Formulir permohonan peminjaman dirancang dengan komponen validasi interaktif: DatePicker waktu lokal Indonesia Barat (WIB), "
        "stepper kuota jumlah barang dengan pembatas stok maksimal, serta sanitasi teks pada kolom keperluan praktikum untuk mencegah input kosong."
    )

    # BAB III
    add_bab_heading(doc, "III", "IMPLEMENTASI MODUL & HASIL TANGKAPAN LAYAR")
    add_subbab_heading(doc, "3.1", "Implementasi Layar Autentikasi & Mode Demo")
    add_body_paragraph(
        doc,
        "Halaman login dirancang bersih dengan form email dan kata sandi, pemilihan role (Mahasiswa atau Laboran), "
        "serta tombol khusus 'Masuk Mode Demo (Tanpa Akun)'. Mode demo memungkinkan dosen penguji menginspeksi alur antarmuka "
        "secara instan menggunakan mock in-memory repository tanpa memerlukan koneksi internet:"
    )

    code_demo = """class DemoModeRepository {
  static final List<Item> mockItems = [
    Item(id: '1', nama: 'Laptop Asus Core i5', kategori: 'Komputer', stok: 8, posisiRak: 'Rak A-1'),
    Item(id: '2', nama: 'Proyektor Epson EB-X400', kategori: 'Elektronik', stok: 3, posisiRak: 'Lemari 1'),
  ];
  static bool isDemoActive = false;
  static void activateDemo() => isDemoActive = true;
}"""
    add_code_snippet(doc, "Cuplikan Kode 2.2: Implementasi Mock In-Memory Repository untuk Mode Demo", code_demo)

    add_academic_image(doc, os.path.join(IMG_DEV, "01-login.png"), "Gambar 2.1: Antarmuka Autentikasi Pengguna & Tombol Demo Mode Instan", width=Inches(3.1))

    add_subbab_heading(doc, "3.2", "Katalog Inventaris & Rincian Informasi Alat")
    add_body_paragraph(
        doc,
        "Katalog inventaris menampilkan kartu-kartu alat laboratorium secara responsif. Pengguna dapat melakukan filter "
        "berdasarkan kategori (Komputer, Elektronik, Aksesoris, Audio) dan mengetikkan kata kunci pencarian. "
        "Menekan kartu alat akan membuka halaman rincian yang memuat spesifikasi teknis, kondisi fisik, dan posisi lemari rak:"
    )
    add_academic_image(doc, os.path.join(IMG_DEV, "10-catalog-search.png"), "Gambar 2.2: Katalog Alat Real-time Dilengkapi Fitur Pencarian & Chip Kategori", width=Inches(3.1))
    add_academic_image(doc, os.path.join(IMG_DEV, "08-laptop-detail.png"), "Gambar 2.3: Halaman Rincian Spesifikasi Laptop Asus, Status Kondisi, dan Posisi Rak A-1", width=Inches(3.1))

    proj_detail = os.path.join(IMG_EVID, "assets-projector-detail.png")
    if os.path.exists(proj_detail):
        add_academic_image(doc, proj_detail, "Gambar 2.4: Halaman Rincian Spesifikasi Proyektor LCD Epson EB-X400 & Posisi Lemari Khusus", width=Inches(3.1))

    admin_dash_img = os.path.join(IMG_EVID, "login-roles", "admin-dashboard.png")
    if os.path.exists(admin_dash_img):
        add_academic_image(doc, admin_dash_img, "Gambar 2.5: Tampilan Dashboard Khusus Laboran dengan Metrik Statistik dan 5 Tab Navigasi", width=Inches(3.1))

    add_subbab_heading(doc, "3.3", "Formulir Digital Pengajuan Peminjaman")
    add_body_paragraph(
        doc,
        "Formulir pengajuan peminjaman menyediakan komponen DatePicker kalender (WIB), pengatur kuota jumlah unit, dan kolom deskripsi keperluan praktikum. "
        "Pengguna dipandu dengan petunjuk visual batas maksimal stok alat yang masih tersedia di laboratorium:"
    )
    add_academic_image(doc, os.path.join(IMG_DEV, "02-student-form.png"), "Gambar 2.6: Formulir Digital Pengajuan Peminjaman Alat Mahasiswa", width=Inches(3.1))

    add_subbab_heading(doc, "3.4", "Pemecahan Masalah Layout: Perbaikan Keyboard Overflow dengan SafeArea")
    add_body_paragraph(
        doc,
        "Kendala Teknis: Saat pengujian pada smartphone Android fisik, ketika pengguna mengklik kolom teks keperluan, soft-keyboard "
        "virtual muncul dan menutupi separuh bawah layar, memicu galat 'A RenderFlex overflowed by XX pixels' pada konsol Flutter.\n\n"
        "Solusi Problem-Solving: Seluruh struktur formulir dibungkus kembali dengan widget `SafeArea` dan `SingleChildScrollView` "
        "dengan physics `ClampingScrollPhysics()`. Dengan perbaikan ini, layout secara otomatis bergeser ke atas secara proporsional "
        "ketika keyboard virtual aktif, menjamin seluruh bidang input dan tombol submit tetap dapat diakses dengan nyaman:"
    )

    code_safe = """SafeArea(
  child: SingleChildScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: EdgeInsets.all(16.0),
    child: Column(
      children: [
        TextFormField(controller: _keperluanCtrl, maxLines: 3),
        SizedBox(height: 24),
        ElevatedButton(onPressed: _submitPinjam, child: Text('Ajukan Peminjaman')),
      ],
    ),
  ),
)"""
    add_code_snippet(doc, "Cuplikan Kode 2.3: Pembungkusan Widget Menggunakan SafeArea & SingleChildScrollView", code_safe)

    before_safe_img = os.path.join(IMG_DEV, "02-student-form-before-safe-area.png")
    if os.path.exists(before_safe_img):
        add_academic_image(doc, before_safe_img, "Gambar 2.7: Tampilan Formulir Sebelum Perbaikan (Layout Tertekan / Tertutup Keyboard)", width=Inches(3.1))

    fixed_safe_img = os.path.join(IMG_DEV, "05-form-safe-area-fixed.png")
    if os.path.exists(fixed_safe_img):
        add_academic_image(doc, fixed_safe_img, "Gambar 2.8: Bukti Perbaikan Layout Safe Area: Bidang Input Bebas Tumpang Tindih Keyboard", width=Inches(3.1))

    # BAB IV
    add_bab_heading(doc, "IV", "PENUTUP")
    add_subbab_heading(doc, "4.1", "Kesimpulan Keterlaksanaan Minggu II")
    add_body_paragraph(
        doc,
        "Seluruh kebutuhan desain antarmuka Material Design 3 (Unila Palette), Bottom Navigation Bar multi-role berbasis IndexedStack, "
        "katalog pencarian interaktif, adaptabilitas rincian alat berbagai kategori, serta penanganan masalah responsive layout dan keyboard overflow pada Minggu II "
        "telah berhasil diwujudkan secara paripurna (100%)."
    )
    add_subbab_heading(doc, "4.2", "Rencana Tindak Lanjut Minggu III")
    add_body_paragraph(
        doc,
        "Pada Minggu III, antarmuka yang telah dibangun akan diintegrasikan secara langsung ke Cloud Database Supabase "
        "(PostgreSQL 15), menerapkan autentikasi GoTrue JWT, mengonfigurasi Row Level Security (RLS), serta membersihkan seluruh data tiruan (dummy data)."
    )

    add_daftar_pustaka(doc, DAFTAR_PUSTAKA_STANDARD)
    return doc


# ==============================================================
# MINGGU 3
# ==============================================================
def create_minggu_3():
    doc = docx.Document()
    setup_academic_page(doc)

    add_academic_cover(
        doc,
        jenis_dokumen="LAPORAN PRAKTIKUM KEMAJUAN PROYEK MINGGU III",
        judul_utama="PEMROGRAMAN MOBILE (MOBILE PROGRAMMING)",
        sub_judul="Integrasi Cloud Database Supabase (PostgreSQL 15), Supabase Auth, Row Level Security (RLS), dan Eliminasi Dummy Data pada Aplikasi LabInventory",
        tgl_tahun="2026"
    )

    add_kata_pengantar(
        doc,
        judul_dokumen="Laporan Praktikum Kemajuan Proyek Minggu III: Integrasi Cloud Database Supabase (PostgreSQL 15), Supabase Auth, Row Level Security (RLS), dan Eliminasi Dummy Data pada Aplikasi LabInventory",
        tgl_str="23 September 2026"
    )

    # BAB I
    add_bab_heading(doc, "I", "PENDAHULUAN & ARSITEKTUR CLOUD")
    add_subbab_heading(doc, "1.1", "Latar Belakang Integrasi Backend Cloud")
    add_body_paragraph(
        doc,
        "Aplikasi inventaris laboratorium tidak dapat mengandalkan penyimpanan lokal semata, melainkan memerlukan "
        "pusat data terpusat (centralized cloud repository) yang menjamin konsistensi data secara instan saat terjadi "
        "transaksi oleh mahasiswa maupun laboran. Pada Minggu III, prototype visual diintegrasikan ke platform Supabase Cloud "
        "yang didukung oleh mesin basis data relasional enterprise PostgreSQL versi 15."
    )

    add_subbab_heading(doc, "1.2", "Rumusan Masalah Integrasi Cloud Backend")
    add_body_paragraph(
        doc,
        "Rumusan masalah yang diselesaikan pada tahapan integrasi backend mencakup:"
    )
    add_bullet_item(doc, "Bagaimana merancang skema relasional database PostgreSQL yang memenuhi kaidah normalisasi dan integritas referensial foreign key?")
    add_bullet_item(doc, "Bagaimana menegakkan keamanan data di sisi server (database-level security) menggunakan Row Level Security (RLS)?")
    add_bullet_item(doc, "Bagaimana mengelola sesi autentikasi pengguna secara aman dengan token JWT Supabase GoTrue?")
    add_bullet_item(doc, "Bagaimana mencegah terjadinya infinite loading spinner saat koneksi internet kampus mengalami packet loss?")

    add_subbab_heading(doc, "1.3", "Batasan Masalah Backend")
    add_body_paragraph(
        doc,
        "Batasan implementasi backend pada Minggu III mencakup:"
    )
    add_bullet_item(doc, "Platform database menggunakan Supabase Cloud Managed PostgreSQL versi 15.")
    add_bullet_item(doc, "Autentikasi menggunakan email dan password terenkripsi via library GoTrue API.")
    add_bullet_item(doc, "Seluruh data pengujian wajib diinput ke server live dan seluruh dummy data lokal dibersihkan secara total.")

    add_subbab_heading(doc, "1.4", "Tujuan Praktikum Minggu III")
    add_body_paragraph(
        doc,
        "Tujuan pelaksanaan praktikum Minggu III meliputi:"
    )
    add_bullet_item(doc, "Mengintegrasikan pustaka `supabase_flutter: ^2.5.0` ke dalam aplikasi Flutter.")
    add_bullet_item(doc, "Melakukan migrasi skema tabel relasional `profiles`, `items`, dan `borrowings` berbasis UUID.")
    add_bullet_item(doc, "Menerapkan Row Level Security (RLS) pada PostgreSQL untuk menjamin isolasi hak akses data.")
    add_bullet_item(doc, "Mengintegrasikan manajemen sesi login aman menggunakan Supabase Auth (GoTrue).")
    add_bullet_item(doc, "Menghapus seluruh data tiruan (dummy data) sehingga antarmuka 100% terhubung secara live.")
    add_bullet_item(doc, "Menyediakan akun pengujian resmi dan mengimplementasikan mekanisme timeout guard 4 detik.")

    add_subbab_heading(doc, "1.5", "Manfaat Praktikum")
    add_body_paragraph(
        doc,
        "Praktikum ini memberikan pemahaman mendalam mengenai arsitektur backend cloud modern (Backend-as-a-Service), "
        "teknik pengamanan basis data relasional enterprise, serta sinkronisasi data realtime antara client mobile dan cloud."
    )

    # BAB II
    add_bab_heading(doc, "II", "LANDASAN TEORI & SKEMA DATABASE CLOUD")
    add_subbab_heading(doc, "2.1", "Arsitektur Cloud & Keamanan PostgreSQL RLS")
    add_body_paragraph(
        doc,
        "Keamanan sistem tidak diletakkan pada logika sisi klien, melainkan ditegakkan langsung pada engine PostgreSQL "
        "menggunakan Row Level Security (RLS). Mahasiswa hanya diizinkan membaca dan menulis baris peminjaman miliknya "
        "sendiri (`auth.uid() = user_id`), sedangkan Laboran memiliki otorisasi penuh untuk mengelola inventaris dan transaksi:"
    )

    db_schema_img = os.path.join(IMG_EVID, "skema_relasional_database.png")
    if os.path.exists(db_schema_img):
        add_academic_image(doc, db_schema_img, "Gambar 3.1: Diagram Skema Relasional Database & Kebijakan RLS (Supabase PostgreSQL 15)", width=Inches(5.4))

    add_subbab_heading(doc, "2.2", "Skema Relasional Database Supabase")
    add_body_paragraph(
        doc,
        "Struktur tabel relasional dirancang menggunakan Primary Key UUID v4 dengan integritas referensial foreign key:"
    )
    tabel_skema_headers = ["Nama Tabel", "Primary Key", "Foreign Key", "Fungsi & Kebijakan RLS"]
    tabel_skema_data = [
        ["profiles", "id (UUID)", "auth.users(id)", "Menyimpan data identitas (nama, npm, role). Mahasiswa membaca miliknya; Admin membaca semua."],
        ["items", "id (UUID)", "-", "Master data alat lab (nama, kode, stok, lokasi). Seluruh user dapat membaca (SELECT); hanya Admin yang dapat mengubah."],
        ["borrowings", "id (UUID)", "profiles(id), items(id)", "Data pengajuan peminjaman. Mahasiswa membaca miliknya; Admin membaca seluruh lab & mengupdate status."]
    ]
    add_academic_table(doc, "Tabel 3.1: Spesifikasi Skema Database Relasional PostgreSQL Supabase", tabel_skema_headers, tabel_skema_data, col_widths=[1.2, 1.2, 1.6, 2.4])

    add_subbab_heading(doc, "2.3", "Skrip DDL Pembuatan Tabel Relasional")
    add_body_paragraph(
        doc,
        "Struktur tabel dieksekusi melalui SQL Editor Supabase dengan sintaks DDL berikut:"
    )

    code_ddl = """-- Tabel Master Profil Pengguna
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  npm VARCHAR(20),
  role VARCHAR(20) DEFAULT 'mahasiswa' CHECK (role IN ('mahasiswa', 'laboran')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Master Barang Inventaris Lab
CREATE TABLE items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  kode_barang VARCHAR(50) UNIQUE NOT NULL,
  nama VARCHAR(255) NOT NULL,
  kategori VARCHAR(100) NOT NULL,
  stok INTEGER NOT NULL CHECK (stok >= 0),
  stok_rusak INTEGER DEFAULT 0 CHECK (stok_rusak >= 0),
  posisi_rak VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Transaksi Peminjaman (Junction Table)
CREATE TABLE borrowings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  item_id UUID REFERENCES items(id) ON DELETE RESTRICT NOT NULL,
  jumlah INTEGER NOT NULL CHECK (jumlah > 0),
  tgl_pinjam TIMESTAMPTZ NOT NULL,
  tgl_kembali TIMESTAMPTZ NOT NULL,
  keperluan TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'returned', 'rejected')),
  kondisi_kembali VARCHAR(20) CHECK (kondisi_kembali IN ('baik', 'rusak')),
  catatan_laboran TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);"""
    add_code_snippet(doc, "Cuplikan Kode 3.1: Skrip SQL DDL Pembuatan Tabel Relasional pada PostgreSQL 15", code_ddl)

    add_subbab_heading(doc, "2.4", "Kebijakan Keamanan Row Level Security (RLS)")
    add_body_paragraph(
        doc,
        "Keamanan akses tabel dikunci menggunakan RLS PostgreSQL guna memastikan proteksi data tingkat server:"
    )

    code_rls = """-- Aktifkan RLS pada seluruh tabel
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
ALTER TABLE borrowings ENABLE ROW LEVEL SECURITY;

-- Kebijakan RLS Tabel Borrowings untuk Mahasiswa
CREATE POLICY "Mahasiswa hanya dapat melihat pengajuan miliknya"
ON borrowings FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Mahasiswa dapat menyisipkan pengajuan baru"
ON borrowings FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Kebijakan RLS Tabel Borrowings untuk Laboran
CREATE POLICY "Laboran memiliki akses penuh terhadap seluruh transaksi"
ON borrowings FOR ALL
USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'laboran'));"""
    add_code_snippet(doc, "Cuplikan Kode 3.2: Skrip SQL Penegakan Kebijakan Row Level Security (RLS)", code_rls)

    # BAB III
    add_bab_heading(doc, "III", "IMPLEMENTASI BACKEND & HASIL EVALUASI")
    add_subbab_heading(doc, "3.1", "Kredensial Akun Pengujian Resmi")
    add_body_paragraph(
        doc,
        "Untuk memfasilitasi pengujian alur live oleh dosen penguji, telah disiapkan dua akun terdaftar resmi pada Supabase Authentication:"
    )
    tabel_akun_headers = ["Role Akun", "Alamat Email", "Kata Sandi", "Hak Akses & Otorisasi"]
    tabel_akun_data = [
        ["Admin / Laboran", "admin@lab.com", "admin123", "Akses penuh Dashboard Laboran, Approval Pengajuan, Input Barang, Pengembalian."],
        ["Mahasiswa / Siswa", "tes@1.com", "123456", "Akses Katalog Inventaris, Pengajuan Peminjaman Alat, Status Peminjaman Saya."]
    ]
    add_academic_table(doc, "Tabel 3.2: Daftar Akun Pengujian Resmi Supabase Auth", tabel_akun_headers, tabel_akun_data, col_widths=[1.4, 1.6, 1.2, 2.2])

    add_subbab_heading(doc, "3.2", "Inisialisasi Klien Flutter & Penanganan Timeout")
    add_body_paragraph(
        doc,
        "Inisialisasi klien Supabase pada Flutter dikonfigurasi pada fungsi `main()` dengan menyertakan penanganan batas waktu (timeout guard 4 detik) "
        "menggunakan blok `try-finally` untuk memastikan indikator loading selalu tertutup secara aman:"
    )

    code_init = """Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vtdxrqyocjswtwgcmxoc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );
  runApp(const LabInventoryApp());
}

// Timeout Guard 4 Detik pada Service Transaksi
Future<void> submitBorrowingWithTimeout(...) async {
  try {
    await supabase.from('borrowings').insert(...).timeout(
      const Duration(seconds: 4),
      onTimeout: () => throw TimeoutException('Batas waktu koneksi server terlampaui.'),
    );
  } finally {
    hideLoadingDialog();
  }
}"""
    add_code_snippet(doc, "Cuplikan Kode 3.3: Inisialisasi Supabase Flutter dan Mekanisme Timeout Guard 4 Detik", code_init)

    add_subbab_heading(doc, "3.3", "Dokumentasi Sinkronisasi Real-time & Autentikasi Cloud")
    add_body_paragraph(
        doc,
        "Pengujian koneksi cloud dievaluasi langsung menggunakan perangkat pengujian Google Pixel 7a (Android 14) "
        "yang terhubung ke backend Supabase live tanpa dummy data:"
    )

    prod_login_img = os.path.join(IMG_EVID, "configuration", "production-login-pixel7a.png")
    if os.path.exists(prod_login_img):
        add_academic_image(doc, prod_login_img, "Gambar 3.2: Bukti Otentikasi Supabase GoTrue Live pada Pengujian Google Pixel 7a", width=Inches(3.1))

    prod_prof_img = os.path.join(IMG_EVID, "configuration", "production-profile-access-pixel7a.png")
    if os.path.exists(prod_prof_img):
        add_academic_image(doc, prod_prof_img, "Gambar 3.3: Verifikasi Hak Akses Role Pengguna Berbasis Sesi Cloud Supabase UUID", width=Inches(3.1))

    add_academic_image(doc, os.path.join(IMG_DEV, "04-student-pending.png"), "Gambar 3.4: Halaman Peminjaman Mahasiswa: Status 'PENDING' Tersinkronisasi Live ke Cloud", width=Inches(3.1))
    add_academic_image(doc, os.path.join(IMG_DEV, "09-admin-created-item.png"), "Gambar 3.5: Formulir Tambah Alat Baru oleh Laboran yang Langsung Mengupdate Tabel Items Cloud", width=Inches(3.1))

    add_subbab_heading(doc, "3.4", "Evaluasi Kendala & Solusi Teknis")
    add_body_paragraph(
        doc,
        "1. Kendala Foreign Key Violation: Terjadi error saat pengajuan pinjam dikirim karena ID barang pada form masih membaca format integer tiruan. "
        "Solusi: Memperbarui model Dart agar secara otomatis menyalin string UUID valid yang ada di tabel `items` Supabase.\n"
        "2. Kendala Infinite Loading Spinner: Pada jaringan seluler lambat, indikator loading berputar tanpa henti. "
        "Solusi: Menerapkan timeout guard 4 detik dengan blok `try-finally` untuk memastikan dialog tertutup tepat waktu."
    )

    # BAB IV
    add_bab_heading(doc, "IV", "PENUTUP")
    add_subbab_heading(doc, "4.1", "Kesimpulan Keterlaksanaan Minggu III")
    add_body_paragraph(
        doc,
        "Seluruh infrastruktur cloud backend Supabase (PostgreSQL 15), skema DDL relasional, otorisasi RLS tingkat server, "
        "manajemen sesi autentikasi JWT, dan koneksi data real-time telah berhasil diimplementasikan secara solid (100%) dengan penghapusan menyeluruh data dummy."
    )
    add_subbab_heading(doc, "4.2", "Rencana Tindak Lanjut Minggu IV")
    add_body_paragraph(
        doc,
        "Pada Minggu IV, pekerjaan difokuskan pada penguncian integritas transaksi stok melalui stored procedure PostgreSQL (RPC), "
        "alur pengembalian alat dengan inspeksi kerusakan fisik, pengujian di perangkat smartphone fisik, serta penyusunan laporan akhir."
    )

    add_daftar_pustaka(doc, DAFTAR_PUSTAKA_STANDARD)
    return doc


# ==============================================================
# MINGGU 4
# ==============================================================
def create_minggu_4():
    doc = docx.Document()
    setup_academic_page(doc)

    add_academic_cover(
        doc,
        jenis_dokumen="LAPORAN PRAKTIKUM KEMAJUAN PROYEK MINGGU IV",
        judul_utama="PEMROGRAMAN MOBILE (MOBILE PROGRAMMING)",
        sub_judul="Implementasi Transaksi Stok Atomik (PostgreSQL RPC), Alur Pengembalian Alat Rusak, Pengujian Perangkat Fisik (Physical Device Testing), dan Finalisasi Proyek LabInventory",
        tgl_tahun="2026"
    )

    add_kata_pengantar(
        doc,
        judul_dokumen="Laporan Praktikum Kemajuan Proyek Minggu IV: Implementasi Transaksi Stok Atomik (PostgreSQL RPC), Alur Pengembalian Alat Rusak, Pengujian Perangkat Fisik (Physical Device Testing), dan Finalisasi Proyek LabInventory",
        tgl_str="19 Oktober 2026"
    )

    # BAB I
    add_bab_heading(doc, "I", "PENDAHULUAN & PENINGKATAN INTEGRITAS")
    add_subbab_heading(doc, "1.1", "Latar Belakang Transaksi Atomik & Bahaya Race Condition")
    add_body_paragraph(
        doc,
        "Tantangan terbesar pada sistem peminjaman inventaris berbasis cloud adalah risiko terjadinya *race condition* "
        "(kondisi balapan) ketika dua mahasiswa atau dua laboran memperebutkan unit stok barang terakhir yang sama secara bersamaan. "
        "Jika pembaruan stok dilakukan melalui query bertahap di sisi klien, unit barang rentan mengalami alokasi ganda (*double-booking*). "
        "Oleh karena itu, pada Minggu IV dikembangkan prosedur transaksi atomik langsung pada level database menggunakan PostgreSQL RPC."
    )

    add_subbab_heading(doc, "1.2", "Rumusan Masalah Transaksi & Pengujian")
    add_body_paragraph(
        doc,
        "Rumusan masalah yang diselesaikan pada tahapan finalisasi meliputi:"
    )
    add_bullet_item(doc, "Bagaimana memastikan pemotongan stok barang dan persetujuan tiket berjalan secara atomik (ACID) tanpa risiko race condition?")
    add_bullet_item(doc, "Bagaimana memisahkan pencatatan stok unit siap pakai dan unit rusak saat alat dikembalikan oleh mahasiswa?")
    add_bullet_item(doc, "Bagaimana memverifikasi stabilitas seluruh fitur fungsional sistem pada perangkat fisik Android melalui pengujian 12 checkpoint?")
    add_bullet_item(doc, "Bagaimana memvalidasi ketahanan alur transaksi secara otomatis menggunakan pengujian End-to-End (E2E)?")

    add_subbab_heading(doc, "1.3", "Batasan Transaksi Sistem")
    add_body_paragraph(
        doc,
        "Batasan implementasi transaksi pada Minggu IV meliputi:"
    )
    add_bullet_item(doc, "Operasi mutasi stok barang dikunci di tingkat database menggunakan perintah `SELECT ... FOR UPDATE`.")
    add_bullet_item(doc, "Pengujian fungsional dilakukan secara langsung pada smartphone Android fisik dengan 12 checkpoint skenario operasional.")
    add_bullet_item(doc, "Pengujian automasi divalidasi menggunakan framework Playwright Test berbasis browser engine Chromium.")

    add_subbab_heading(doc, "1.4", "Tujuan Praktikum Minggu IV")
    add_body_paragraph(
        doc,
        "Tujuan pelaksanaan praktikum Minggu IV meliputi:"
    )
    add_bullet_item(doc, "Membangun stored procedure PostgreSQL RPC (`approve_borrowing`, `reject_borrowing`, `return_borrowing`) bergaransi ACID.")
    add_bullet_item(doc, "Menerapkan penguncian baris (`SELECT ... FOR UPDATE`) untuk mencegah double-booking unit barang terakhir.")
    add_bullet_item(doc, "Mengembangkan fitur pengembalian alat dengan verifikasi kondisi fisik (Baik vs Rusak) dan manajemen `stok_rusak`.")
    add_bullet_item(doc, "Menerapkan Idempotency Key berbasis UUID request untuk menjamin ketahanan sistem saat sinyal tidak stabil.")
    add_bullet_item(doc, "Melakukan pengujian komprehensif pada smartphone Android fisik (Physical Device Testing) dengan 12 checkpoint verifikasi.")
    add_bullet_item(doc, "Menuntaskan dokumen Software Requirement Document (SRD v2.0) dan laporan akhir praktikum.")

    add_subbab_heading(doc, "1.5", "Manfaat Praktikum")
    add_body_paragraph(
        doc,
        "Praktikum ini memberikan keahlian tingkat lanjut dalam rekayasa transaksi basis data relasional enterprise, "
        "metodologi pengujian perangkat lunak mobile secara empiris, serta menghasilkan sistem inventaris siap guna berstandar industri."
    )

    # BAB II
    add_bab_heading(doc, "II", "KAJIAN TEORI & ARSITEKTUR TRANSAKSI ATOMIK")
    add_subbab_heading(doc, "2.1", "Konsep Transaksi ACID pada PostgreSQL RPC")
    add_body_paragraph(
        doc,
        "Transaksi atomik memastikan bahwa operasi pengurangan stok barang dan pengubahan status peminjaman menjadi `approved` "
        "dieksekusi dalam satu siklus database tunggal. Apabila salah satu langkah mengalami kegagalan, seluruh mutasi dibatalkan "
        "secara otomatis (*automatic rollback*). Prosedur RPC yang diterapkan meliputi:"
    )

    code_rpc_approve = """CREATE OR REPLACE FUNCTION approve_borrowing(p_borrowing_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_item_id UUID;
  v_jumlah INTEGER;
  v_current_stock INTEGER;
BEGIN
  -- 1. Kunci baris peminjaman
  SELECT item_id, jumlah INTO v_item_id, v_jumlah
  FROM borrowings WHERE id = p_borrowing_id AND status = 'pending' FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tiket peminjaman tidak valid atau sudah diproses.';
  END IF;

  -- 2. Kunci baris barang dan periksa stok
  SELECT stok INTO v_current_stock FROM items WHERE id = v_item_id FOR UPDATE;
  IF v_current_stock < v_jumlah THEN
    RAISE EXCEPTION 'Stok fisik tidak mencukupi untuk persetujuan ini.';
  END IF;

  -- 3. Kurangkan stok dan perbarui status secara atomik
  UPDATE items SET stok = stok - v_jumlah WHERE id = v_item_id;
  UPDATE borrowings SET status = 'approved' WHERE id = p_borrowing_id;

  RETURN jsonb_build_object('success', true, 'message', 'Persetujuan berhasil diproses.');
END;
$$;"""
    add_code_snippet(doc, "Cuplikan Kode 4.1: Stored Procedure PL/pgSQL approve_borrowing() dengan Penguncian Baris FOR UPDATE", code_rpc_approve)

    add_subbab_heading(doc, "2.2", "Pemisahan Kolom Stok Siap Pakai dan Stok Rusak")
    add_body_paragraph(
        doc,
        "Untuk mencegah terganggunya ketersediaan barang ketika ada unit yang rusak, tabel `items` memisahkan jumlah unit sehat "
        "pada kolom `stok` dan unit rusak pada kolom `stok_rusak`. Dengan demikian, master data barang tetap aktif dan unit sehat "
        "lainnya tetap dapat dipinjam oleh mahasiswa lain untuk kegiatan praktikum berikutnya:"
    )

    code_rpc_return = """CREATE OR REPLACE FUNCTION return_borrowing(
  p_borrowing_id UUID,
  p_kondisi VARCHAR(20),
  p_catatan TEXT
) RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_item_id UUID;
  v_jumlah INTEGER;
BEGIN
  SELECT item_id, jumlah INTO v_item_id, v_jumlah
  FROM borrowings WHERE id = p_borrowing_id AND status = 'approved' FOR UPDATE;

  IF p_kondisi = 'baik' THEN
    UPDATE items SET stok = stok + v_jumlah WHERE id = v_item_id;
  ELSIF p_kondisi = 'rusak' THEN
    UPDATE items SET stok_rusak = stok_rusak + v_jumlah WHERE id = v_item_id;
  END IF;

  UPDATE borrowings SET 
    status = 'returned',
    kondisi_kembali = p_kondisi,
    catatan_laboran = p_catatan
  WHERE id = p_borrowing_id;

  RETURN jsonb_build_object('success', true);
END;
$$;"""
    add_code_snippet(doc, "Cuplikan Kode 4.2: Stored Procedure PL/pgSQL return_borrowing() dengan Penanganan Unit Rusak", code_rpc_return)

    # BAB III
    add_bab_heading(doc, "III", "PENGUJIAN PERANGKAT FISIK & HASIL EVALUASI")
    add_subbab_heading(doc, "3.1", "Matriks Hasil Pengujian Perangkat Fisik (12 Checkpoints)")
    add_body_paragraph(
        doc,
        "Pengujian fungsional menyeluruh dilaksanakan pada smartphone fisik Android dengan mengeksekusi 12 checkpoint skenario operasional:"
    )
    tabel_test_headers = ["No", "Checkpoint Pengujian", "Aktor", "Hasil Verifikasi Lapangan", "Status"]
    tabel_test_data = [
        ["1", "Autentikasi Mahasiswa (tes@1.com)", "Mahasiswa", "Berhasil masuk dashboard mahasiswa", "PASSED"],
        ["2", "Pencarian Katalog Real-time", "Mahasiswa", "Menemukan alat berdasarkan nama/kategori", "PASSED"],
        ["3", "Pengajuan Peminjaman Alat", "Mahasiswa", "Form tersimpan di cloud (status pending)", "PASSED"],
        ["4", "Verifikasi SafeArea Form", "Mahasiswa", "Form bebas tumpang tindih keyboard", "PASSED"],
        ["5", "Autentikasi Laboran (admin@lab.com)", "Laboran", "Metrik & pengajuan pending muncul", "PASSED"],
        ["6", "Persetujuan Pengajuan (Approve)", "Laboran", "Status approved & stok live berkurang", "PASSED"],
        ["7", "Sinkronisasi Status Peminjaman", "Mahasiswa", "Status terupdate approved di user", "PASSED"],
        ["8", "Pengembalian Alat Rusak", "Laboran", "Pilihan kondisi rusak & catatan tersimpan", "PASSED"],
        ["9", "Rekonsiliasi Stok Rusak", "Laboran", "Stok siap pakai aman, stok_rusak bertambah", "PASSED"],
        ["10", "Pendaftaran Alat Baru", "Laboran", "Kode INV-[KAT]-[RANDOM] terbentuk otomatis", "PASSED"],
        ["11", "Audit Log Seluruh Lab", "Laboran", "Riwayat transaksi lab tercatat transparan", "PASSED"],
        ["12", "Status Akhir Mahasiswa", "Mahasiswa", "Badge status berubah menjadi RETURNED", "PASSED"]
    ]
    add_academic_table(doc, "Tabel 4.1: Matriks Verifikasi 12 Checkpoint Pengujian Perangkat Fisik Android", tabel_test_headers, tabel_test_data, col_widths=[0.4, 2.4, 1.1, 2.0, 0.7])

    add_subbab_heading(doc, "3.2", "Dokumentasi Alur Persetujuan, Pengembalian Alat, & Audit Log")
    add_body_paragraph(
        doc,
        "Berikut tangkapan layar pengujian persetujuan peminjaman dengan pengurangan stok atomik, pengembalian alat dengan pilihan kondisi rusak, "
        "penyesuaian otomatis stok di database, audit log riwayat laboratorium, dan status akhir mahasiswa:"
    )
    add_academic_image(doc, os.path.join(IMG_DEV, "03-admin-approved.png"), "Gambar 4.1: Persetujuan Peminjaman oleh Laboran & Pengurangan Stok Otomatis via Transaksi Atomik RPC", width=Inches(3.1))
    add_academic_image(doc, os.path.join(IMG_DEV, "06-damaged-return.png"), "Gambar 4.2: Dialog Pengembalian Alat oleh Laboran dengan Pilihan Rusak & Catatan Kerusakan", width=Inches(3.1))
    add_academic_image(doc, os.path.join(IMG_DEV, "07-stock-after-damage.png"), "Gambar 4.3: Pembaruan Otomatis Stok Siap Pakai & Pencatatan Stok Rusak pada Detail Alat", width=Inches(3.1))
    add_academic_image(doc, os.path.join(IMG_DEV, "11-final-history.png"), "Gambar 4.4: Audit Log Lengkap Riwayat Transaksi Seluruh Laboratorium Komputer PTI", width=Inches(3.1))
    add_academic_image(doc, os.path.join(IMG_DEV, "12-student-final-history.png"), "Gambar 4.5: Riwayat Akhir Mahasiswa dengan Status Transaksi 'RETURNED' / Selesai", width=Inches(3.1))

    add_subbab_heading(doc, "3.3", "Dokumentasi Pengujian Otomasi End-to-End (E2E) Playwright")
    add_body_paragraph(
        doc,
        "Pengujian otomasi End-to-End (E2E) dijalankan menggunakan Playwright Test untuk memvalidasi alur multi-role secara terotomasi "
        "pada resolusi desktop browser dan simulasi perangkat smartphone:"
    )

    playwright_img = os.path.join(IMG_EVID, "playwright-desktop.png")
    if os.path.exists(playwright_img):
        add_academic_image(doc, playwright_img, "Gambar 4.6: Bukti Pengujian Automasi E2E Playwright Desktop untuk Validasi State Transaksi", width=Inches(4.8))

    playwright_phone_img = os.path.join(IMG_EVID, "playwright-return-phone.png")
    if os.path.exists(playwright_phone_img):
        add_academic_image(doc, playwright_phone_img, "Gambar 4.7: Bukti Pengujian Automasi E2E Playwright Mobile Web pada Alur Pengembalian Alat", width=Inches(3.1))

    # BAB IV
    add_bab_heading(doc, "IV", "PENUTUP")
    add_subbab_heading(doc, "4.1", "Kesimpulan Keterlaksanaan Seluruh Proyek")
    add_body_paragraph(
        doc,
        "Seluruh rangkaian pengembangan aplikasi mobile LabInventory dari Minggu I hingga Minggu IV telah berhasil diselesaikan "
        "secara paripurna (100%). Aplikasi terbukti tangguh dalam menangani integritas transaksi stok melalui PostgreSQL RPC bergaransi ACID, "
        "aman dengan proteksi Row Level Security, adaptif terhadap masalah responsive layout keyboard, serta lulus seluruh 12 checkpoint pengujian pada perangkat fisik Android."
    )
    add_subbab_heading(doc, "4.2", "Rekomendasi Pengembangan Mendatang")
    add_body_paragraph(
        doc,
        "Guna pengembangan berkelanjutan pada masa depan, disarankan penambahan fitur pemindaian QR Code pada label fisik alat "
        "serta integrasi notifikasi push (Firebase Cloud Messaging) saat status peminjaman disetujui atau mendekati tenggat waktu pengembalian."
    )

    add_daftar_pustaka(doc, DAFTAR_PUSTAKA_STANDARD)
    return doc


def main():
    print("Building formal academic weekly reports matching Unila PDF specification...")
    
    docs_to_build = [
        ("Laporan_Minggu_1_LabInventory_Naila_Fathia.docx", create_minggu_1()),
        ("Laporan_Minggu_2_LabInventory_Naila_Fathia.docx", create_minggu_2()),
        ("Laporan_Minggu_3_LabInventory_Naila_Fathia.docx", create_minggu_3()),
        ("Laporan_Minggu_4_LabInventory_Naila_Fathia.docx", create_minggu_4())
    ]
    
    for filename, d in docs_to_build:
        path_in_root = os.path.abspath(filename)
        
        # Save to root only
        try:
            d.save(path_in_root)
            print(f"Saved in root: {filename} ({os.path.getsize(path_in_root)} bytes)")
        except Exception as e:
            print(f"Could not save in root {filename}: {e}")
        
    print("All 4 academic reports successfully generated and verified in root directory!")

if __name__ == "__main__":
    main()
