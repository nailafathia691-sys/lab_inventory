import os
import sys
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

from doc_builder import (
    NAVY, SAPPHIRE, DARK_GRAY, MUTED_GRAY, WHITE,
    add_header_styled, add_paragraph_styled, add_bullet_styled,
    add_callout, add_styled_table, add_image_styled,
    set_cell_background, set_cell_margins, set_table_borders
)

def build_srd_v2():
    doc = docx.Document()
    
    # Page setup - Margins 1 inch
    for section in doc.sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.1)
        section.right_margin = Inches(1.0)
        
    # COVER / HEADER TITLE
    p_title_pre = doc.add_paragraph()
    p_title_pre.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title_pre.paragraph_format.space_before = Pt(20)
    p_title_pre.paragraph_format.space_after = Pt(4)
    r_doc = p_title_pre.add_run("SOFTWARE REQUIREMENT DOCUMENT (SRD)")
    r_doc.font.name = "Arial"
    r_doc.font.size = Pt(18)
    r_doc.bold = True
    r_doc.font.color.rgb = NAVY
    
    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_after = Pt(8)
    r_sub = p_sub.add_run("Sistem Informasi Manajemen Inventaris dan Peminjaman Alat Laboratorium Komputer Berbasis Mobile")
    r_sub.font.name = "Arial"
    r_sub.font.size = Pt(12)
    r_sub.bold = True
    r_sub.font.color.rgb = SAPPHIRE
    
    p_app = doc.add_paragraph()
    p_app.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_app.paragraph_format.space_after = Pt(4)
    r_app = p_app.add_run("LABINVENTORY — VERSION 2.0")
    r_app.font.name = "Arial"
    r_app.font.size = Pt(15)
    r_app.bold = True
    r_app.font.color.rgb = NAVY
    
    # Embed Logo if exists
    logo_path = os.path.abspath("assets/images/lab_inventory_logo.png")
    if os.path.exists(logo_path):
        add_image_styled(doc, logo_path, "Logo Resmi Aplikasi LabInventory PTI FKIP Universitas Lampung", width=Inches(1.8))
        
    # Metadata Table
    meta_headers = ["Informasi Dokumen", "Keterangan"]
    meta_data = [
        ["Mata Kuliah", "Pemrograman Mobile (Mobile Programming)"],
        ["Program Studi", "S1 Pendidikan Teknologi Informasi (PTI)"],
        ["Jurusan / Fakultas", "Pendidikan MIPA / Keguruan dan Ilmu Pendidikan"],
        ["Perguruan Tinggi", "Universitas Lampung (UNILA)"],
        ["Dosen Pengampu", "Ghea Chandra Surawan, M.Pd."],
        ["Disusun Oleh", "Naila Fathia"],
        ["NPM Mahasiswa", "2413025076"],
        ["Tanggal Pembaruan", "19 Oktober 2026 (Revisi v2.0)"],
        ["Status Implementasi", "Terverifikasi Penuh — Terhubung Cloud Supabase Realtime & RLS"]
    ]
    add_styled_table(doc, meta_headers, meta_data, col_widths=[2.5, 4.0])
    
    doc.add_page_break()
    
    # RIWAYAT REVISI DOKUMEN
    add_header_styled(doc, "Riwayat Revisi Dokumen", level=1)
    add_paragraph_styled(
        doc,
        "Setiap modifikasi arsitektural dan spesifikasi kebutuhan dicatat secara berkala guna menjamin transparansi serta kepatuhan implementasi terhadap rancangan teknis yang disepakati."
    )
    
    rev_headers = ["Versi", "Tanggal", "Deskripsi Perubahan", "Penulis"]
    rev_data = [
        [
            "1.0",
            "03 Sept 2026",
            "Draf awal dokumen SRD: Pendahuluan, arsitektur dasar, rancangan use case, spesifikasi antarmuka awal, dan konsep awal MySQL.",
            "Naila Fathia"
        ],
        [
            "2.0",
            "19 Okt 2026",
            "Pembaruan menyeluruh (v2.0): Migrasi arsitektur dari PHP/MySQL ke Flutter + Supabase (PostgreSQL 15, Supabase Auth, Row Level Security / RLS, dan RPC Transactional Function untuk integritas stok atomik), skema UUID, penghapusan dummy data, penyertaan diagram use case & arsitektur, dan hasil pengujian perangkat fisik Android.",
            "Naila Fathia"
        ]
    ]
    add_styled_table(doc, rev_headers, rev_data, col_widths=[0.8, 1.2, 3.5, 1.0])
    
    # BAB I: PENDAHULUAN
    add_header_styled(doc, "BAB I. PENDAHULUAN", level=1)
    
    add_header_styled(doc, "1.1 Latar Belakang", level=2)
    add_paragraph_styled(
        doc,
        "Laboratorium Komputer pada Program Studi Pendidikan Teknologi Informasi (PTI), FKIP Universitas Lampung, mengelola puluhan perangkat praktikum seperti laptop mahasiswa, proyektor LCD, switch jaringan, instrumen kabel, serta perangkat multimedia. Sebelumnya, proses pendataan barang dan permohonan peminjaman praktikum masih mengandalkan buku catatan fisik formulir kertas."
    )
    add_paragraph_styled(
        doc,
        "Metode manual tersebut memiliki berbagai kelemahan mendasar: tingginya risiko kehilangan catatan, kesulitan melacak status ketersediaan stok alat secara instan, tidak adanya verifikasi kondisi saat pengembalian, serta antrean administratif yang memakan waktu mahasiswa dan laboran. Oleh karena itu, dikembangkan sistem aplikasi mobile 'LabInventory' guna memodernisasi tata kelola inventaris secara digital, transparan, dan real-time."
    )
    
    add_header_styled(doc, "1.2 Gambaran Umum Sistem", level=2)
    add_paragraph_styled(
        doc,
        "LabInventory adalah aplikasi mobile berbasis Flutter yang terintegrasi secara langsung dengan PostgreSQL Cloud Database via Supabase. Sistem melayani dua peran utama:"
    )
    add_bullet_styled(doc, "Dapat menelusuri katalog alat lengkap, memeriksa stok siap pakai secara langsung, mengajukan peminjaman dengan formulir digital, serta memantau status persetujuan dari mana saja.", bold_prefix="Mahasiswa: ")
    add_bullet_styled(doc, "Menerima notifikasi pengajuan masuk, memvalidasi dan menyetujui/menolak permohonan, mencatat mutasi penambahan alat baru, memproses pengembalian dengan inspeksi kondisi (Baik / Rusak), serta meninjau riwayat transaksi seluruh lab.", bold_prefix="Laboran / Admin: ")
    
    add_header_styled(doc, "1.3 Tujuan dan Manfaat", level=2)
    add_paragraph_styled(doc, "Tujuan utama pengembangan sistem meliputi:")
    add_bullet_styled(doc, "Mentransformasi birokrasi peminjaman manual menjadi alur digital yang efisien dan akuntabel.")
    add_bullet_styled(doc, "Mencegah kesalahan alokasi unit (double-booking) melalui transaksi database yang atomik (ACID via RPC).")
    add_bullet_styled(doc, "Menyediakan audit trail transparan mengenai riwayat keluar-masuk barang serta kondisi fisik alat pasca praktikum.")
    
    add_callout(
        doc,
        "Pada versi 2.0 ini, seluruh data inventaris dan transaksi telah 100% terhubung secara live ke Supabase PostgreSQL Cloud. Penggunaan data dummy lokal telah sepenuhnya dihilangkan dari sistem operasional.",
        title="Keputusan Arsitektur v2.0"
    )
    
    # BAB II: ARSITEKTUR DAN LINGKUNGAN OPERASIONAL
    add_header_styled(doc, "BAB II. ARSITEKTUR DAN LINGKUNGAN OPERASIONAL", level=1)
    
    add_header_styled(doc, "2.1 Arsitektur Sistem & Technology Stack", level=2)
    add_paragraph_styled(
        doc,
        "Sistem menerapkan arsitektur Clean Architecture pada sisi klien Flutter dengan pola Repository Pattern yang berkomunikasi aman ke Supabase Cloud Platform. Keamanan data tidak diletakkan pada logika klien, melainkan ditegakkan langsung di level database engine menggunakan Row Level Security (RLS) PostgreSQL."
    )
    
    arch_img = os.path.abspath("docs/evidence/diagram_arsitektur_sistem.png")
    if os.path.exists(arch_img):
        add_image_styled(doc, arch_img, "Gambar 2.1 Diagram Arsitektur Cloud, Gateway Keamanan, dan Database Supabase PostgreSQL 15", width=Inches(5.6))
        
    tech_headers = ["Lapisan / Layer", "Teknologi & Versi", "Fungsi & Tanggung Jawab"]
    tech_data = [
        ["Mobile Client", "Flutter 3.13+ / Dart 3+", "Antarmuka responsif Material Design 3, state management, offline-fallback demo."],
        ["Autentikasi", "Supabase Auth (GoTrue)", "Manajemen sesi aman berbasis token JWT, sanitasi pendaftaran, login role-based."],
        ["Cloud Database", "PostgreSQL 15 (Supabase Cloud)", "Penyimpanan data relasional terpusat, foreign keys, index performa."],
        ["Otorisasi & Keamanan", "Row Level Security (RLS)", "Aturan hak akses baris: Mahasiswa hanya membaca miliknya, Admin mengelola seluruh lab."],
        ["Integritas Transaksi", "PostgreSQL RPC Functions", "Stored procedure atomik (`approve_borrowing`, `return_borrowing`) bergaransi ACID."],
        ["Aset Grafis & Media", "Vector Mipmaps & Cloud Storage", "Penyajian gambar foto alat dan logo resolusi tinggi tanpa distorsi layout."]
    ]
    add_styled_table(doc, tech_headers, tech_data, col_widths=[1.5, 2.0, 3.0])
    
    add_header_styled(doc, "2.2 Mode Operasional", level=2)
    add_paragraph_styled(
        doc,
        "Aplikasi beroperasi dalam 2 mode yang terisolasi secara tegas:"
    )
    add_bullet_styled(doc, "Menggunakan koneksi HTTPS terenkripsi ke endpoint Supabase. Kegagalan jaringan ditangani secara eksplisit dengan timeout guard (4 detik) dan pesan error yang informatif tanpa memalsukan data.", bold_prefix="Mode Live Operasional: ")
    add_bullet_styled(doc, "Disediakan tombol 'Masuk Mode Demo' untuk keperluan presentasi atau pengujian cepat tanpa memerlukan koneksi internet, menggunakan In-Memory Repository independen.", bold_prefix="Mode Demo Instan: ")
    
    # BAB III: USE CASE DAN SPESIFIKASI DATA
    add_header_styled(doc, "BAB III. SPESIFIKASI PENGGUNA DAN USE CASE", level=1)
    
    usecase_img = os.path.abspath("docs/evidence/diagram_usecase_sistem.png")
    if os.path.exists(usecase_img):
        add_image_styled(doc, usecase_img, "Gambar 3.1 Diagram Use Case & Pembagian Peran Aplikasi Mobile LabInventory", width=Inches(5.6))
        
    uc_headers = ["Kode", "Nama Use Case", "Aktor Utama", "Deskripsi Alur Sistem"]
    uc_data = [
        ["UC-01", "Autentikasi & Validasi Peran", "Mahasiswa, Laboran", "Pengguna memasukkan email dan kata sandi. Supabase Auth memvalidasi token dan server mencocokkan role pada tabel `profiles`."],
        ["UC-02", "Pencarian & Filter Katalog", "Mahasiswa, Laboran", "Melihat daftar alat aktif, filter per kategori (Komputer, Elektronik, Aksesoris), dan pencarian real-time."],
        ["UC-03", "Pengajuan Peminjaman Alat", "Mahasiswa", "Mahasiswa memilih alat, menentukan jumlah unit, tanggal pinjam & kembali, serta menginput tujuan praktikum."],
        ["UC-04", "Verifikasi & Persetujuan (Approve/Reject)", "Laboran", "Laboran meninjau pengajuan. Jika disetujui, RPC memverifikasi stok dan mengalokasikan unit secara atomik."],
        ["UC-05", "Pencatatan Pengembalian & Cek Fisik", "Laboran", "Laboran menginspeksi fisik alat (Kondisi Baik atau Rusak), mencatat evaluasi, dan sistem mengembalikan stok siap pakai / stok rusak."],
        ["UC-06", "Pendaftaran Inventaris Baru", "Laboran", "Laboran menambahkan alat baru dengan kode inventaris otomatis (`INV-[KAT]-[RANDOM]`), kondisi, stok awal, dan lokasi rak."],
        ["UC-07", "Audit Log & Riwayat Transaksi", "Laboran, Mahasiswa", "Mahasiswa melihat riwayat transaksi pribadinya, sedangkan Laboran melihat audit log seluruh transaksi laboratorium."]
    ]
    add_styled_table(doc, uc_headers, uc_data, col_widths=[0.8, 1.8, 1.2, 2.7])
    
    # Spesifikasi Use Case Detail
    add_header_styled(doc, "3.1 Spesifikasi Detail Use Case Pokok", level=2)
    add_paragraph_styled(doc, "Tabel di bawah menguraikan kondisi prasyarat (preconditions), alur utama (main flow), dan kondisi akhir (postconditions) untuk setiap use case:", bold_prefix="Spesifikasi Alur: ")
    
    uc_detail_headers = ["Kode UC", "Preconditions", "Main Flow", "Postconditions"]
    uc_detail_data = [
        ["UC-01", "Pengguna memiliki akun Supabase Auth.", "Input email & password -> Submit -> Token JWT diverifikasi -> Redirect ke Dashboard sesuai role.", "Sesi tersimpan lokal; role guard aktif."],
        ["UC-03", "Mahasiswa sudah login; stok barang > 0.", "Pilih alat -> Masukkan jumlah unit -> Pilih tanggal (WIB) -> Input keperluan -> Kirim.", "Row transaksi dibuat di tabel borrowings status 'pending'."],
        ["UC-04", "Pengajuan berstatus 'pending'; Laboran sudah login.", "Buka antrean -> Klik 'Setujui' -> Eksekusi RPC approve_borrowing() -> Stok berkurang.", "Status transaksi menjadi 'approved'; stok live terupdate."],
        ["UC-05", "Pengajuan berstatus 'approved'; alat dikembalikan.", "Pilih transaksi -> Pilih kondisi (Baik/Rusak) -> Input catatan -> Konfirmasi pengembalian.", "Status transaksi menjadi 'returned'; stok siap/rusak disesuaikan."]
    ]
    add_styled_table(doc, uc_detail_headers, uc_detail_data, col_widths=[0.8, 1.7, 2.3, 1.7])

    # BAB IV: KEBUTUHAN FUNGSIONAL DAN NON-FUNGSIONAL
    add_header_styled(doc, "BAB IV. KEBUTUHAN FUNGSIONAL & NON-FUNGSIONAL", level=1)
    
    add_header_styled(doc, "4.1 Kebutuhan Fungsional (Functional Requirements)", level=2)
    fr_headers = ["Kode", "Nama Kebutuhan", "Spesifikasi Implementasi Sistem"]
    fr_data = [
        ["FR-01", "Manajemen Sesi & Role Guard", "Sistem membatasi navigasi mahasiswa hanya pada fitur peminjam dan admin pada fitur manajemen lab."],
        ["FR-02", "Monitoring Stok Real-time", "Stok inventaris terupdate secara live di cloud saat transaksi disetujui atau dikembalikan."],
        ["FR-03", "Validasi Tanggal Kalender", "Tanggal pinjam minimal hari ini (WIB) dan tanggal kembali tidak boleh lebih awal dari tanggal pinjam."],
        ["FR-04", "Pencegahan Over-borrowing", "Pengajuan tidak dapat melebihi batas stok tersedia pada saat form dikirim maupun saat diapprove."],
        ["FR-05", "Klasifikasi Pengembalian Rusak", "Unit yang dikembalikan dalam kondisi rusak otomatis dialihkan ke `stok_rusak` tanpa mengubah status barang sehat lainnya."],
        ["FR-06", "Pemberian Kode Otomatis", "Pendaftaran alat baru menghasilkan kode unik format standar laboratorium."],
        ["FR-07", "Dashboard Metrik Laboran", "Menghitung total aset aktif, jumlah antrean pending, dan rekapitulasi status secara instan."]
    ]
    add_styled_table(doc, fr_headers, fr_data, col_widths=[0.8, 1.8, 3.9])
    
    add_header_styled(doc, "4.2 Kebutuhan Non-Fungsional (Non-Functional Requirements)", level=2)
    add_bullet_styled(doc, "Seluruh pertukaran data dilindungi protokol TLS 1.3. Akses tabel dibatasi kebijakan RLS PostgreSQL. Password di-hash menggunakan algoritma Bcrypt via GoTrue.", bold_prefix="NFR-01 Keamanan: ")
    add_bullet_styled(doc, "Eksekusi persetujuan dan pengembalian dijalankan dalam satu blok transaksi database PostgreSQL (`BEGIN ... COMMIT`) untuk mencegah anomali data.", bold_prefix="NFR-02 Integritas Transaksi: ")
    add_bullet_styled(doc, "Setiap request penulisan menyertakan UUID unik sebagai idempotency key untuk mencegah pengiriman ganda akibat sinyal seluler yang tidak stabil.", bold_prefix="NFR-03 Idempotensi Jaringan: ")
    add_bullet_styled(doc, "Antarmuka dirancang adaptif terhadap berbagai ukuran layar smartphone Android, mendukung Safe Area (bebas tumpang tindih keyboard/notch).", bold_prefix="NFR-04 Responsivitas Antarmuka: ")
    add_bullet_styled(doc, "Waktu respons server untuk query inventaris rata-rata di bawah 500ms pada koneksi jaringan 4G stabil.", bold_prefix="NFR-05 Performa & Kecepatan: ")
    
    # BAB V: PERANCANGAN STRUKTUR DATABASE
    add_header_styled(doc, "BAB V. PERANCANGAN STRUKTUR DATABASE", level=1)
    add_paragraph_styled(
        doc,
        "Database dibangun pada PostgreSQL 15 di Supabase Cloud Platform. Skema terdiri atas tabel entitas inti, relasi foreign key, serta fungsi transaksi."
    )
    
    add_header_styled(doc, "5.1 Tabel: profiles (Profil Pengguna)", level=2)
    db_p_headers = ["Nama Kolom", "Tipe Data", "Batasan / Constraint", "Keterangan"]
    db_p_data = [
        ["id", "UUID", "PRIMARY KEY, REFERENCES auth.users(id)", "ID unik akun pengguna dari Supabase Auth"],
        ["nama", "TEXT", "NOT NULL", "Nama lengkap mahasiswa atau laboran"],
        ["npm", "TEXT", "UNIQUE, NULLABLE", "Nomor Pokok Mahasiswa (khusus mahasiswa)"],
        ["role", "TEXT", "NOT NULL, CHECK (role IN ('student','admin'))", "Hak akses peran pengguna dalam sistem"],
        ["created_at", "TIMESTAMPTZ", "DEFAULT NOW()", "Waktu pembuatan akun"]
    ]
    add_styled_table(doc, db_p_headers, db_p_data, col_widths=[1.2, 1.2, 2.0, 2.1])
    
    add_header_styled(doc, "5.2 Tabel: items (Inventaris Barang Laboratorium)", level=2)
    db_i_headers = ["Nama Kolom", "Tipe Data", "Batasan / Constraint", "Keterangan"]
    db_i_data = [
        ["id", "UUID", "PRIMARY KEY, DEFAULT gen_random_uuid()", "ID unik barang inventaris"],
        ["nama_barang", "TEXT", "NOT NULL", "Nama alat (cth: Laptop Lenovo, Proyektor Epson)"],
        ["kode_barang", "TEXT", "NOT NULL, UNIQUE", "Kode inventaris lab (cth: INV-CMP-0008)"],
        ["kategori", "TEXT", "NOT NULL", "Komputer, Elektronik, Aksesoris, Audio"],
        ["kondisi", "TEXT", "NOT NULL, DEFAULT 'Baik'", "Sangat Baik, Baik, Perlu Perbaikan"],
        ["stok", "INTEGER", "NOT NULL, CHECK (stok >= 0)", "Jumlah unit siap pakai yang tersedia"],
        ["stok_rusak", "INTEGER", "NOT NULL, DEFAULT 0", "Jumlah unit yang rusak dan dalam perbaikan"],
        ["lokasi", "TEXT", "NOT NULL", "Lokasi rak / lemari di laboratorium PTI"],
        ["created_at", "TIMESTAMPTZ", "DEFAULT NOW()", "Waktu pencatatan aset"]
    ]
    add_styled_table(doc, db_i_headers, db_i_data, col_widths=[1.2, 1.2, 2.0, 2.1])
    
    add_header_styled(doc, "5.3 Tabel: borrowings (Transaksi Peminjaman)", level=2)
    db_b_headers = ["Nama Kolom", "Tipe Data", "Batasan / Constraint", "Keterangan"]
    db_b_data = [
        ["id", "UUID", "PRIMARY KEY, DEFAULT gen_random_uuid()", "ID unik transaksi peminjaman"],
        ["user_id", "UUID", "NOT NULL, REFERENCES profiles(id)", "ID mahasiswa yang mengajukan peminjaman"],
        ["item_id", "UUID", "NOT NULL, REFERENCES items(id)", "ID alat yang dipinjam"],
        ["nama_peminjam", "TEXT", "NOT NULL", "Nama lengkap peminjam"],
        ["nama_barang", "TEXT", "NOT NULL", "Nama barang yang dipinjam"],
        ["jumlah", "INTEGER", "NOT NULL, CHECK (jumlah > 0)", "Jumlah unit yang diajukan"],
        ["tgl_pinjam", "TIMESTAMPTZ", "NOT NULL", "Tanggal awal masa peminjaman"],
        ["tgl_kembali", "TIMESTAMPTZ", "NOT NULL", "Tenggat waktu pengembalian alat"],
        ["keperluan", "TEXT", "NOT NULL", "Alasan praktikum / kegiatan akademik"],
        ["status", "TEXT", "CHECK (status IN ('pending','approved','rejected','returned'))", "Status persetujuan dan transaksi"],
        ["catatan_kondisi", "TEXT", "NULLABLE", "Catatan hasil inspeksi fisik oleh laboran"],
        ["approved_at", "TIMESTAMPTZ", "NULLABLE", "Waktu persetujuan oleh laboran"],
        ["returned_at", "TIMESTAMPTZ", "NULLABLE", "Waktu pengembalian aktual barang"],
        ["created_at", "TIMESTAMPTZ", "DEFAULT NOW()", "Waktu pengajuan dikirim"]
    ]
    add_styled_table(doc, db_b_headers, db_b_data, col_widths=[1.3, 1.1, 2.0, 2.1])
    
    # BAB VI: SPESIFIKASI LOGIKA TRANSAKSI ATOMIK (RPC)
    add_header_styled(doc, "BAB VI. SPESIFIKASI TRANSAKSI ATOMIK (STORED PROCEDURES)", level=1)
    add_paragraph_styled(
        doc,
        "Untuk mencegah anomali race condition pada kuantitas stok barang, seluruh mutasi transaksi dikunci dalam PostgreSQL RPC:"
    )
    add_bullet_styled(doc, "Memverifikasi hak laboran, mengunci baris barang (`SELECT ... FOR UPDATE`), memeriksa ketersediaan stok, mengurangkan stok, dan mengubah status peminjaman menjadi `approved` dalam 1 transaksi atomik.", bold_prefix="Fungsi approve_borrowing(p_borrowing_id, p_admin_id): ")
    add_bullet_styled(doc, "Memeriksa status `approved`, membaca kondisi fisik yang diinput laboran. Jika Baik: menambah `stok`. Jika Rusak: menambah `stok_rusak` dan mencatat evaluasi kerusakan pada kolom `catatan_kondisi`. Status diubah menjadi `returned`.", bold_prefix="Fungsi return_borrowing(p_borrowing_id, p_is_damaged, p_notes): ")

    # BAB VII: SPESIFIKASI ANTARMUKA PENGGUNA (HASIL TANGKAPAN LAYAR)
    add_header_styled(doc, "BAB VII. SPESIFIKASI ANTARMUKA PENGGUNA", level=1)
    add_paragraph_styled(
        doc,
        "Berikut merupakan dokumentasi antarmuka pengguna hasil kompilasi langsung pada perangkat fisik Android (Physical Device Testing):"
    )
    
    img_dir = os.path.abspath("docs/evidence/device")
    
    screenshots = [
        ("01-login.png", "Gambar 7.1 Antarmuka Autentikasi Pengguna (Login Mahasiswa & Laboran dengan Opsi Demo)"),
        ("10-catalog-search.png", "Gambar 7.2 Katalog Inventaris Real-time Dilengkapi Fitur Pencarian & Filter Kategori"),
        ("08-laptop-detail.png", "Gambar 7.3 Halaman Rincian Alat (Spesifikasi, Lokasi Lemari, dan Ketersediaan Stok)"),
        ("02-student-form.png", "Gambar 7.4 Formulir Digital Pengajuan Peminjaman Alat Mahasiswa"),
        ("03-admin-approved.png", "Gambar 7.5 Dashboard Laboran dengan Fitur Verifikasi & Persetujuan Cepat"),
        ("06-damaged-return.png", "Gambar 7.6 Dialog Verifikasi Pengembalian Alat dengan Inspeksi Kondisi Fisik"),
        ("09-admin-created-item.png", "Gambar 7.7 Formulir Pendaftaran Alat Baru oleh Laboran"),
        ("11-final-history.png", "Gambar 7.8 Audit Log & Riwayat Lengkap Seluruh Transaksi Laboratorium")
    ]
    
    for filename, caption in screenshots:
        full_path = os.path.join(img_dir, filename)
        if os.path.exists(full_path):
            add_image_styled(doc, full_path, caption, width=Inches(3.2))
            
    # BAB VIII: KESIMPULAN
    add_header_styled(doc, "BAB VIII. KESIMPULAN DAN REKOMENDASI", level=1)
    add_paragraph_styled(
        doc,
        "Pembaruan SRD versi 2.0 ini berhasil menyelaraskan dokumen perancangan dengan implementasi final aplikasi LabInventory. Penggunaan Flutter dan Supabase PostgreSQL terbukti mampu menyelesaikan permasalahan pencatatan manual di Laboratorium Komputer PTI FKIP Unila secara aman, real-time, dan mudah dioperasikan baik oleh mahasiswa maupun laboran."
    )
    
    # Sign-off block
    p_sign = doc.add_paragraph()
    p_sign.paragraph_format.space_before = Pt(20)
    p_sign.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    r_sign = p_sign.add_run("Bandar Lampung, 19 Oktober 2026\nPengembang Aplikasi,\n\n\n\nNaila Fathia\nNPM. 2413025076")
    r_sign.font.name = "Arial"
    r_sign.font.size = Pt(10)
    r_sign.bold = True
    r_sign.font.color.rgb = DARK_GRAY
    
    # Save documents
    target_v2 = os.path.abspath("SOFTWARE REQUIREMENT DOCUMENT_v2.docx")
    target_root = os.path.abspath("SOFTWARE REQUIREMENT DOCUMENT.docx")
    
    doc.save(target_v2)
    doc.save(target_root)
    print(f"SRD v2 generated successfully at:\n- {target_v2}\n- {target_root}")

if __name__ == "__main__":
    build_srd_v2()
