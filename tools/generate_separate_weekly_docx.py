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

LOGO_PATH = os.path.abspath("assets/images/lab_inventory_logo.png")
ICON_PATH = os.path.abspath("assets/images/app_icon.png")
IMG_DIR = os.path.abspath("docs/evidence/device")
EVID_DIR = os.path.abspath("docs/evidence")

def setup_page(doc):
    for sec in doc.sections:
        sec.top_margin = Inches(1.0)
        sec.bottom_margin = Inches(1.0)
        sec.left_margin = Inches(1.1)
        sec.right_margin = Inches(1.0)

def add_standard_cover(doc, minggu_romawi, minggu_angka, topik_minggu, tgl_str):
    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_before = Pt(20)
    p_title.paragraph_format.space_after = Pt(4)
    r1 = p_title.add_run(f"LAPORAN KEMAJUAN MINGGUAN — MINGGU {minggu_romawi}")
    r1.font.name = "Arial"
    r1.font.size = Pt(17)
    r1.bold = True
    r1.font.color.rgb = NAVY

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_after = Pt(4)
    r2 = p_sub.add_run(topik_minggu.upper())
    r2.font.name = "Arial"
    r2.font.size = Pt(11)
    r2.bold = True
    r2.font.color.rgb = SAPPHIRE

    p_proj = doc.add_paragraph()
    p_proj.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_proj.paragraph_format.space_after = Pt(12)
    r3 = p_proj.add_run("PENGEMBANGAN SISTEM INVENTARIS & PEMINJAMAN ALAT LABORATORIUM KOMPUTER BERBASIS MOBILE (LABINVENTORY)")
    r3.font.name = "Arial"
    r3.font.size = Pt(9.5)
    r3.font.color.rgb = DARK_GRAY

    if os.path.exists(LOGO_PATH):
        add_image_styled(doc, LOGO_PATH, "Logo Resmi Aplikasi LabInventory PTI FKIP Universitas Lampung", width=Inches(1.6))

    meta_headers = ["Komponen Informasi", "Keterangan"]
    meta_data = [
        ["Nama Mahasiswa", "Naila Fathia"],
        ["NPM", "2413025076"],
        ["Mata Kuliah", "Pemrograman Mobile (Mobile Programming)"],
        ["Dosen Pengampu", "Ghea Chandra Surawan, M.Pd."],
        ["Program Studi", "S1 Pendidikan Teknologi Informasi (PTI)"],
        ["Jurusan / Fakultas", "Pendidikan MIPA / Keguruan dan Ilmu Pendidikan (FKIP)"],
        ["Perguruan Tinggi", "Universitas Lampung (UNILA)"],
        ["Tahap / Periode", f"Minggu ke-{minggu_angka} ({tgl_str})"],
        ["Status Capaian", "Selesai 100% — Terverifikasi Pengujian & Dokumentasi Lengkap"]
    ]
    add_styled_table(doc, meta_headers, meta_data, col_widths=[2.3, 4.0])
    doc.add_page_break()

def add_signoff(doc, tgl_lengkap):
    p_sign = doc.add_paragraph()
    p_sign.paragraph_format.space_before = Pt(22)
    p_sign.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    r_sign = p_sign.add_run(
        f"Bandar Lampung, {tgl_lengkap}\n"
        "Mahasiswa Pengembang,\n\n\n\n\n"
        "Naila Fathia\n"
        "NPM. 2413025076"
    )
    r_sign.font.name = "Arial"
    r_sign.font.size = Pt(10)
    r_sign.bold = True
    r_sign.font.color.rgb = DARK_GRAY


