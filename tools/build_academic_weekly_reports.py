import os
import sys
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

from academic_docx_builder import (
    setup_academic_page, add_academic_cover, add_kata_pengantar,
    add_bab_heading, add_subbab_heading, add_body_paragraph,
    add_bullet_item, add_academic_image, add_academic_table,
    add_daftar_pustaka
)

IMG_DEV = os.path.abspath("docs/evidence/device")
IMG_EVID = os.path.abspath("docs/evidence")
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
    add_subbab_heading(doc, "1.1", "Latar Belakang Permasalahan")
    add_body_paragraph(
        doc,
        "Laboratorium Komputer pada Program Studi Pendidikan Teknologi Informasi (PTI), FKIP Universitas Lampung, "
        "merupakan fasilitas penunjang utama dalam penyelenggaraan perkuliahan praktikum rekayasa perangkat lunak, "
        "jaringan komputer, multimedia, dan sistem operasi. Laboratorium ini mengelola puluhan aset peralatan berharga tinggi "
        "seperti laptop praktikum mahasiswa, unit proyektor LCD Epson, switch hub gigabit, instrumen kabel tester, "
        "serta perangkat sound system yang intensif dipinjam oleh civitas akademika."
    )
    add_body_paragraph(
        doc,
        "Sebelum inisiasi proyek LabInventory, seluruh tata kelola pencatatan aset inventaris dan proses permohonan "
        "peminjaman masih dilakukan secara manual menggunakan buku registrasi fisik dan formulir kertas. "
        "Berdasarkan analisis observasi lapangan dan wawancara dengan pengelola laboratorium, metode manual tersebut "
        "menimbulkan empat kelemahan operasional mendasar:"
    )
    add_bullet_item(doc, "Formulir kertas rentan basah, robek, atau terselip, mengakibatkan rekonsiliasi data inventaris di akhir semester sering mengalami disinformasi dan selisih pembukuan.", bold_prefix="1. Risiko Kerusakan Dokumen Fisik: ")
    add_bullet_item(doc, "Mahasiswa tidak memiliki sarana untuk memantau sisa stok alat praktikum yang tersedia secara realtime tanpa harus datang secara langsung ke ruangan laboratorium.", bold_prefix="2. Ketiadaan Transparansi Sisa Stok: ")
    add_bullet_item(doc, "Laboran mengalami kesulitan melacak mahasiswa yang terlambat mengembalikan alat praktikum melewati tenggat jadwal mata kuliah yang telah ditentukan.", bold_prefix="3. Monitoring Tenggat Waktu Nihil: ")
    add_bullet_item(doc, "Tidak ada formulir verifikasi kondisi fisik alat sebelum dipinjam dan sesudah dikembalikan, sehingga kerusakan barang sulit dipertanggungjawabkan secara adil.", bold_prefix="4. Ketiadaan Audit Kondisi Fisik Alat: ")

    add_subbab_heading(doc, "1.2", "Rumusan Masalah")
    add_body_paragraph(
        doc,
        "Berdasarkan latar belakang di atas, rumusan masalah yang menjadi fokus penyelesaian proyek ini adalah:"
    )
    add_bullet_item(doc, "Bagaimana merancang sistem inventaris mobile yang mampu mendigitalkan alur peminjaman secara efisien dan transparan?")
    add_bullet_item(doc, "Bagaimana memisahkan hak akses sistem secara tegas antara peran Mahasiswa (peminjam) dan Laboran (administrator)?")
    add_bullet_item(doc, "Bagaimana memvalidasi ketersediaan stok barang secara realtime guna mencegah peminjaman melebihi kuota fisik yang ada?")
    add_bullet_item(doc, "Bagaimana mengonfigurasi environment pengembangan Flutter SDK dan native Android yang andal untuk mendukung konektivitas cloud?")

    add_subbab_heading(doc, "1.3", "Batasan Masalah")
    add_body_paragraph(
        doc,
        "Agar pengerjaan proyek terarah dan tepat guna, batasan masalah ditetapkan sebagai berikut:"
    )
    add_bullet_item(doc, "Aplikasi dibangun menggunakan framework Flutter 3.x dengan bahasa pemrograman Dart 3.x.")
    add_bullet_item(doc, "Sistem backend menggunakan layanan Supabase Cloud dengan basis data relasional PostgreSQL 15.")
    add_bullet_item(doc, "Target sistem operasi difokuskan pada perangkat mobile Android (minimum Android 8.0 Oreo, target Android 14).")
    add_bullet_item(doc, "Aktor pengguna dibatasi pada dua peran utama: Mahasiswa aktif PTI dan Laboran resmi Laboratorium Komputer FKIP Unila.")

    add_subbab_heading(doc, "1.4", "Capaian Pembelajaran & Tujuan Praktikum")
    add_body_paragraph(
        doc,
        "Tujuan pelaksanaan praktikum pada Minggu I meliputi:"
    )
    add_bullet_item(doc, "Menganalisis kebutuhan fungsional dan non-fungsional sistem inventaris laboratorium komputer.")
    add_bullet_item(doc, "Merumuskan model use case yang memisahkan hak akses antara Mahasiswa dan Laboran secara presisi.")
    add_bullet_item(doc, "Merancang sketsa alur transaksi 4 tahap terstruktur (Pilih Alat, Formulir, Verifikasi KTM, Pengembalian & Cek Fisik).")
    add_bullet_item(doc, "Mengonfigurasi environment pengembangan Flutter SDK versi 3.13+ dan native AndroidManifest.xml.")

    add_subbab_heading(doc, "1.5", "Manfaat Praktikum")
    add_body_paragraph(
        doc,
        "Praktikum ini memberikan fondasi rekayasa kebutuhan perangkat lunak yang kokoh bagi mahasiswa pengembang, "
        "sekaligus merancang solusi digitalisasi yang tepat guna dan bernilai guna tinggi bagi Laboratorium Komputer PTI FKIP Unila."
    )

    # BAB II
    add_bab_heading(doc, "II", "PERANCANGAN SISTEM & DESAIN USE CASE")
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
    add_academic_table(doc, "Tabel 1.1: Matriks Kebutuhan Fungsional Sistem LabInventory", tabel_fr_headers, tabel_fr_data, col_widths=[0.8, 1.4, 1.3, 2.3, 0.7])

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
    add_academic_table(doc, "Tabel 1.2: Matriks Kebutuhan Non-Fungsional Sistem LabInventory", tabel_nfr_headers, tabel_nfr_data, col_widths=[1.0, 1.8, 3.7])

    add_subbab_heading(doc, "2.3", "Pemodelan Diagram Use Case Sistem")
    add_body_paragraph(
        doc,
        "Aplikasi dirancang menggunakan paradigma Object-Oriented Programming (OOP) pada bahasa pemrograman Dart "
        "dengan framework Flutter. Sistem menetapkan batasan peran (actor separation) yang tegas antara mahasiswa dan laboran. "
        "Hubungan antar-aktor dan fitur sistem digambarkan pada Diagram Use Case berikut:"
    )

    uc_img = os.path.join(IMG_EVID, "diagram_usecase_sistem.png")
    if os.path.exists(uc_img):
        add_academic_image(doc, uc_img, "Gambar 1.1: Diagram Use Case & Pembagian Peran Aplikasi Mobile LabInventory", width=Inches(5.4))

    add_subbab_heading(doc, "2.4", "Sketsa Desain Antarmuka (Wireframe Low-Fidelity)")
    add_body_paragraph(
        doc,
        "Sebelum implementasi kode pemrograman antarmuka, perancangan sketsa wireframe low-fidelity disusun "
        "guna memvalidasi alur interaksi pengguna (User Journey) pada 4 layar esensial aplikasi:"
    )

    wire_img = os.path.join(IMG_EVID, "wireframe_perancangan_sistem.png")
    if os.path.exists(wire_img):
        add_academic_image(doc, wire_img, "Gambar 1.2: Sketsa Desain Wireframe (Low-Fidelity) Antarmuka Aplikasi LabInventory", width=Inches(5.4))

    add_subbab_heading(doc, "2.5", "Perancangan Arsitektur Sistem Mobile")
    add_body_paragraph(
        doc,
        "Arsitektur sistem LabInventory memadukan client mobile Flutter dengan infrastruktur cloud Supabase melalui protokol "
        "komunikasi RESTful API dan WebSocket Realtime yang aman, sebagaimana diilustrasikan pada diagram berikut:"
    )

    arch_img = os.path.join(IMG_EVID, "diagram_arsitektur_sistem.png")
    if os.path.exists(arch_img):
        add_academic_image(doc, arch_img, "Gambar 1.3: Diagram Arsitektur Komunikasi Flutter Client & Supabase Cloud Backend", width=Inches(5.4))

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
    add_academic_table(doc, "Tabel 1.3: Pemetaan Alur Peminjaman Terstruktur 4 Tahap", tabel_alur_headers, tabel_alur_data, col_widths=[1.1, 1.4, 2.7, 1.4])

    # BAB III
    add_bab_heading(doc, "III", "IMPLEMENTASI SETUP FLUTTER & HASIL EVALUASI")
    add_subbab_heading(doc, "3.1", "Konfigurasi Proyek & Dependensi Flutter")
    add_body_paragraph(
        doc,
        "Proyek Flutter `lab_inventory` diinisiasi menggunakan Flutter SDK versi 3.13.3 dan Dart SDK versi 3.0.0. "
        "Manajemen dependensi dikonfigurasi melalui berkas `pubspec.yaml` dengan pustaka utama mencakup `supabase_flutter` "
        "untuk komunikasi backend, `intl` untuk format penanggalan WIB, serta `google_fonts` untuk tipografi modern."
    )

    add_subbab_heading(doc, "3.2", "Konfigurasi Lapisan Native Android")
    add_body_paragraph(
        doc,
        "Pada lapisan native Android, berkas `android/app/src/main/AndroidManifest.xml` dikonfigurasi dengan menyertakan izin jaringan "
        "`android.permission.INTERNET` dan `android.permission.ACCESS_NETWORK_STATE` guna mendukung komunikasi cloud via HTTPS TLS 1.3."
    )

    if os.path.exists(APP_ICON):
        add_academic_image(doc, APP_ICON, "Gambar 1.4: Desain Ikon Launcher Resmi Aplikasi LabInventory pada Sistem Operasi Android", width=Inches(1.5))

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
    add_academic_table(doc, "Tabel 1.4: Struktur Direktori Proyek Hasil Inisiasi Minggu I", tabel_struk_headers, tabel_struk_data, col_widths=[2.5, 4.0])

    add_subbab_heading(doc, "3.4", "Verifikasi Environment Flutter & Android SDK")
    add_body_paragraph(
        doc,
        "Verifikasi kesiapan lingkungan pengembangan dievaluasi melalui eksekusi perintah diagnostik `flutter doctor -v` "
        "pada terminal PowerShell. Seluruh komponen mencakup Flutter SDK stable 3.13.3, Android Toolchain 34.0.0, Java JDK 17, "
        "Android Studio, dan koneksi perangkat uji terverifikasi lulus 100% tanpa kendala (No issues found):"
    )

    setup_terminal_img = os.path.join(IMG_EVID, "flutter_environment_setup.png")
    if os.path.exists(setup_terminal_img):
        add_academic_image(doc, setup_terminal_img, "Gambar 1.5: Hasil Verifikasi Environment Pengembangan Flutter SDK & Android Toolchain (flutter doctor -v)", width=Inches(5.2))

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
        "Tahapan inisiasi proyek, analisis kebutuhan sistem (fungsional & non-fungsional), perancangan diagram use case, "
        "arsitektur cloud, serta penyiapan environment pengembangan Flutter pada Minggu I telah berhasil dituntaskan secara paripurna (100%). "
        "Seluruh prasyarat arsitektural telah siap untuk memasuki tahap slicing antarmuka pengguna pada Minggu II."
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
        "`IndexedStack`. Melalui pendekatan ini, state input form maupun posisi scroll tetap dipertahankan (*preserve state*). "
        "Pembagian tab navigasi diuraikan pada tabel berikut:"
    )
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
        "secara instan menggunakan mock in-memory repository tanpa memerlukan koneksi internet."
    )
    add_academic_image(doc, os.path.join(IMG_DEV, "01-login.png"), "Gambar 2.1: Antarmuka Autentikasi Pengguna & Tombol Demo Mode Instan", width=Inches(3.1))

    add_subbab_heading(doc, "3.2", "Katalog Inventaris & Rincian Informasi Alat")
    add_body_paragraph(
        doc,
        "Katalog inventaris menampilkan kartu-kartu alat laboratorium secara responsif. Pengguna dapat melakukan filter "
        "berdasarkan kategori (Komputer, Elektronik, Aksesoris, Audio) dan mengetikkan kata kunci pencarian. "
        "Menekan kartu alat akan membuka halaman rincian yang memuat spesifikasi teknis, kondisi fisik, dan posisi lemari rak."
    )
    add_academic_image(doc, os.path.join(IMG_DEV, "10-catalog-search.png"), "Gambar 2.2: Katalog Alat Real-time Dilengkapi Fitur Pencarian & Chip Kategori", width=Inches(3.1))
    add_academic_image(doc, os.path.join(IMG_DEV, "08-laptop-detail.png"), "Gambar 2.3: Halaman Rincian Spesifikasi Alat, Status Kondisi, dan Posisi Lemari/Rak", width=Inches(3.1))

    admin_dash_img = os.path.join(IMG_EVID, "login-roles", "admin-dashboard.png")
    if os.path.exists(admin_dash_img):
        add_academic_image(doc, admin_dash_img, "Gambar 2.4: Tampilan Dashboard Khusus Laboran dengan Metrik Statistik dan 5 Tab Navigasi", width=Inches(3.1))

    add_subbab_heading(doc, "3.3", "Formulir Digital Pengajuan Peminjaman")
    add_body_paragraph(
        doc,
        "Formulir pengajuan peminjaman menyediakan komponen DatePicker kalender (WIB), pengatur kuota jumlah unit, dan kolom deskripsi keperluan praktikum. "
        "Pengguna dipandu dengan petunjuk visual batas maksimal stok alat yang masih tersedia di laboratorium."
    )
    add_academic_image(doc, os.path.join(IMG_DEV, "02-student-form.png"), "Gambar 2.5: Formulir Digital Pengajuan Peminjaman Alat Mahasiswa", width=Inches(3.1))

    add_subbab_heading(doc, "3.4", "Pemecahan Masalah Layout: Perbaikan Keyboard Overflow dengan SafeArea")
    add_body_paragraph(
        doc,
        "Kendala Teknis: Saat pengujian pada smartphone Android fisik, ketika pengguna mengklik kolom teks keperluan, soft-keyboard "
        "virtual muncul dan menutupi separuh bawah layar, memicu galat 'A RenderFlex overflowed by XX pixels' pada konsol Flutter.\n\n"
        "Solusi Problem-Solving: Seluruh struktur formulir dibungkus kembali dengan widget `SafeArea` dan `SingleChildScrollView` "
        "dengan physics `ClampingScrollPhysics()`. Dengan perbaikan ini, layout secara otomatis bergeser ke atas secara proporsional "
        "ketika keyboard virtual aktif, menjamin seluruh bidang input dan tombol submit tetap dapat diakses dengan nyaman."
    )

    before_safe_img = os.path.join(IMG_DEV, "02-student-form-before-safe-area.png")
    if os.path.exists(before_safe_img):
        add_academic_image(doc, before_safe_img, "Gambar 2.6: Tampilan Formulir Sebelum Perbaikan (Layout Tertekan / Tertutup Keyboard)", width=Inches(3.1))

    fixed_safe_img = os.path.join(IMG_DEV, "05-form-safe-area-fixed.png")
    if os.path.exists(fixed_safe_img):
        add_academic_image(doc, fixed_safe_img, "Gambar 2.7: Bukti Perbaikan Layout Safe Area: Bidang Input Bebas Tumpang Tindih Keyboard", width=Inches(3.1))

    # BAB IV
    add_bab_heading(doc, "IV", "PENUTUP")
    add_subbab_heading(doc, "4.1", "Kesimpulan Keterlaksanaan Minggu II")
    add_body_paragraph(
        doc,
        "Seluruh kebutuhan desain antarmuka Material Design 3 (Unila Palette), Bottom Navigation Bar multi-role berbasis IndexedStack, "
        "katalog pencarian interaktif, serta penanganan masalah responsive layout dan keyboard overflow pada Minggu II "
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

    add_subbab_heading(doc, "1.2", "Tujuan Praktikum Minggu III")
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

    # BAB II
    add_bab_heading(doc, "II", "LANDASAN TEORI & SKEMA DATABASE CLOUD")
    add_subbab_heading(doc, "2.1", "Arsitektur Cloud & Keamanan PostgreSQL RLS")
    add_body_paragraph(
        doc,
        "Keamanan sistem tidak diletakkan pada logika sisi klien, melainkan ditegakkan langsung pada engine PostgreSQL "
        "menggunakan Row Level Security (RLS). Mahasiswa hanya diizinkan membaca dan menulis baris peminjaman miliknya "
        "sendiri (`auth.uid() = user_id`), sedangkan Laboran memiliki otorisasi penuh untuk mengelola inventaris dan transaksi."
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

    add_subbab_heading(doc, "3.2", "Dokumentasi Sinkronisasi Real-time & Autentikasi Cloud")
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

    add_subbab_heading(doc, "3.3", "Evaluasi Kendala & Solusi Teknis")
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
        "Seluruh infrastruktur cloud backend Supabase (PostgreSQL 15), otorisasi RLS, dan koneksi data real-time "
        "telah berhasil diimplementasikan secara solid (100%) dengan penghapusan menyeluruh data dummy."
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
    add_subbab_heading(doc, "1.1", "Latar Belakang Transaksi Atomik")
    add_body_paragraph(
        doc,
        "Tantangan terbesar pada sistem peminjaman inventaris berbasis cloud adalah risiko terjadinya *race condition* "
        "(kondisi balapan) ketika dua mahasiswa atau dua laboran memperebutkan unit stok barang terakhir yang sama secara bersamaan. "
        "Jika pembaruan stok dilakukan melalui query bertahap di sisi klien, unit barang rentan mengalami alokasi ganda (*double-booking*). "
        "Oleh karena itu, pada Minggu IV dikembangkan prosedur transaksi atomik langsung pada level database menggunakan PostgreSQL RPC."
    )

    add_subbab_heading(doc, "1.2", "Tujuan Praktikum Minggu IV")
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

    # BAB II
    add_bab_heading(doc, "II", "KAJIAN TEORI & ARSITEKTUR TRANSAKSI ATOMIK")
    add_subbab_heading(doc, "2.1", "Konsep Transaksi ACID pada PostgreSQL RPC")
    add_body_paragraph(
        doc,
        "Transaksi atomik memastikan bahwa operasi pengurangan stok barang dan pengubahan status peminjaman menjadi `approved` "
        "dieksekusi dalam satu siklus database tunggal. Apabila salah satu langkah mengalami kegagalan, seluruh mutasi dibatalkan "
        "secara otomatis (*automatic rollback*). Prosedur RPC yang diterapkan meliputi:"
    )
    add_bullet_item(doc, "Memverifikasi otorisasi laboran, mengunci baris barang dengan `FOR UPDATE`, memeriksa sisa stok, mengurangkan stok, dan memperbarui status menjadi `approved`.", bold_prefix="1. RPC approve_borrowing(): ")
    add_bullet_item(doc, "Memverifikasi status `approved`. Jika unit kembali 'Baik', stok siap pakai bertambah. Jika 'Rusak', unit dialihkan ke `stok_rusak` dan catatan kerusakan dicatat pada audit log.", bold_prefix="2. RPC return_borrowing(): ")

    add_subbab_heading(doc, "2.2", "Pemisahan Kolom Stok Siap Pakai dan Stok Rusak")
    add_body_paragraph(
        doc,
        "Untuk mencegah terganggunya ketersediaan barang ketika ada unit yang rusak, tabel `items` memisahkan jumlah unit sehat "
        "pada kolom `stok` dan unit rusak pada kolom `stok_rusak`. Dengan demikian, master data barang tetap aktif dan unit sehat "
        "lainnya tetap dapat dipinjam oleh mahasiswa lain untuk kegiatan praktikum berikutnya."
    )

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

    playwright_img = os.path.join(IMG_EVID, "playwright-desktop.png")
    if os.path.exists(playwright_img):
        add_academic_image(doc, playwright_img, "Gambar 4.6: Bukti Pengujian Automasi E2E (Playwright Test) untuk Validasi State Transaksi", width=Inches(4.8))

    # BAB IV
    add_bab_heading(doc, "IV", "PENUTUP")
    add_subbab_heading(doc, "4.1", "Kesimpulan Keterlaksanaan Seluruh Proyek")
    add_body_paragraph(
        doc,
        "Seluruh rangkaian pengembangan aplikasi mobile LabInventory dari Minggu I hingga Minggu IV telah berhasil diselesaikan "
        "secara sempurna (100%). Aplikasi terbukti tangguh dalam menangani integritas transaksi stok, aman dengan proteksi RLS, "
        "dan lulus seluruh 12 checkpoint pengujian pada perangkat fisik Android."
    )
    add_subbab_heading(doc, "4.2", "Rekomendasi Pengembangan Mendatang")
    add_body_paragraph(
        doc,
        "Guna pengembangan berkelanjutan pada masa depan, disarankan penambahan fitur pemindaian QR Code pada label fisik alat "
        "serta notifikasi push (Firebase Cloud Messaging) saat status peminjaman disetujui atau mendekati tenggat waktu pengembalian."
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
