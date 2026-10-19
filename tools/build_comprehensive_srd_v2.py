import os
import sys
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

from academic_docx_builder import (
    setup_academic_page, add_academic_cover, add_kata_pengantar,
    add_bab_heading, add_subbab_heading, add_body_paragraph,
    add_bullet_item, add_academic_image, add_academic_table,
    add_daftar_pustaka
)

IMG_DEV = os.path.abspath("docs/evidence/device")
IMG_EVID = os.path.abspath("docs/evidence")

DAFTAR_PUSTAKA_SRD = [
    "Budhayanti, C. I. S. (2023). Penggunaan Mobile Learning dan Cloud Database pada Perkuliahan Pendidikan Komputer. Jurnal Pendidikan Terbuka dan Jarak Jauh, 24(1), 45-56.",
    "Kemendikbudristek. (2022). Panduan Pembelajaran dan Asesmen Pendidikan Vokasi dan Komputer. Jakarta: BSKAP Kemendikbudristek.",
    "PostgreSQL Global Development Group. (2023). PostgreSQL 15 Documentation: Row Level Security Policies and Concurrency Control. PostgreSQL Official Documentation Hub.",
    "Pressman, R. S., & Maxim, B. R. (2020). Software Engineering: A Practitioner's Approach (9th ed.). New York: McGraw-Hill Education.",
    "Sommerville, I. (2019). Software Engineering (10th ed.). London: Pearson Education.",
    "Supabase Inc. (2024). Supabase Documentation: Auth, Realtime Database, and Stored Procedures via PostgreSQL RPC. San Francisco: Supabase Docs Hub.",
    "Team Flutter. (2024). Flutter Documentation: Material 3 Design Specifications and State Management with IndexedStack. Mountain View: Google Open Source.",
    "Wulandari, L. P. A. O., & Agustini, K. (2024). Pengembangan Sistem Manajemen Laboratorium Berbasis Mobile Menggunakan Arsitektur Clean Architecture. Jurnal Pendidikan Teknologi dan Kejuruan, 23(1), 89-101.",
    "Yauma, A., Fitri, I., & Ningsih, S. (2021). Perancangan Sistem Informasi Inventaris Peralatan Laboratorium Berbasis Mobile. Jurnal Sains dan Teknologi Komputer, 1(2), 99-106."
]