# ===================== MINGGU 1 =====================
def generate_minggu_1():
    doc = docx.Document()
    setup_page(doc)
    add_standard_cover(
        doc,
        minggu_romawi="I",
        minggu_angka="1",
        topik_minggu="Inisiasi Proyek, Analisis Kebutuhan, Use Case Diagram, Wireframe & Setup Flutter",
        tgl_str="03 – 09 September 2026"
    )

    add_header_styled(doc, "1. Latar Belakang & Analisis Permasalahan Lapangan", level=1)
    add_paragraph_styled(
        doc,
        "Laboratorium Komputer pada Program Studi Pendidikan Teknologi Informasi (PTI), FKIP Universitas Lampung, "
        "mengelola puluhan perangkat praktikum seperti laptop mahasiswa, proyektor LCD Epson, switch hub, instrumen kabel, "
        "serta perangkat multimedia. Sebelum inisiasi proyek LabInventory, seluruh proses pencatatan inventaris dan "
        "permohonan peminjaman masih dijalankan secara manual menggunakan formulir fisik kertas."
    )
    add_paragraph_styled(
        doc,
        "Berdasarkan analisis observasi lapangan, metode konvensional tersebut menimbulkan berbagai masalah signifikan:"
    )
    add_bullet_styled(doc, "Formulir kertas rentan basah, robek, atau terselip, mengakibatkan rekapitulasi inventaris akhir semester tidak akurat.", bold_prefix="1. Risiko Kehilangan Dokumen: ")
    add_bullet_styled(doc, "Mahasiswa tidak memiliki sarana untuk memantau stok alat praktikum yang tersedia tanpa mendatangi laboratorium secara fisik.", bold_prefix="2. Ketiadaan Transparansi Stok: ")
    add_bullet_styled(doc, "Laboran kesulitan melacak mahasiswa yang belum mengembalikan alat melewati batas waktu praktikum.", bold_prefix="3. Monitoring Tenggat Waktu Nihil: ")
    add_bullet_styled(doc, "Tidak ada formulir verifikasi kondisi fisik alat sebelum dipinjam dan setelah dikembalikan.", bold_prefix="4. Ketiadaan Inspeksi Fisik: ")

    add_header_styled(doc, "2. Perancangan Use Case & Alur Kerja Sistem", level=1)
    add_paragraph_styled(
        doc,
        "Solusi yang dibangun adalah aplikasi mobile 'LabInventory' berbasis Flutter. Sistem membagi hak akses ke dalam 2 aktor utama: "
        "Mahasiswa (peminjam) dan Laboran (administrator). Diagram di bawah ini mengilustrasikan pembagian use case dan batasan sistem aplikasi:"
    )

    usecase_img = os.path.join(EVID_DIR, "diagram_usecase_sistem.png")
    if os.path.exists(usecase_img):
        add_image_styled(doc, usecase_img, "Gambar 1.1 Diagram Use Case & Pembagian Peran Aplikasi Mobile LabInventory", width=Inches(5.6))

    add_paragraph_styled(
        doc,
        "Alur peminjaman dirancang menjadi 4 langkah terstruktur:"
    )
    add_bullet_styled(doc, "Mahasiswa mengecek ketersediaan unit dan spesifikasi pada katalog digital.", bold_prefix="Langkah 1 (Pilih Alat): ")
    add_bullet_styled(doc, "Mahasiswa menentukan jumlah unit, memilih rentang tanggal kalender (DatePicker WIB), dan mengisi tujuan praktikum.", bold_prefix="Langkah 2 (Isi Formulir): ")
    add_bullet_styled(doc, "Laboran menyetujui pengajuan di sistem dan mahasiswa mengambil alat dengan verifikasi KTM fisik di laboratorium.", bold_prefix="Langkah 3 (Verifikasi & Ambil): ")
    add_bullet_styled(doc, "Laboran menginspeksi kondisi fisik alat (Baik atau Rusak) dan mengonfirmasi pengembalian di sistem.", bold_prefix="Langkah 4 (Pengembalian): ")

    add_header_styled(doc, "3. Setup Environment Flutter & Aset Aplikasi", level=1)
    add_paragraph_styled(
        doc,
        "Pada minggu ini telah diselesaikan instalasi serta konfigurasi Flutter SDK (^3.13) dan Dart SDK (^3.0). "
        "Aplikasi telah dikonfigurasi dengan launcher icon Android kustom berlogo resmi LabInventory Unila:"
    )
    if os.path.exists(ICON_PATH):
        add_image_styled(doc, ICON_PATH, "Gambar 1.2 Ikon Launcher Resmi Aplikasi LabInventory pada Perangkat Android", width=Inches(1.5))

    add_header_styled(doc, "4. Struktur Direktori Proyek Hasil Inisiasi", level=1)
    struk_headers = ["Direktori / File", "Deskripsi & Peranan"]
    struk_data = [
        ["android/app/src/main/AndroidManifest.xml", "Konfigurasi izin jaringan native (INTERNET, ACCESS_NETWORK_STATE) dan label 'LabInventory'."],
        ["android/app/src/main/res/mipmap-*/", "Aset ikon launcher adaptive pada berbagai resolusi layar Android."],
        ["assets/images/lab_inventory_logo.png", "Logo utama identitas aplikasi LabInventory Universitas Lampung."],
        ["lib/main.dart", "Entry point aplikasi dan struktur navigasi awal."],
        ["pubspec.yaml", "Pendaftaran pustaka dependensi (cupertino_icons, supabase_flutter) dan aset grafis."],
        ["README.md", "Dokumentasi petunjuk teknis proyek dan panduan pengujian."]
    ]
    add_styled_table(doc, struk_headers, struk_data, col_widths=[2.5, 3.8])

    add_header_styled(doc, "5. Kendala dan Solusi Teknis", level=1)
    add_callout(
        doc,
        "Kendala: Muncul peringatan deprecation Gradle pada Android Studio saat inisiasi build awal.\n"
        "Solusi: Memperbarui gradle-wrapper ke versi 8.0+ dan menetapkan compileSdkVersion 34 serta targetSdkVersion 34 sehingga kompilasi berjalan mulus tanpa error.",
        title="Evaluasi & Solusi Teknis"
    )

    add_header_styled(doc, "6. Kesimpulan & Rencana Minggu II", level=1)
    add_paragraph_styled(
        doc,
        "Fase inisiasi, analisis kebutuhan, perancangan use case, dan setup environment pada Minggu I telah berhasil diselesaikan dengan baik (100%). "
        "Pada Minggu II, pekerjaan dilanjutkan ke implementasi antarmuka pengguna (UI/UX) Material Design 3, "
        "Bottom Navigation Bar (4 tab Mahasiswa dan 5 tab Laboran), Animated Splash Screen, serta katalog inventaris real-time."
    )

    add_signoff(doc, "09 September 2026")
    return doc


