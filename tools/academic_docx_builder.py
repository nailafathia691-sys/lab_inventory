import os
import sys
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

BLACK = RGBColor(0, 0, 0)
DARK_NAVY = RGBColor(15, 59, 122)
WHITE = RGBColor(255, 255, 255)

def setup_academic_page(doc):
    for sec in doc.sections:
        sec.top_margin = Inches(1.0)      # 2.54 cm
        sec.bottom_margin = Inches(1.0)   # 2.54 cm
        sec.left_margin = Inches(1.18)    # 3.0 cm
        sec.right_margin = Inches(1.0)    # 2.54 cm

def set_cell_background(cell, hex_color):
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
    cell._tc.get_or_add_tcPr().append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=140, right=140):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def set_academic_table_borders(table):
    # Standard academic APA-style table: top, bottom, and header bottom borders only
    tblPr = table._tbl.tblPr
    borders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>'
        f'  <w:top w:val="single" w:sz="12" w:space="0" w:color="000000"/>'
        f'  <w:left w:val="none"/>'
        f'  <w:bottom w:val="single" w:sz="12" w:space="0" w:color="000000"/>'
        f'  <w:right w:val="none"/>'
        f'  <w:insideH w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>'
        f'  <w:insideV w:val="none"/>'
        f'</w:tblBorders>'
    )
    tblPr.append(borders)

def add_academic_cover(doc, jenis_dokumen, judul_utama, sub_judul, tgl_tahun="2026"):
    # Header block
    p1 = doc.add_paragraph()
    p1.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p1.paragraph_format.space_before = Pt(12)
    p1.paragraph_format.space_after = Pt(2)
    p1.paragraph_format.line_spacing = 1.15
    r_j = p1.add_run(jenis_dokumen.upper())
    r_j.font.name = "Times New Roman"
    r_j.font.size = Pt(14)
    r_j.bold = True
    r_j.font.color.rgb = BLACK

    p2 = doc.add_paragraph()
    p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p2.paragraph_format.space_before = Pt(0)
    p2.paragraph_format.space_after = Pt(6)
    p2.paragraph_format.line_spacing = 1.15
    r_t = p2.add_run(judul_utama.upper())
    r_t.font.name = "Times New Roman"
    r_t.font.size = Pt(13)
    r_t.bold = True
    r_t.font.color.rgb = BLACK

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(18)
    p_sub.paragraph_format.line_spacing = 1.15
    r_sub = p_sub.add_run(f'“{sub_judul}”')
    r_sub.font.name = "Times New Roman"
    r_sub.font.size = Pt(11)
    r_sub.italic = True
    r_sub.font.color.rgb = BLACK

    # Maksud penyusunan
    p_maksud = doc.add_paragraph()
    p_maksud.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_maksud.paragraph_format.space_after = Pt(2)
    r_m = p_maksud.add_run("Disusun untuk memenuhi tugas mata kuliah Pemrograman Mobile (Mobile Programming)")
    r_m.font.name = "Times New Roman"
    r_m.font.size = Pt(11)
    r_m.font.color.rgb = BLACK

    p_dosen = doc.add_paragraph()
    p_dosen.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_dosen.paragraph_format.space_after = Pt(16)
    r_d = p_dosen.add_run("Dosen Pengampu: Ghea Chandra Surawan, M. Pd.")
    r_d.font.name = "Times New Roman"
    r_d.font.size = Pt(11)
    r_d.bold = True
    r_d.font.color.rgb = BLACK

    # Logo Unila
    logo_path = os.path.abspath("assets/images/lab_inventory_logo.png")
    if os.path.exists(logo_path):
        p_logo = doc.add_paragraph()
        p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_logo.paragraph_format.space_before = Pt(6)
        p_logo.paragraph_format.space_after = Pt(16)
        run_logo = p_logo.add_run()
        run_logo.add_picture(logo_path, width=Inches(2.1))

    # Identitas Mahasiswa
    p_oleh = doc.add_paragraph()
    p_oleh.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_oleh.paragraph_format.space_after = Pt(2)
    r_oleh = p_oleh.add_run("Disusun Oleh:")
    r_oleh.font.name = "Times New Roman"
    r_oleh.font.size = Pt(11)
    r_oleh.bold = True

    p_mhs = doc.add_paragraph()
    p_mhs.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_mhs.paragraph_format.line_spacing = 1.15
    p_mhs.paragraph_format.space_after = Pt(24)
    r_mhs = p_mhs.add_run(
        "Nama : Naila Fathia\n"
        "NPM : 2413025076\n"
        "Kelas : PTI 2024 B"
    )
    r_mhs.font.name = "Times New Roman"
    r_mhs.font.size = Pt(11)
    r_mhs.bold = True

    # Institusi
    p_inst = doc.add_paragraph()
    p_inst.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_inst.paragraph_format.line_spacing = 1.15
    p_inst.paragraph_format.space_after = Pt(0)
    r_inst = p_inst.add_run(
        "PROGRAM STUDI PENDIDIKAN TEKNOLOGI INFORMASI\n"
        "JURUSAN PENDIDIKAN MATEMATIKA DAN ILMU PENGETAHUAN ALAM\n"
        "FAKULTAS KEGURUAN DAN ILMU PENDIDIKAN\n"
        "UNIVERSITAS LAMPUNG\n"
        f"{tgl_tahun}"
    )
    r_inst.font.name = "Times New Roman"
    r_inst.font.size = Pt(11.5)
    r_inst.bold = True
    r_inst.font.color.rgb = BLACK

    doc.add_page_break()