def build_full_srd_v2():
    doc = docx.Document()
    setup_academic_page(doc)

    # ================= COVER =================
    add_academic_cover(
        doc,
        jenis_dokumen="SOFTWARE REQUIREMENT DOCUMENT (SRD) — VERSION 2.0",
        judul_utama="SISTEM INFORMASI MANAJEMEN INVENTARIS DAN PEMINJAMAN ALAT LABORATORIUM KOMPUTER BERBASIS MOBILE (LABINVENTORY)",
        sub_judul="Spesifikasi Kebutuhan Sistem Terintegrasi Cloud Database Supabase PostgreSQL 15, Supabase Auth, dan Row Level Security (RLS)",
        tgl_tahun="2026"
    )

    # ================= KATA PENGANTAR =================
    add_kata_pengantar(
        doc,
        judul_dokumen="Software Requirement Document (SRD) Version 2.0: Sistem Informasi Manajemen Inventaris dan Peminjaman Alat Laboratorium Komputer Berbasis Mobile (LabInventory)",
        tgl_str="19 Oktober 2026"
    )

    # ================= LEMBAR RIWAYAT REVISI =================
    h_rev = doc.add_paragraph()
    h_rev.alignment = WD_ALIGN_PARAGRAPH.CENTER
    h_rev.paragraph_format.space_before = Pt(12)
    h_rev.paragraph_format.space_after = Pt(14)
    r_rev = h_rev.add_run("LEMBAR RIWAYAT REVISI DOKUMEN SPESIFIKASI")
    r_rev.font.name = "Times New Roman"
    r_rev.font.size = Pt(12)
    r_rev.bold = True

    add_body_paragraph(
        doc,
        "Dokumen Software Requirement Document (SRD) ini dikembangkan secara iteratif mengikuti siklus rekayasa perangkat lunak. "
        "Setiap modifikasi arsitektur, skema basis data, dan penyesuaian kebutuhan fungsional dicatat pada tabel riwayat berikut:"
    )

    rev_headers = ["Versi", "Tanggal Rilis", "Deskripsi Perubahan Spesifikasi", "Penulis & Verifikator"]
    rev_data = [
        ["1.0", "03 Sept 2026", "Draf awal spesifikasi kebutuhan sistem: pendahuluan, perancangan use case awal, arsitektur dasar, dan konsep penyimpanan MySQL lokal.", "Naila Fathia (2413025076)"],
        ["2.0", "19 Okt 2026", "Pembaruan Menyeluruh (v2.0): Migrasi total arsitektur ke Cloud Supabase (PostgreSQL 15), penerapan Row Level Security (RLS), stored procedure transaksi atomik (RPC), skema UUID v4, eliminasi dummy data, penyertaan diagram arsitektur/use case visual, dan integrasi hasil pengujian perangkat fisik Android.", "Naila Fathia (2413025076)"]
    ]
    add_academic_table(doc, "Tabel Riwayat Pembaruan Dokumen Spesifikasi Kebutuhan Perangkat Lunak", rev_headers, rev_data, col_widths=[0.8, 1.3, 3.4, 1.5])
    doc.add_page_break()

    # ================= BAB I: PENDAHULUAN =================
    add_bab_heading(doc, "I", "PENDAHULUAN")
    
    add_subbab_heading(doc, "1.1", "Latar Belakang Permasalahan")
    add_body_paragraph(
        doc,
        "Perkembangan teknologi komputasi dan pendidikan kejuruan menuntut penyelenggaraan kegiatan laboratorium yang terstruktur, "
        "akuntabel, dan efisien. Pada Program Studi Pendidikan Teknologi Informasi (PTI), Fakultas Keguruan dan Ilmu Pendidikan, "
        "Universitas Lampung, Laboratorium Komputer memegang peranan krusial sebagai pusat praktikum rekayasa perangkat lunak, jaringan komputer, "
        "multimedia, dan pemeliharaan perangkat keras. Laboratorium ini mengelola puluhan aset peralatan berharga tinggi, seperti laptop mahasiswa, "
        "unit proyektor LCD Epson, switch gigabit, instrumen kabel tester, serta perangkat audio."
    )
    add_body_paragraph(
        doc,
        "Pada praktiknya, prosedur pengelolaan peminjaman alat praktikum masih mengandalkan mekanisme konvensional berupa buku registrasi fisik "
        "dan formulir kertas. Praktik manual ini menimbulkan sejumlah permasalahan kritis:"
    )
    add_bullet_item(doc, "Formulir kertas rentan hilang, robek, atau terselip, mengakibatkan audit aset di akhir semester tidak akurat.", bold_prefix="1. Risiko Kehilangan Dokumen: ")
    add_bullet_item(doc, "Mahasiswa tidak memiliki sarana untuk memantau sisa stok alat yang tersedia tanpa mendatangi ruang lab secara fisik.", bold_prefix="2. Ketiadaan Transparansi Stok: ")
    add_bullet_item(doc, "Laboran mengalami kesulitan melacak mahasiswa yang terlambat mengembalikan alat praktikum melewati batas waktu.", bold_prefix="3. Monitoring Tenggat Waktu Nihil: ")
    add_bullet_item(doc, "Tidak ada pencatatan resmi mengenai kondisi fisik alat sebelum dipinjam versus saat dikembalikan.", bold_prefix="4. Ketiadaan Inspeksi Fisik: ")

    add_subbab_heading(doc, "1.2", "Gambaran Umum Solusi Perangkat Lunak")
    add_body_paragraph(
        doc,
        "Untuk menjawab tantangan tersebut, dikembangkan sistem aplikasi mobile 'LabInventory' berbasis Flutter yang terintegrasi "
        "langsung dengan Cloud Database PostgreSQL 15 di Supabase. Sistem ini mentransformasi seluruh birokrasi manual ke dalam alur digital "
        "yang aman, real-time, dan mudah diakses oleh mahasiswa maupun laboran."
    )

    add_subbab_heading(doc, "1.3", "Tujuan Pengembangan Sistem")
    add_body_paragraph(
        doc,
        "Tujuan penyusunan spesifikasi kebutuhan perangkat lunak ini meliputi:"
    )
    add_bullet_item(doc, "Menyediakan dokumen acuan teknis (blueprint) yang memandu implementasi arsitektur, database, dan antarmuka mobile.")
    add_bullet_item(doc, "Memastikan integritas transaksi mutasi stok alat laboratorium bergaransi ACID melalui stored procedure PostgreSQL RPC.")
    add_bullet_item(doc, "Menjamin keamanan data pengguna dan hak akses data institusi melalui kebijakan Row Level Security (RLS).")
    add_bullet_item(doc, "Menyediakan antarmuka mobile responsif Material Design 3 yang ramah pengguna (user-friendly) bagi mahasiswa dan laboran.")

    add_subbab_heading(doc, "1.4", "Manfaat Sistem")
    add_bullet_item(doc, "Memperoleh kemudahan menelusuri katalog alat praktikum, mengecek stok siap pakai, dan mengajukan pinjam secara mandiri.", bold_prefix="Bagi Mahasiswa: ")
    add_bullet_item(doc, "Mendapatkan kemudahan verifikasi permohonan pinjam, pencatatan otomatis penambahan aset, dan audit trail mutasi alat.", bold_prefix="Bagi Laboran: ")
    add_bullet_item(doc, "Memiliki sistem inventarisasi aset laboratorium komputer yang modern, akuntabel, dan terdigitalisasi penuh.", bold_prefix="Bagi Program Studi PTI: ")

    add_subbab_heading(doc, "1.5", "Batasan Sistem & Ruang Lingkup (Scope & Delimitations)")
    add_body_paragraph(
        doc,
        "Ruang lingkup pengembangan aplikasi LabInventory dibatasi pada hal-hal berikut:"
    )
    add_bullet_item(doc, "Aplikasi dibangun untuk sistem operasi mobile Android menggunakan Flutter SDK.")
    add_bullet_item(doc, "Pusat data operasional dikelola secara terpusat menggunakan Supabase Cloud Platform (PostgreSQL 15).")
    add_bullet_item(doc, "Autentikasi menggunakan Supabase Auth berbasis token JSON Web Token (JWT).")
    add_bullet_item(doc, "Peran pengguna dibagi secara tegas menjadi dua: Mahasiswa (peminjam) dan Laboran (administrator).")
    add_bullet_item(doc, "Tidak menangani transaksi peminjaman antar-kampus; peminjaman dikhususkan untuk lingkungan Laboratorium Komputer PTI FKIP Unila.")

    add_subbab_heading(doc, "1.6", "Definisi Istilah, Akronim, dan Singkatan")
    tabel_istilah_headers = ["Istilah / Akronim", "Kepanjangan", "Definisi Operasional"]
    tabel_istilah_data = [
        ["BaaS", "Backend as a Service", "Model layanan cloud (Supabase) yang menyediakan database, autentikasi, dan API tanpa server mandiri."],
        ["RLS", "Row Level Security", "Mekanisme keamanan PostgreSQL yang membatasi hak akses baca/tulis baris data berdasarkan identitas user."],
        ["RPC", "Remote Procedure Call", "Fungsi/stored procedure PostgreSQL yang dieksekusi secara atomik dari sisi klien."],
        ["JWT", "JSON Web Token", "Standar token terenkripsi untuk memvalidasi sesi autentikasi dan klaim peran pengguna."],
        ["ACID", "Atomicity, Consistency, Isolation, Durability", "Prinsip jaminan keandalan transaksi database pada mutasi kuantitas stok barang."],
        ["UUID", "Universally Unique Identifier", "Tipe data pengidentifikasi unik 128-bit acak berformat v4 sebagai Primary Key database."]
    ]
    add_academic_table(doc, "Tabel 1.1: Glosarium Definisi Istilah dan Singkatan Teknis", tabel_istilah_headers, tabel_istilah_data, col_widths=[1.3, 2.0, 3.7])

    # ================= BAB II: ARSITEKTUR =================
    add_bab_heading(doc, "II", "ARSITEKTUR DAN LINGKUNGAN OPERASIONAL")
    
    add_subbab_heading(doc, "2.1", "Arsitektur Perangkat Lunak (Clean Architecture)")
    add_body_paragraph(
        doc,
        "Aplikasi LabInventory mengadopsi prinsip Clean Architecture yang memisahkan tanggung jawab sistem ke dalam tiga lapisan utama: "
        "Lapisan Presentasi (UI Widgets, Screens, Navigation), Lapisan Logika Bisnis (SessionController, Models, Failures), "
        "dan Lapisan Data (InventoryRepository, Supabase Client). Pola Repository memisahkan logika antarmuka dari komunikasi jaringan, "
        "sehingga memungkinkan pengujian terisolasi dan penggunaan Mode Demo in-memory."
    )

    arch_img = os.path.join(IMG_EVID, "diagram_arsitektur_sistem.png")
    if os.path.exists(arch_img):
        add_academic_image(doc, arch_img, "Gambar 2.1: Diagram Arsitektur Cloud Backend Supabase PostgreSQL 15 & Keamanan RLS", width=Inches(5.4))

    add_subbab_heading(doc, "2.2", "Spesifikasi Lingkungan Operasional (Technology Stack)")
    add_body_paragraph(
        doc,
        "Spesifikasi teknologi yang digunakan dalam implementasi sistem terangkum dalam tabel berikut:"
    )
    tech_headers = ["Lapisan Sistem", "Teknologi & Versi", "Peranan & Fungsi"]
    tech_data = [
        ["Framework Klien", "Flutter 3.13.3 / Dart 3.0.0", "Penyedia antarmuka responsif Material Design 3, state management, dan navigasi multi-tab."],
        ["Sistem Operasi Target", "Android 8.0 s.d. 14.0 (API 26-34)", "Platform target distribusi aplikasi mobile pada perangkat smartphone civitas akademika."],
        ["Platform Cloud BaaS", "Supabase Cloud Platform", "Penyedia infrastruktur terkelola: Autentikasi, Database PostgreSQL, dan Realtime Engine."],
        ["Mesin Basis Data", "PostgreSQL versi 15.1", "Penyimpanan data relasional terpusat, penguncian baris (row locking), dan stored procedure RPC."],
        ["Layanan Autentikasi", "Supabase Auth (GoTrue Service)", "Manajemen login email/password, hashing Bcrypt, dan penerbitan token JWT terenkripsi."],
        ["Protokol Keamanan", "HTTPS TLS 1.3 & Web Crypto", "Enkripsi end-to-end pada seluruh pertukaran data antara klien mobile dan cloud server."]
    ]
    add_academic_table(doc, "Tabel 2.1: Matriks Spesifikasi Lingkungan Teknologi (Technology Stack)", tech_headers, tech_data, col_widths=[1.5, 2.0, 3.5])

    add_subbab_heading(doc, "2.3", "Mode Operasional Ganda")
    add_body_paragraph(
        doc,
        "Aplikasi LabInventory dirancang adaptif dengan menyediakan dua mode operasional:"
    )
    add_bullet_item(doc, "Aplikasi terhubung langsung ke endpoint Supabase Cloud via HTTPS. Kegagalan jaringan ditangani oleh timeout guard 4 detik dengan pesan error yang informatif tanpa memalsukan data operasional.", bold_prefix="1. Mode Live Operasional: ")
    add_bullet_item(doc, "Disediakan tombol khusus 'Masuk Mode Demo (Tanpa Akun)' pada halaman login. Mode ini menggunakan mock in-memory repository independen untuk memfasilitasi penilaian visual dosen tanpa memerlukan koneksi internet.", bold_prefix="2. Mode Demo In-Memory: ")

    # ================= BAB III: USE CASE =================
    add_bab_heading(doc, "III", "SPESIFIKASI PENGGUNA DAN USE CASE")
    
    add_subbab_heading(doc, "3.1", "Karakteristik Pengguna & Matriks Hak Akses")
    add_body_paragraph(
        doc,
        "Sistem melayani dua aktor utama dengan hak akses yang terisolasi secara ketat oleh database engine:"
    )
    tabel_aktor_headers = ["Aktor Pengguna", "Karakteristik & Profil", "Kewenangan / Hak Akses Sistem"]
    tabel_aktor_data = [
        ["Mahasiswa (`student`)", "Mahasiswa aktif PTI FKIP Unila yang terdaftar di sistem perkuliahan praktikum.", "Melihat katalog alat aktif, cek stok live, mengirim formulir permohonan pinjam, melihat riwayat transaksi sendiri."],
        ["Laboran (`admin`)", "Pengelola laboratorium komputer yang bertanggung jawab atas aset dan tata tertib praktikum.", "Melihat dashboard metrik lab, menyetujui/menolak pengajuan, menginput inventaris alat baru, memproses pengembalian & cek fisik, melihat audit log."]
    ]
    add_academic_table(doc, "Tabel 3.1: Matriks Peran Pengguna dan Hak Akses Sistem", tabel_aktor_headers, tabel_aktor_data, col_widths=[1.4, 2.3, 3.3])

    add_subbab_heading(doc, "3.2", "Diagram Use Case Sistem")
    add_body_paragraph(
        doc,
        "Hubungan fungsional antara aktor pengguna dengan fungsionalitas sistem diilustrasikan pada Diagram Use Case berikut:"
    )

    uc_img = os.path.join(IMG_EVID, "diagram_usecase_sistem.png")
    if os.path.exists(uc_img):
        add_academic_image(doc, uc_img, "Gambar 3.1: Diagram Use Case & Pembagian Peran Aplikasi Mobile LabInventory", width=Inches(5.4))

    add_subbab_heading(doc, "3.3", "Deskripsi Rinci 7 Use Case Pokok")
    add_body_paragraph(
        doc,
        "Berikut dijabarkan rincian spesifikasi alur kerja untuk ketujuh use case pokok mengikuti format baku IEEE:"
    )

    uc_matrix_headers = ["Kode UC", "Nama Use Case", "Aktor", "Preconditions", "Alur Utama (Main Flow)", "Postconditions"]
    uc_matrix_data = [
        ["UC-01", "Autentikasi Pengguna", "Mahasiswa, Laboran", "Aplikasi terpasang; akun terdaftar di Supabase.", "1. Buka aplikasi -> 2. Input email & kata sandi -> 3. Pilih role -> 4. Tekan Masuk -> 5. Token JWT tervalidasi.", "Masuk ke Dashboard sesuai hak akses peran."],
        ["UC-02", "Pencarian Katalog", "Mahasiswa, Laboran", "Pengguna telah berada di halaman katalog.", "1. Masuk tab Inventaris -> 2. Ketik kata kunci / pilih chip kategori -> 3. Daftar alat tersaring real-time.", "Menampilkan daftar alat yang sesuai kriteria."],
        ["UC-03", "Pengajuan Pinjam", "Mahasiswa", "Mahasiswa login; stok alat > 0.", "1. Pilih alat -> 2. Tentukan jumlah unit -> 3. Pilih rentang tanggal (WIB) -> 4. Isi keperluan -> 5. Kirim pengajuan.", "Tiket transaksi tersimpan di database status 'pending'."],
        ["UC-04", "Persetujuan Pinjam", "Laboran", "Pengajuan berstatus 'pending'; Laboran login.", "1. Buka tab Pengajuan -> 2. Tinjau rincian peminjam -> 3. Klik 'Setujui' -> 4. Eksekusi RPC approve_borrowing().", "Status menjadi 'approved'; stok live alat berkurang otomatis."],
        ["UC-05", "Pengembalian Alat", "Laboran", "Peminjaman berstatus 'approved'; alat dikembalikan.", "1. Buka aksi Pengembalian -> 2. Pilih transaksi -> 3. Pilih kondisi (Baik/Rusak) -> 4. Isi catatan -> 5. Konfirmasi.", "Status menjadi 'returned'; stok siap pakai / stok rusak disesuaikan."],
        ["UC-06", "Pendaftaran Alat", "Laboran", "Laboran login; memegang master data alat baru.", "1. Tekan tombol Tambah Barang -> 2. Input nama, kategori, kondisi, stok, lokasi -> 3. Simpan data.", "Baris baru tersimpan di tabel items dengan kode unik otomatis."],
        ["UC-07", "Audit Log Riwayat", "Laboran, Mahasiswa", "Pengguna login; memiliki transaksi lampau.", "1. Buka tab Riwayat -> 2. Sistem memuat log transaksi dari database -> 3. Meninjau status.", "Audit log transaksi laboratorium ditampilkan transparan."]
    ]
    add_academic_table(doc, "Tabel 3.2: Matriks Spesifikasi Detail Alur 7 Use Case Pokok", uc_matrix_headers, uc_matrix_data, col_widths=[0.6, 1.2, 1.0, 1.3, 1.9, 1.0])

    # ================= BAB IV: KEBUTUHAN =================
    add_bab_heading(doc, "IV", "KEBUTUHAN FUNGSIONAL & NON-FUNGSIONAL")
    
    add_subbab_heading(doc, "4.1", "Kebutuhan Fungsional (Functional Requirements)")
    add_body_paragraph(
        doc,
        "Kebutuhan fungsional merincikan kapabilitas operasional yang wajib dipenuhi oleh sistem LabInventory:"
    )
    fr_headers = ["Kode FR", "Nama Fungsionalitas", "Deskripsi Logika & Kriteria Keberhasilan"]
    fr_data = [
        ["FR-01", "Role Guard & Sesi Login", "Sistem memvalidasi token JWT dan mengunci hak akses antarmuka agar mahasiswa tidak dapat mengakses fitur laboran."],
        ["FR-02", "Monitoring Stok Real-time", "Jumlah stok siap pakai pada katalog berkurang seketika di cloud saat transaksi disetujui (approved)."],
        ["FR-03", "Validasi Kalender WIB", "Tanggal mulai pinjam minimal hari ini (WIB) dan tanggal tenggat pengembalian tidak boleh mendahului tanggal pinjam."],
        ["FR-04", "Pencegahan Over-borrowing", "Sistem menolak pengajuan atau persetujuan jika jumlah unit yang diminta melebihi sisa stok siap pakai yang tersedia."],
        ["FR-05", "Klasifikasi Pengembalian Rusak", "Unit yang dikembalikan dalam kondisi rusak otomatis dialihkan ke kolom `stok_rusak` tanpa merusak master barang."],
        ["FR-06", "Auto-generate Kode Inventaris", "Pendaftaran alat baru secara otomatis menghasilkan kode barang dengan format standar laboratorium (`INV-[KAT]-[RANDOM]`)."],
        ["FR-07", "Dashboard Metrik Laboran", "Menampilkan kartu metrik ringkasan total aset aktif, jumlah unit tersedia, dan total antrean pending secara langsung."],
        ["FR-08", "Mode Demo In-Memory", "Menyediakan alternatif pengujian antarmuka tanpa koneksi jaringan menggunakan mock data di memori perangkat."]
    ]
    add_academic_table(doc, "Tabel 4.1: Daftar Spesifikasi Kebutuhan Fungsional Sistem (FR)", fr_headers, fr_data, col_widths=[0.9, 1.8, 4.3])

    add_subbab_heading(doc, "4.2", "Kebutuhan Non-Fungsional (Non-Functional Requirements)")
    add_bullet_item(doc, "Seluruh lalu lintas komunikasi terenkripsi protokol TLS 1.3. Akses tabel dibatasi ketat oleh Row Level Security (RLS) PostgreSQL. Kata sandi di-hash menggunakan algoritma Bcrypt.", bold_prefix="NFR-01 Keamanan (Security): ")
    add_bullet_item(doc, "Transaksi persetujuan dan pengembalian dijalankan dalam satu blok atomik database bergaransi ACID dengan penguncian baris (`FOR UPDATE`) untuk mencegah race condition.", bold_prefix="NFR-02 Integritas Transaksi (ACID): ")
    add_bullet_item(doc, "Setiap request penulisan menyertakan UUID request unik sebagai idempotency key untuk mencegah duplikasi data transaksi akibat sinyal seluler yang tidak stabil.", bold_prefix="NFR-03 Idempotensi Jaringan: ")
    add_bullet_item(doc, "Antarmuka dibangun adaptif pada berbagai ukuran layar Android, mendukung Safe Area sehingga bidang input formulir bebas dari tumpang tindih keyboard virtual.", bold_prefix="NFR-04 Responsivitas & Usability: ")
    add_bullet_item(doc, "Waktu respons rata-rata untuk pengambilan data inventaris di bawah 500ms pada koneksi 4G, dan dilengkapi timeout guard 4 detik untuk mencegah infinite spinner.", bold_prefix="NFR-05 Performa & Keandalan: ")

    # ================= BAB V: BASIS DATA =================
    add_bab_heading(doc, "V", "PERANCANGAN STRUKTUR BASIS DATA RELASIONAL")
    
    add_subbab_heading(doc, "5.1", "Kamus Data & Struktur Tabel Relasional")
    add_body_paragraph(
        doc,
        "Basis data dibangun pada mesin PostgreSQL versi 15 di Supabase Cloud Platform. Seluruh entitas utama menggunakan "
        "Primary Key tipe data UUID v4 untuk menjamin keunikan global dan keamanan data:"
    )

    # Tabel profiles
    add_body_paragraph(doc, "Tabel profiles digunakan untuk menyimpan data identitas dan peran pengguna yang terhubung ke Supabase Auth:", bold_prefix="1. Tabel profiles (Identitas & Hak Akses Pengguna): ")
    db_p_headers = ["Nama Kolom", "Tipe Data", "Batasan / Constraint", "Keterangan Kolom"]
    db_p_data = [
        ["id", "UUID", "PRIMARY KEY, REFERENCES auth.users(id)", "ID unik akun pengguna dari auth.users Supabase"],
        ["nama", "TEXT", "NOT NULL", "Nama lengkap mahasiswa atau laboran"],
        ["npm", "TEXT", "UNIQUE, NULLABLE", "Nomor Pokok Mahasiswa (khusus peran mahasiswa)"],
        ["role", "TEXT", "NOT NULL, CHECK (role IN ('student','admin'))", "Hak akses peran pengguna di dalam sistem"],
        ["created_at", "TIMESTAMPTZ", "DEFAULT NOW()", "Waktu pendaftaran akun ke sistem"]
    ]
    add_academic_table(doc, "Tabel 5.1: Struktur Kamus Data Tabel profiles", db_p_headers, db_p_data, col_widths=[1.2, 1.2, 2.0, 2.6])

    # Tabel items
    add_body_paragraph(doc, "Tabel items menyimpan master data seluruh aset inventaris pada Laboratorium Komputer PTI:", bold_prefix="2. Tabel items (Master Inventaris Laboratorium): ")
    db_i_headers = ["Nama Kolom", "Tipe Data", "Batasan / Constraint", "Keterangan Kolom"]
    db_i_data = [
        ["id", "UUID", "PRIMARY KEY, DEFAULT gen_random_uuid()", "ID unik barang inventaris laboratorium"],
        ["nama_barang", "TEXT", "NOT NULL", "Nama peralatan praktikum (cth: Laptop Lenovo, Proyektor LCD)"],
        ["kode_barang", "TEXT", "NOT NULL, UNIQUE", "Kode unik inventaris lab (cth: INV-CMP-0008)"],
        ["kategori", "TEXT", "NOT NULL", "Kategori alat (Komputer, Elektronik, Aksesoris, Audio)"],
        ["kondisi", "TEXT", "NOT NULL, DEFAULT 'Baik'", "Kondisi fisik alat (Sangat Baik, Baik, Perlu Perbaikan)"],
        ["stok", "INTEGER", "NOT NULL, CHECK (stok >= 0)", "Jumlah unit siap pakai yang tersedia di laboratorium"],
        ["stok_rusak", "INTEGER", "NOT NULL, DEFAULT 0", "Jumlah unit yang rusak dan sedang dalam perbaikan"],
        ["lokasi", "TEXT", "NOT NULL", "Posisi lemari / rak penyimpanan di ruang laboratorium"],
        ["created_at", "TIMESTAMPTZ", "DEFAULT NOW()", "Waktu pencatatan aset inventaris"]
    ]
    add_academic_table(doc, "Tabel 5.2: Struktur Kamus Data Tabel items", db_i_headers, db_i_data, col_widths=[1.2, 1.2, 2.0, 2.6])

    # Tabel borrowings
    add_body_paragraph(doc, "Tabel borrowings mencatat seluruh transaksi permohonan, persetujuan, dan pengembalian alat:", bold_prefix="3. Tabel borrowings (Transaksi Peminjaman Alat): ")
    db_b_headers = ["Nama Kolom", "Tipe Data", "Batasan / Constraint", "Keterangan Kolom"]
    db_b_data = [
        ["id", "UUID", "PRIMARY KEY, DEFAULT gen_random_uuid()", "ID unik transaksi peminjaman"],
        ["user_id", "UUID", "NOT NULL, REFERENCES profiles(id)", "ID mahasiswa yang mengajukan peminjaman"],
        ["item_id", "UUID", "NOT NULL, REFERENCES items(id)", "ID alat laboratorium yang diajukan untuk dipinjam"],
        ["nama_peminjam", "TEXT", "NOT NULL", "Nama lengkap mahasiswa peminjam"],
        ["nama_barang", "TEXT", "NOT NULL", "Nama barang yang dipinjam"],
        ["jumlah", "INTEGER", "NOT NULL, CHECK (jumlah > 0)", "Jumlah unit barang yang diajukan"],
        ["tgl_pinjam", "TIMESTAMPTZ", "NOT NULL", "Waktu awal peminjaman (kalender WIB)"],
        ["tgl_kembali", "TIMESTAMPTZ", "NOT NULL", "Batas tenggat waktu pengembalian alat ke lab"],
        ["keperluan", "TEXT", "NOT NULL", "Uraian kegiatan akademik / mata kuliah praktikum"],
        ["status", "TEXT", "CHECK (status IN ('pending','approved','rejected','returned'))", "Status verifikasi dan penyelesaian transaksi"],
        ["catatan_kondisi", "TEXT", "NULLABLE", "Catatan hasil evaluasi fisik saat barang dikembalikan"],
        ["approved_at", "TIMESTAMPTZ", "NULLABLE", "Waktu persetujuan oleh laboran"],
        ["returned_at", "TIMESTAMPTZ", "NULLABLE", "Waktu pengembalian aktual barang ke lab"],
        ["created_at", "TIMESTAMPTZ", "DEFAULT NOW()", "Waktu pengajuan formulir dikirim"]
    ]
    add_academic_table(doc, "Tabel 5.3: Struktur Kamus Data Tabel borrowings", db_b_headers, db_b_data, col_widths=[1.3, 1.1, 2.0, 2.6])

    add_subbab_heading(doc, "5.2", "Matriks Kebijakan Row Level Security (RLS) PostgreSQL")
    add_body_paragraph(
        doc,
        "Row Level Security (RLS) menjamin bahwa setiap query SQL disaring langsung oleh engine PostgreSQL berdasarkan token autentikasi:"
    )
    rls_headers = ["Tabel Sasaran", "Operasi SQL", "Peran Mahasiswa (`student`)", "Peran Laboran (`admin`)"]
    rls_data = [
        ["profiles", "SELECT", "Hanya membaca baris profil sendiri (id = auth.uid())", "Membaca seluruh baris profil pengguna"],
        ["profiles", "UPDATE", "Ditolak (Hanya dapat diubah admin melalui server)", "Diizinkan mengubah status/role profil"],
        ["items", "SELECT", "Diizinkan membaca seluruh barang aktif (stok > 0)", "Diizinkan membaca seluruh data barang"],
        ["items", "INSERT / UPDATE", "Ditolak (Tidak memiliki izin tulis)", "Diizinkan menambah dan memperbarui stok"],
        ["borrowings", "SELECT", "Hanya membaca permohonan miliknya (user_id = auth.uid())", "Membaca seluruh transaksi peminjaman lab"],
        ["borrowings", "INSERT", "Diizinkan mengajukan peminjaman baru", "Diizinkan membuat catatan peminjaman"],
        ["borrowings", "UPDATE", "Ditolak (Status hanya dapat diubah laboran via RPC)", "Diizinkan mengupdate status via RPC"]
    ]
    add_academic_table(doc, "Tabel 5.4: Matriks Kebijakan Keamanan Row Level Security (RLS)", rls_headers, rls_data, col_widths=[1.2, 1.3, 2.2, 2.3])

    add_subbab_heading(doc, "5.3", "Spesifikasi Stored Procedures RPC (Transaksi Atomik)")
    add_body_paragraph(
        doc,
        "Untuk mencegah race condition dan anomali mutasi data, mutasi stok dijalankan melalui Remote Procedure Call (RPC):"
    )
    add_bullet_item(doc, "Memverifikasi hak laboran, mengunci baris barang dengan `SELECT ... FOR UPDATE`, memeriksa ketersediaan stok, mengurangkan stok secara atomik, dan mengubah status transaksi menjadi `approved`.", bold_prefix="1. RPC approve_borrowing(p_borrowing_id, p_admin_id): ")
    add_bullet_item(doc, "Memeriksa status `approved`. Jika unit kembali 'Baik', stok siap pakai bertambah. Jika 'Rusak', unit dialihkan ke `stok_rusak` dan catatan kerusakan dicatat pada audit log. Status transaksi diubah menjadi `returned`.", bold_prefix="2. RPC return_borrowing(p_borrowing_id, p_is_damaged, p_notes): ")

    # ================= BAB VI: ANTARMUKA =================
    add_bab_heading(doc, "VI", "SPESIFIKASI ANTARMUKA PENGGUNA (USER INTERFACE)")
    add_body_paragraph(
        doc,
        "Berikut merupakan dokumentasi antarmuka pengguna hasil pengujian nyata pada perangkat fisik Android (Physical Device Testing), "
        "yang mencakup seluruh alur operasional mahasiswa dan laboran:"
    )

    screenshots_srd = [
        ("01-login.png", "Gambar 6.1: Antarmuka Autentikasi Pengguna & Tombol Masuk Mode Demo Instan"),
        ("10-catalog-search.png", "Gambar 6.2: Katalog Inventaris Real-time Dilengkapi Fitur Pencarian & Filter Kategori"),
        ("08-laptop-detail.png", "Gambar 6.3: Halaman Rincian Spesifikasi Alat, Status Kondisi, dan Posisi Lemari/Rak"),
        ("02-student-form.png", "Gambar 6.4: Formulir Digital Pengajuan Peminjaman Alat Mahasiswa"),
        ("05-form-safe-area-fixed.png", "Gambar 6.5: Bukti Perbaikan Layout Safe Area: Bidang Input Bebas Tumpang Tindih Keyboard"),
        ("03-admin-approved.png", "Gambar 6.6: Dashboard Laboran Live: Menampilkan Metrik Cloud & Antrean Pengajuan"),
        ("04-student-pending.png", "Gambar 6.7: Halaman Peminjaman Mahasiswa: Status 'PENDING' Terupdate Otomatis dari Cloud"),
        ("09-admin-created-item.png", "Gambar 6.8: Formulir Tambah Alat Baru oleh Laboran yang Langsung Mengupdate Tabel Items"),
        ("06-damaged-return.png", "Gambar 6.9: Dialog Pengembalian Alat oleh Laboran dengan Pilihan Rusak & Catatan Evaluasi"),
        ("07-stock-after-damage.png", "Gambar 6.10: Pembaruan Otomatis Stok Siap Pakai & Pencatatan Stok Rusak pada Detail Alat"),
        ("11-final-history.png", "Gambar 6.11: Audit Log Lengkap Riwayat Transaksi Seluruh Laboratorium Komputer PTI"),
        ("12-student-final-history.png", "Gambar 6.12: Riwayat Akhir Mahasiswa dengan Status Transaksi 'RETURNED' / Selesai")
    ]

    for filename, caption in screenshots_srd:
        full_path = os.path.join(IMG_DEV, filename)
        if os.path.exists(full_path):
            add_academic_image(doc, full_path, caption, width=Inches(3.1))

    # ================= BAB VII: PENUTUP =================
    add_bab_heading(doc, "VII", "KESIMPULAN DAN REKOMENDASI TINGKAT LANJUT")
    add_subbab_heading(doc, "7.1", "Kesimpulan Ketercapaian Rekayasa Kebutuhan")
    add_body_paragraph(
        doc,
        "Penyusunan dokumen Software Requirement Document (SRD) versi 2.0 ini berhasil menyelaraskan seluruh spesifikasi kebutuhan "
        "perangkat lunak dengan implementasi final aplikasi LabInventory. Penggunaan Flutter pada sisi klien dan Supabase PostgreSQL 15 "
        "pada sisi backend cloud terbukti mampu menyelesaikan permasalahan pencatatan manual di Laboratorium Komputer PTI FKIP Unila "
        "secara andal, aman melalui Row Level Security, bergaransi integritas ACID melalui stored procedure RPC, serta siap dioperasikan "
        "secara nyata oleh mahasiswa dan laboran."
    )
    add_subbab_heading(doc, "7.2", "Rekomendasi Pengembangan Tingkat Lanjut")
    add_body_paragraph(
        doc,
        "Untuk pengembangan pada fase selanjutnya, direkomendasikan penambahan modul pemindai barcode / QR Code pada stiker fisik alat "
        "untuk mempercepat verifikasi serah-terima di ruang laboratorium, serta integrasi layanan push notification (Firebase Cloud Messaging) "
        "untuk memberikan pengingat tenggat waktu pengembalian kepada mahasiswa."
    )

    # Daftar Pustaka
    add_daftar_pustaka(doc, DAFTAR_PUSTAKA_SRD)

    # Save to root and docs/
    target_root = os.path.abspath("SOFTWARE REQUIREMENT DOCUMENT.docx")
    target_docs = os.path.abspath("docs/SOFTWARE_REQUIREMENT_DOCUMENT_v2.docx")
    doc.save(target_root)
    doc.save(target_docs)
    print(f"Master SRD v2 generated successfully at:\n- {target_root}\n- {target_docs}")

if __name__ == "__main__":
    build_full_srd_v2()