# ===================== MINGGU 2 =====================
def generate_minggu_2():
    doc = docx.Document()
    setup_page(doc)
    add_standard_cover(
        doc,
        minggu_romawi="II",
        minggu_angka="2",
        topik_minggu="Implementasi UI/UX (Material Design 3), Bottom Navigation Bar & Form Pinjam",
        tgl_str="10 – 16 September 2026"
    )

    add_header_styled(doc, "1. Deskripsi Pekerjaan Minggu II", level=1)
    add_paragraph_styled(
        doc,
        "Fokus utama pada Minggu II adalah membangun sistem antarmuka pengguna mobile yang modern, responsif, dan konsisten "
        "mengikuti panduan Google Material Design 3 dengan palet warna resmi almamater Universitas Lampung."
    )

    add_header_styled(doc, "2. Rincian Capaian Implementasi UI/UX", level=1)
    add_bullet_styled(doc, "Primer Unila Navy (`0xFF0F3B7A`), Sekunder Sapphire Blue (`0xFF1E60B8`), Background Bersih (`0xFFF8FAFC`).", bold_prefix="Design System & Warna: ")
    add_bullet_styled(doc, "Transisi pembesaran dan pemudaran (Scale & Fade) logo Universitas Lampung sebelum memasuki layar autentikasi.", bold_prefix="Animated Splash Screen: ")
    add_bullet_styled(doc, "Menggunakan widget `IndexedStack` agar data formulir dan scroll position tetap terjaga saat berpindah antar tab navigasi.", bold_prefix="Preserve State Navigation: ")
    add_bullet_styled(doc, "Beranda (Hero banner, status pinjaman, tata tertib), Inventaris (katalog), Peminjaman (status riwayat), Profil.", bold_prefix="Tab Mahasiswa (4 Tab): ")
    add_bullet_styled(doc, "Dashboard (metrik total alat & pending), Inventaris (manajemen stok), Pengajuan (approval), Riwayat Lab, Profil Admin.", bold_prefix="Tab Laboran (5 Tab): ")
    add_bullet_styled(doc, "Dilengkapi search query instan dan filter chip kategori (*Komputer, Elektronik, Aksesoris, Audio*).", bold_prefix="Katalog & Pencarian: ")
    add_bullet_styled(doc, "Dialog pemilih tanggal kalender (WIB), counter unit, dan textfield keperluan praktikum.", bold_prefix="Formulir Pengajuan: ")
    add_bullet_styled(doc, "Disediakan opsi tombol 'Masuk Mode Demo' agar dosen penguji dapat menguji antarmuka secara instan tanpa login.", bold_prefix="Mode Demo In-Memory: ")

    add_header_styled(doc, "3. Dokumentasi Hasil Implementasi (Tangkapan Layar)", level=1)
    add_image_styled(doc, os.path.join(IMG_DIR, "01-login.png"), "Gambar 2.1 Halaman Autentikasi Pengguna & Pilihan Mode Demo Instan", width=Inches(3.1))
    add_image_styled(doc, os.path.join(IMG_DIR, "10-catalog-search.png"), "Gambar 2.2 Katalog Inventaris dengan Pencarian Real-time & Chip Kategori", width=Inches(3.1))
    add_image_styled(doc, os.path.join(IMG_DIR, "08-laptop-detail.png"), "Gambar 2.3 Rincian Spesifikasi Alat, Status Kondisi, dan Posisi Lemari/Rak", width=Inches(3.1))
    add_image_styled(doc, os.path.join(IMG_DIR, "02-student-form.png"), "Gambar 2.4 Formulir Digital Pengajuan Peminjaman Alat Mahasiswa", width=Inches(3.1))

    add_header_styled(doc, "4. Kendala Antarmuka & Perbaikan Safe Area", level=1)
    add_paragraph_styled(
        doc,
        "Saat pengujian formulir pada layar smartphone, ditemukan kendala di mana keyboard virtual menutupi tombol 'Kirim Pengajuan'. "
        "Perbaikan dilakukan dengan membungkus antarmuka menggunakan `SafeArea` dan `SingleChildScrollView`:"
    )
    safe_area_img = os.path.join(IMG_DIR, "05-form-safe-area-fixed.png")
    if os.path.exists(safe_area_img):
        add_image_styled(doc, safe_area_img, "Gambar 2.5 Bukti Perbaikan Formulir: Keyboard Virtual Tidak Lagi Menutupi Bidang Input & Tombol Aksi", width=Inches(3.1))

    add_callout(
        doc,
        "Perbaikan layout Safe Area memastikan bahwa seluruh perangkat Android, baik dengan aspect ratio 16:9, 19:9, maupun 20:9, dapat menampilkan formulir peminjaman dengan sempurna tanpa clipping.",
        title="Kepatuhan Responsivitas"
    )

    add_header_styled(doc, "5. Kesimpulan & Rencana Minggu III", level=1)
    add_paragraph_styled(
        doc,
        "Seluruh komponen antarmuka, navigasi multi-role, dan formulir telah berhasil dibangun secara solid (100%). "
        "Pada Minggu III, aplikasi akan dihubungkan secara live ke Cloud Database Supabase (PostgreSQL 15), menerapkan Supabase Auth, "
        "dan mengonfigurasi Row Level Security (RLS) serta menghapus dummy data lokal."
    )

    add_signoff(doc, "16 September 2026")
    return doc