def add_kata_pengantar(doc, judul_dokumen, tgl_str="Oktober 2026"):
    h = doc.add_paragraph()
    h.alignment = WD_ALIGN_PARAGRAPH.CENTER
    h.paragraph_format.space_before = Pt(12)
    h.paragraph_format.space_after = Pt(16)
    r_h = h.add_run("KATA PENGANTAR")
    r_h.font.name = "Times New Roman"
    r_h.font.size = Pt(13)
    r_h.bold = True

    p1 = doc.add_paragraph()
    p1.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p1.paragraph_format.line_spacing = 1.3
    p1.paragraph_format.space_after = Pt(10)
    r1 = p1.add_run(
        f"Puji dan syukur senantiasa penyusun panjatkan kehadirat Tuhan Yang Maha Kuasa atas limpahan rahmat, taufik, "
        f"serta petunjuk-Nya, sehingga naskah dokumen tugas yang berjudul “{judul_dokumen}” dapat diselesaikan "
        f"dengan tuntas, optimal, dan tepat waktu."
    )
    r1.font.name = "Times New Roman"
    r1.font.size = Pt(11)

    p2 = doc.add_paragraph()
    p2.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p2.paragraph_format.line_spacing = 1.3
    p2.paragraph_format.space_after = Pt(10)
    r2 = p2.add_run(
        "Laporan ini merupakan wujud dokumentasi akademik yang berfokus pada perancangan arsitektur, rekayasa kebutuhan, "
        "pengembangan antarmuka pengguna responsif berbasis Flutter, serta implementasi sistem basis data terpusat real-time "
        "menggunakan Cloud Supabase (PostgreSQL 15). Seluruh tahapan disusun guna menghadirkan solusi digitalisasi modern yang "
        "akuntabel bagi pengelolaan inventaris dan alur peminjaman alat pada Laboratorium Komputer Program Studi Pendidikan "
        "Teknologi Informasi (PTI), FKIP Universitas Lampung."
    )
    r2.font.name = "Times New Roman"
    r2.font.size = Pt(11)

    p3 = doc.add_paragraph()
    p3.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p3.paragraph_format.line_spacing = 1.3
    p3.paragraph_format.space_after = Pt(20)
    r3 = p3.add_run(
        "Rasa hormat dan ucapan terima kasih yang tulus penyusun haturkan kepada Bapak Ghea Chandra Surawan, M.Pd., "
        "selaku Dosen Pengampu mata kuliah Pemrograman Mobile (Mobile Programming), atas dedikasi, bimbingan metodologis, "
        "serta arahan keilmuan yang senantiasa diberikan selama proses perkuliahan dan penyelesaian proyek ini."
    )
    r3.font.name = "Times New Roman"
    r3.font.size = Pt(11)

    p_sign = doc.add_paragraph()
    p_sign.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p_sign.paragraph_format.line_spacing = 1.15
    r_s = p_sign.add_run(
        f"Bandar Lampung, {tgl_str}\n"
        "Penyusun,\n\n\n\n"
        "Naila Fathia\n"
        "NPM. 2413025076"
    )
    r_s.font.name = "Times New Roman"
    r_s.font.size = Pt(11)
    r_s.bold = True

    doc.add_page_break()

def add_bab_heading(doc, nomor_bab, judul_bab):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(14)
    p.paragraph_format.space_after = Pt(2)
    p.paragraph_format.keep_with_next = True
    r = p.add_run(f"BAB {nomor_bab}")
    r.font.name = "Times New Roman"
    r.font.size = Pt(13)
    r.bold = True
    r.font.color.rgb = BLACK

    p2 = doc.add_paragraph()
    p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p2.paragraph_format.space_after = Pt(14)
    p2.paragraph_format.keep_with_next = True
    r2 = p2.add_run(judul_bab.upper())
    r2.font.name = "Times New Roman"
    r2.font.size = Pt(13)
    r2.bold = True
    r2.font.color.rgb = BLACK