# ===================== MINGGU 3 =====================
def generate_minggu_3():
    doc = docx.Document()
    setup_page(doc)
    add_standard_cover(
        doc,
        minggu_romawi="III",
        minggu_angka="3",
        topik_minggu="Integrasi Backend Cloud Supabase (PostgreSQL), Autentikasi & RLS Security",
        tgl_str="17 – 23 September 2026"
    )

    add_header_styled(doc, "1. Deskripsi Pekerjaan Minggu III", level=1)
    add_paragraph_styled(
        doc,
        "Pada Minggu III, aplikasi LabInventory beralih dari prototype visual menjadi aplikasi terkoneksi cloud penuh "
        "dengan mengintegrasikan Supabase Cloud Platform (PostgreSQL 15), Supabase Auth, dan otorisasi ketat Row Level Security (RLS)."
    )

    add_header_styled(doc, "2. Arsitektur Cloud & Keamanan Sistem", level=1)
    add_paragraph_styled(
        doc,
        "Arsitektur keamanan ditegakkan di level database engine menggunakan PostgreSQL Row Level Security (RLS). "
        "Diagram di bawah mengilustrasikan konektivitas antara klien Flutter dengan lapisan otorisasi dan database Supabase:"
    )
    arch_img = os.path.join(EVID_DIR, "diagram_arsitektur_sistem.png")
    if os.path.exists(arch_img):
        add_image_styled(doc, arch_img, "Gambar 3.1 Diagram Arsitektur Cloud, Gateway Keamanan, dan Database Supabase PostgreSQL 15", width=Inches(5.6))

    add_header_styled(doc, "3. Rincian Capaian Integrasi Backend", level=1)
    add_bullet_styled(doc, "Mengaktifkan package `supabase_flutter: ^2.5.0` dan menghubungkan project ke URL endpoint HTTPS resmi.", bold_prefix="Konektivitas Supabase: ")
    add_bullet_styled(doc, "Menghapus seluruh mock data lokal (dummy data); data barang dan peminjaman murni membaca baris tabel Supabase secara real-time.", bold_prefix="Eliminasi Dummy Data: ")
    add_bullet_styled(doc, "Menerapkan tabel relasional `profiles`, `items`, dan `borrowings` berbasis Primary Key UUID v4.", bold_prefix="Skema Relasional Database: ")
    add_bullet_styled(doc, "Mahasiswa hanya dapat membaca/menulis transaksinya sendiri (`auth.uid() = user_id`), sedangkan Laboran memiliki akses penuh.", bold_prefix="Row Level Security (RLS): ")
    add_bullet_styled(doc, "Menangani status session login secara otomatis melalui `SessionController` (login, auto-restore token, dan secure logout).", bold_prefix="Autentikasi Token JWT: ")
    add_bullet_styled(doc, "Menambahkan timeout guard 4 detik dengan blok `try-finally` untuk menjamin dialog loading tidak berputar terus-menerus.", bold_prefix="Stabilitas Jaringan: ")

    add_header_styled(doc, "4. Struktur Tabel Database Cloud Supabase", level=1)
    tbl_headers = ["Nama Tabel", "Primary Key", "Foreign Key", "Fungsi & Hak Akses RLS"]
    tbl_data = [
        ["profiles", "id (UUID)", "auth.users(id)", "Menyimpan data identitas (nama, npm, role). Mahasiswa membaca akun sendiri; Admin membaca semua."],
        ["items", "id (UUID)", "-", "Master data alat lab (nama, kode, stok, lokasi). Seluruh user dapat membaca (SELECT); hanya Admin yang dapat mengubah."],
        ["borrowings", "id (UUID)", "profiles(id), items(id)", "Data pengajuan peminjaman. Mahasiswa membaca miliknya; Admin membaca seluruh lab & mengupdate status."]
    ]
    add_styled_table(doc, tbl_headers, tbl_data, col_widths=[1.2, 1.2, 1.5, 2.4])

    add_header_styled(doc, "5. Kredensial Akun Pengujian Resmi Cloud", level=1)
    cred_headers = ["Role / Peran", "Email Akun", "Kata Sandi", "Hak Akses & Fitur"]
    cred_data = [
        ["Admin / Laboran", "admin@lab.com", "admin123", "Akses penuh Dashboard Laboran, Approval Pengajuan, Input Alat Baru, & Pengembalian Alat."],
        ["Mahasiswa / Siswa", "tes@1.com", "123456", "Akses Katalog Inventaris, Pengajuan Pinjam Alat, Cek Status Peminjaman Saya."]
    ]
    add_styled_table(doc, cred_headers, cred_data, col_widths=[1.5, 1.6, 1.2, 2.0])

    add_header_styled(doc, "6. Dokumentasi Integrasi Cloud (Tangkapan Layar)", level=1)
    add_image_styled(doc, os.path.join(IMG_DIR, "03-admin-approved.png"), "Gambar 3.2 Dashboard Laboran Live: Menampilkan Metrik Cloud & Antrean Pengajuan", width=Inches(3.1))
    add_image_styled(doc, os.path.join(IMG_DIR, "04-student-pending.png"), "Gambar 3.3 Halaman Peminjaman Mahasiswa: Status 'PENDING' Terupdate Otomatis dari Cloud", width=Inches(3.1))
    add_image_styled(doc, os.path.join(IMG_DIR, "09-admin-created-item.png"), "Gambar 3.4 Formulir Tambah Alat Baru oleh Laboran yang Langsung Mengupdate Tabel Items", width=Inches(3.1))

    add_header_styled(doc, "7. Kendala Database & Solusi", level=1)
    add_callout(
        doc,
        "Kendala: Muncul error 'foreign key constraint violation' saat pengajuan dikirim karena ID barang masih membaca format integer tiruan.\n"
        "Solusi: Memperbarui pemetaan model Dart agar ID barang secara otomatis menyalin string UUID valid yang ada di tabel items Supabase sebelum pengajuan disubmit ke server.",
        title="Integritas Foreign Key"
    )

    add_header_styled(doc, "8. Kesimpulan & Rencana Minggu IV", level=1)
    add_paragraph_styled(
        doc,
        "Seluruh arsitektur cloud backend, otorisasi RLS, dan koneksi real-time telah beroperasi sempurna (100%). "
        "Pada Minggu IV, pekerjaan difokuskan pada penguncian integritas transaksi stok (PostgreSQL RPC Stored Procedures), "
        "alur pengembalian alat dengan inspeksi kerusakan, pengujian di perangkat smartphone fisik, serta penyusunan laporan akhir."
    )

    add_signoff(doc, "23 September 2026")
    return doc


# ===================== MINGGU 4 =====================
def generate_minggu_4():
    doc = docx.Document()
    setup_page(doc)
    add_standard_cover(
        doc,
        minggu_romawi="IV",
        minggu_angka="4",
        topik_minggu="Transaksi Stok Atomik (RPC), Pengujian Device Fisik, SRD v2 & Finalisasi",
        tgl_str="24 September – 19 Oktober 2026"
    )

    add_header_styled(doc, "1. Deskripsi Pekerjaan Minggu IV", level=1)
    add_paragraph_styled(
        doc,
        "Minggu IV merupakan fase krusial penyempurnaan integritas transaksi stok melalui stored procedure database, "
        "penanganan kondisi barang rusak saat pengembalian, pengujian intensif end-to-end pada perangkat Android fisik, "
        "serta kompilasi dokumentasi akademik (SRD v2.0 dan Laporan Akhir)."
    )

    add_header_styled(doc, "2. Rincian Capaian Integritas Transaksi & Pengujian", level=1)
    add_bullet_styled(doc, "Membuat RPC `approve_borrowing()`, `reject_borrowing()`, dan `return_borrowing()` dengan penguncian baris (`FOR UPDATE`) untuk mencegah race condition double-booking unit terakhir.", bold_prefix="Transaksi Atomik (ACID): ")
    add_bullet_styled(doc, "Stok siap pakai berkurang seketika di database saat laboran menekan tombol 'Setujui' pada antrean pengajuan.", bold_prefix="Pengurangan Stok Live: ")
    add_bullet_styled(doc, "Jika alat kembali dalam kondisi 'Rusak', sistem otomatis mengalihkan unit ke kolom `stok_rusak` tanpa mengurangi status kebaikan unit lain yang masih berfungsi.", bold_prefix="Alur Pengembalian & Cek Fisik: ")
    add_bullet_styled(doc, "Setiap request penulisan menyertakan UUID request unik sehingga gangguan koneksi internet tidak mengakibatkan data ganda.", bold_prefix="Idempotency Guard: ")
    add_bullet_styled(doc, "Menjalankan 12 checkpoint verifikasi pada smartphone Android nyata (Physical Device Testing) dengan hasil 100% Passed.", bold_prefix="Pengujian Perangkat Fisik: ")
    add_bullet_styled(doc, "Memperbarui dokumen SRD ke versi 2.0 (Word dan Markdown) dan menyelesaikan laporan kemajuan 4 minggu.", bold_prefix="Finalisasi Akademik: ")

    add_header_styled(doc, "3. Hasil Verifikasi Pengujian Perangkat Fisik (12 Checkpoints)", level=1)
    chk_headers = ["No", "Checkpoint Pengujian", "Aktor", "Hasil Verifikasi", "Status"]
    chk_data = [
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
    add_styled_table(doc, chk_headers, chk_data, col_widths=[0.4, 2.5, 1.1, 2.0, 0.7])

    add_header_styled(doc, "4. Dokumentasi Hasil Pengujian (Tangkapan Layar)", level=1)
    add_image_styled(doc, os.path.join(IMG_DIR, "06-damaged-return.png"), "Gambar 4.1 Dialog Pengembalian Alat oleh Laboran dengan Pilihan Rusak & Catatan", width=Inches(3.1))
    add_image_styled(doc, os.path.join(IMG_DIR, "07-stock-after-damage.png"), "Gambar 4.2 Pembaruan Otomatis Stok Siap Pakai & Pencatatan Stok Rusak pada Detail Alat", width=Inches(3.1))
    add_image_styled(doc, os.path.join(IMG_DIR, "11-final-history.png"), "Gambar 4.3 Audit Log Lengkap Riwayat Transaksi Seluruh Laboratorium Komputer PTI", width=Inches(3.1))
    add_image_styled(doc, os.path.join(IMG_DIR, "12-student-final-history.png"), "Gambar 4.4 Riwayat Akhir Mahasiswa dengan Status Transaksi 'RETURNED' / Selesai", width=Inches(3.1))

    playwright_img = os.path.join(EVID_DIR, "playwright-desktop.png")
    if os.path.exists(playwright_img):
        add_image_styled(doc, playwright_img, "Gambar 4.5 Bukti Pengujian Automasi E2E (Playwright Test) untuk Validasi Konsistensi State Transaksi", width=Inches(4.8))

    add_header_styled(doc, "5. Kendala Integritas Stok & Solusi", level=1)
    add_callout(
        doc,
        "Kendala: Mengubah kondisi master barang menjadi 'Rusak' membuat seluruh sisa stok unit lain tidak dapat dipinjam.\n"
        "Solusi: Memisahkan jumlah kerusakan ke dalam kolom khusus `stok_rusak` pada level database. Unit sehat tetap berada di kolom `stok` dan dapat dipinjam kembali tanpa mengubah status master barang.",
        title="Arsitektur Database Stok"
    )

    add_header_styled(doc, "6. Kesimpulan Akhir Seluruh Proyek", level=1)
    add_paragraph_styled(
        doc,
        "Aplikasi LabInventory telah selesai dikembangkan 100% dan berhasil memenuhi seluruh spesifikasi kebutuhan akademik. "
        "Sistem ini siap diimplementasikan untuk mendigitalisasi pengelolaan inventaris dan peminjaman alat pada "
        "Laboratorium Komputer Program Studi Pendidikan Teknologi Informasi, FKIP Universitas Lampung."
    )

    add_signoff(doc, "19 Oktober 2026")
    return doc


def main():
    print("Regenerating all 4 enriched weekly Word reports...")
    out_dir = os.path.abspath("docs/laporan")
    
    docs_to_build = [
        ("Laporan_Minggu_1_LabInventory_Naila_Fathia.docx", generate_minggu_1()),
        ("Laporan_Minggu_2_LabInventory_Naila_Fathia.docx", generate_minggu_2()),
        ("Laporan_Minggu_3_LabInventory_Naila_Fathia.docx", generate_minggu_3()),
        ("Laporan_Minggu_4_LabInventory_Naila_Fathia.docx", generate_minggu_4())
    ]
    
    for filename, d in docs_to_build:
        path_in_laporan = os.path.join(out_dir, filename)
        path_in_root = os.path.abspath(filename)
        d.save(path_in_laporan)
        d.save(path_in_root)
        print(f"Generated: {filename} ({os.path.getsize(path_in_laporan)} bytes)")
        
    print("All 4 weekly reports enriched and successfully saved!")

if __name__ == "__main__":
    main()