def add_subbab_heading(doc, kode_sub, judul_sub):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(12)
    p.paragraph_format.space_after = Pt(4)
    p.paragraph_format.keep_with_next = True
    r = p.add_run(f"{kode_sub} {judul_sub}")
    r.font.name = "Times New Roman"
    r.font.size = Pt(11.5)
    r.bold = True
    r.font.color.rgb = BLACK

def add_body_paragraph(doc, text, bold_prefix=None, space_after=8, line_spacing=1.3):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.line_spacing = line_spacing
    if bold_prefix:
        r_pre = p.add_run(bold_prefix)
        r_pre.font.name = "Times New Roman"
        r_pre.font.size = Pt(11)
        r_pre.bold = True
    r = p.add_run(text)
    r.font.name = "Times New Roman"
    r.font.size = Pt(11)
    return p

def add_bullet_item(doc, text, bold_prefix=None):
    p = doc.add_paragraph(style='List Bullet')
    p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p.paragraph_format.space_after = Pt(4)
    p.paragraph_format.line_spacing = 1.2
    if bold_prefix:
        r_pre = p.add_run(bold_prefix)
        r_pre.font.name = "Times New Roman"
        r_pre.font.size = Pt(11)
        r_pre.bold = True
    r = p.add_run(text)
    r.font.name = "Times New Roman"
    r.font.size = Pt(11)
    return p

def add_academic_image(doc, image_path, caption_text, width=Inches(3.8)):
    if not os.path.exists(image_path):
        return
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after = Pt(4)
    p.paragraph_format.keep_with_next = True
    run = p.add_run()
    run.add_picture(image_path, width=width)

    p_cap = doc.add_paragraph()
    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cap.paragraph_format.space_after = Pt(12)
    r_cap = p_cap.add_run(caption_text)
    r_cap.font.name = "Times New Roman"
    r_cap.font.size = Pt(10)
    r_cap.italic = True

def add_academic_table(doc, table_title, headers, data, col_widths=None):
    p_t = doc.add_paragraph()
    p_t.paragraph_format.space_before = Pt(8)
    p_t.paragraph_format.space_after = Pt(4)
    p_t.paragraph_format.keep_with_next = True
    r_t = p_t.add_run(table_title)
    r_t.font.name = "Times New Roman"
    r_t.font.size = Pt(10.5)
    r_t.bold = True

    table = doc.add_table(rows=len(data) + 1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_academic_table_borders(table)

    # Header
    for i, title in enumerate(headers):
        cell = table.rows[0].cells[i]
        cell.text = title
        set_cell_background(cell, "1E3A8A") # Navy Blue
        set_cell_margins(cell, top=100, bottom=100, left=120, right=120)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        for run in p.runs:
            run.font.name = "Times New Roman"
            run.font.size = Pt(10)
            run.bold = True
            run.font.color.rgb = WHITE

    # Rows
    for r_idx, row_data in enumerate(data):
        row_cells = table.rows[r_idx + 1].cells
        bg = "F1F5F9" if r_idx % 2 == 1 else "FFFFFF"
        for c_idx, val in enumerate(row_data):
            row_cells[c_idx].text = str(val)
            set_cell_background(row_cells[c_idx], bg)
            set_cell_margins(row_cells[c_idx], top=80, bottom=80, left=120, right=120)
            p = row_cells[c_idx].paragraphs[0]
            if c_idx == 0:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            else:
                p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            for run in p.runs:
                run.font.name = "Times New Roman"
                run.font.size = Pt(9.5)

    if col_widths:
        for row in table.rows:
            for i, w in enumerate(col_widths):
                row.cells[i].width = Inches(w)

    doc.add_paragraph().paragraph_format.space_after = Pt(8)
    return table

def add_daftar_pustaka(doc, daftar_items):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(16)
    p.paragraph_format.space_after = Pt(14)
    r = p.add_run("DAFTAR PUSTAKA")
    r.font.name = "Times New Roman"
    r.font.size = Pt(13)
    r.bold = True

    for item in daftar_items:
        p_item = doc.add_paragraph()
        p_item.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p_item.paragraph_format.line_spacing = 1.15
        p_item.paragraph_format.space_after = Pt(6)
        p_item.paragraph_format.left_indent = Inches(0.5)
        p_item.paragraph_format.first_line_indent = Inches(-0.5)
        r_item = p_item.add_run(item)
        r_item.font.name = "Times New Roman"
        r_item.font.size = Pt(10)

print("Academic docx builder helper loaded successfully.")
