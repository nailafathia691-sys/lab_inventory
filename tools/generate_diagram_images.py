import os
from PIL import Image, ImageDraw, ImageFont

def draw_rounded_rect(draw, coords, radius, fill, outline=None, width=1):
    x1, y1, x2, y2 = coords
    draw.rounded_rectangle([x1, y1, x2, y2], radius=radius, fill=fill, outline=outline, width=width)

def generate_usecase_diagram():
    # Width 1200, Height 700
    img = Image.new("RGB", (1200, 720), "#F8FAFC")
    draw = ImageDraw.Draw(img)

    # Header Banner
    draw_rounded_rect(draw, (40, 25, 1160, 95), radius=10, fill="#0F3B7A")
    draw.text((600, 42), "DIAGRAM USE CASE & ALUR SISTEM LABINVENTORY", fill="#FFFFFF", anchor="mm")
    draw.text((600, 75), "Laboratorium Komputer PTI FKIP Universitas Lampung", fill="#CBD5E1", anchor="mm")

    # Actor 1: Mahasiswa (Left)
    draw_rounded_rect(draw, (40, 130, 220, 680), radius=12, fill="#FFFFFF", outline="#1E60B8", width=2)
    draw_rounded_rect(draw, (55, 145, 205, 195), radius=8, fill="#1E60B8")
    draw.text((130, 170), "🎓 MAHASISWA", fill="#FFFFFF", anchor="mm")
    draw.text((130, 225), "[Aktor Peminjam]", fill="#64748B", anchor="mm")
    draw.text((130, 245), "- Cari Barang Lab", fill="#2D3748", anchor="mm")
    draw.text((130, 270), "- Cek Stok Live", fill="#2D3748", anchor="mm")
    draw.text((130, 295), "- Form Pengajuan", fill="#2D3748", anchor="mm")
    draw.text((130, 320), "- Cek Status Pinjam", fill="#2D3748", anchor="mm")
    draw.text((130, 345), "- Bawa KTM ke Lab", fill="#2D3748", anchor="mm")

    # Actor 2: Laboran / Admin (Right)
    draw_rounded_rect(draw, (980, 130, 1160, 680), radius=12, fill="#FFFFFF", outline="#0F3B7A", width=2)
    draw_rounded_rect(draw, (995, 145, 1145, 195), radius=8, fill="#0F3B7A")
    draw.text((1070, 170), "🛡️ LABORAN / ADMIN", fill="#FFFFFF", anchor="mm")
    draw.text((1070, 225), "[Aktor Pengelola]", fill="#64748B", anchor="mm")
    draw.text((1070, 245), "- Verifikasi Pengajuan", fill="#2D3748", anchor="mm")
    draw.text((1070, 270), "- Approve / Reject", fill="#2D3748", anchor="mm")
    draw.text((1070, 295), "- Input Alat Baru", fill="#2D3748", anchor="mm")
    draw.text((1070, 320), "- Proses Pengembalian", fill="#2D3748", anchor="mm")
    draw.text((1070, 345), "- Cek Kerusakan Fisik", fill="#2D3748", anchor="mm")
    draw.text((1070, 370), "- Audit Log Riwayat", fill="#2D3748", anchor="mm")

    # System Boundary Box (Center)
    draw_rounded_rect(draw, (260, 130, 940, 680), radius=14, fill="#FFFFFF", outline="#CBD5E1", width=2)
    draw.text((600, 155), "Batasan Sistem Aplikasi Mobile LabInventory", fill="#0F3B7A", anchor="mm")

    use_cases = [
        ("UC-01: Autentikasi & Role Guard (GoTrue)", 200, "#EFF6FF", "#1E60B8"),
        ("UC-02: Penelusuran Katalog & Filter Kategori", 265, "#F1F5F9", "#0F3B7A"),
        ("UC-03: Pengajuan Peminjaman Alat (DatePicker WIB)", 330, "#EFF6FF", "#1E60B8"),
        ("UC-04: Verifikasi & Persetujuan (RPC Atomic Stock)", 395, "#FEF3C7", "#D97706"),
        ("UC-05: Pengembalian Alat & Inspeksi Fisik (Rusak/Baik)", 460, "#FEF2F2", "#DC2626"),
        ("UC-06: Manajemen Stok & Registrasi Alat Baru", 525, "#F1F5F9", "#0F3B7A"),
        ("UC-07: Audit Log Riwayat Transaksi Laboratorium", 590, "#EFF6FF", "#1E60B8"),
        ("Mode Demo Instan (In-Memory Prototype)", 645, "#F8FAFC", "#64748B")
    ]

    for title, y_pos, bg_col, border_col in use_cases:
        draw_rounded_rect(draw, (310, y_pos - 20, 890, y_pos + 20), radius=18, fill=bg_col, outline=border_col, width=2)
        draw.text((600, y_pos), title, fill="#1E293B", anchor="mm")

    # Connectors lines
    # From Mahasiswa
    for y_pos in [200, 265, 330, 590, 645]:
        draw.line([(220, 240), (310, y_pos)], fill="#1E60B8", width=2)
    # From Laboran
    for y_pos in [200, 265, 395, 460, 525, 590, 645]:
        draw.line([(980, 240), (890, y_pos)], fill="#0F3B7A", width=2)

    out_path = os.path.abspath("docs/evidence/diagram_usecase_sistem.png")
    img.save(out_path, "PNG")
    print(f"Use Case Diagram generated: {out_path}")

def generate_architecture_diagram():
    # Width 1200, Height 650
    img = Image.new("RGB", (1200, 650), "#F8FAFC")
    draw = ImageDraw.Draw(img)

    # Header
    draw_rounded_rect(draw, (40, 20, 1160, 85), radius=10, fill="#0F3B7A")
    draw.text((600, 40), "ARSITEKTUR CLOUD & KEAMANAN SISTEM LABINVENTORY", fill="#FFFFFF", anchor="mm")
    draw.text((600, 68), "Flutter Mobile Client <---> Supabase PostgreSQL Backend", fill="#CBD5E1", anchor="mm")

    # Layer 1: Client Layer
    draw_rounded_rect(draw, (50, 115, 380, 610), radius=12, fill="#FFFFFF", outline="#1E60B8", width=2)
    draw_rounded_rect(draw, (70, 130, 360, 175), radius=8, fill="#1E60B8")
    draw.text((215, 152), "📱 MOBILE CLIENT (FLUTTER)", fill="#FFFFFF", anchor="mm")

    client_items = [
        ("Material Design 3 (Unila Palette)", 210),
        ("IndexedStack Bottom Nav (Preserve State)", 270),
        ("SessionController (JWT Auto-Restore)", 330),
        ("Timeout Guard (4s) + Try-Finally", 390),
        ("Idempotency Key Generator (UUID)", 450),
        ("In-Memory Demo Backend Fallback", 510),
        ("Android Native Permissions (Internet/State)", 570)
    ]
    for text, y in client_items:
        draw_rounded_rect(draw, (70, y - 18, 360, y + 18), radius=6, fill="#EFF6FF", outline="#CBD5E1")
        draw.text((215, y), text, fill="#1E293B", anchor="mm")

    # Layer 2: Network / Security Gateway
    draw_rounded_rect(draw, (430, 115, 770, 610), radius=12, fill="#FFFFFF", outline="#0F3B7A", width=2)
    draw_rounded_rect(draw, (450, 130, 750, 175), radius=8, fill="#0F3B7A")
    draw.text((600, 152), "🛡️ GATEWAY & KEAMANAN", fill="#FFFFFF", anchor="mm")

    gateway_items = [
        ("HTTPS TLS 1.3 Encryption", 210),
        ("Supabase Auth (GoTrue Service)", 270),
        ("Bcrypt Password Hashing", 330),
        ("JWT Claims Validation (Role Guard)", 390),
        ("Row Level Security (RLS) PostgreSQL", 450),
        ("Row-level Locking ('FOR UPDATE')", 510),
        ("Sanitasi UUID & Anti SQL Injection", 570)
    ]
    for text, y in gateway_items:
        draw_rounded_rect(draw, (450, y - 18, 750, y + 18), radius=6, fill="#F1F5F9", outline="#94A3B8")
        draw.text((600, y), text, fill="#0F172A", anchor="mm")

    # Layer 3: Database & Cloud
    draw_rounded_rect(draw, (820, 115, 1150, 610), radius=12, fill="#FFFFFF", outline="#D97706", width=2)
    draw_rounded_rect(draw, (840, 130, 1130, 175), radius=8, fill="#D97706")
    draw.text((985, 152), "🗄️ SUPABASE POSTGRESQL 15", fill="#FFFFFF", anchor="mm")

    db_items = [
        ("Tabel: 'profiles' (User Identities)", 210),
        ("Tabel: 'items' (Stok Siap & Stok Rusak)", 270),
        ("Tabel: 'borrowings' (Transaksi Pinjam)", 330),
        ("RPC: 'approve_borrowing()' (Atomic)", 390),
        ("RPC: 'return_borrowing()' (Damage Split)", 450),
        ("Tabel: 'audit_logs' & 'request_records'", 510),
        ("Realtime Event Listener (WebSocket)", 570)
    ]
    for text, y in db_items:
        draw_rounded_rect(draw, (840, y - 18, 1130, y + 18), radius=6, fill="#FEF3C7", outline="#F59E0B")
        draw.text((985, y), text, fill="#78350F", anchor="mm")

    # Connecting arrows
    draw.line([(380, 270), (430, 270)], fill="#0F3B7A", width=3)
    draw.line([(380, 450), (430, 450)], fill="#0F3B7A", width=3)
    draw.line([(770, 270), (820, 270)], fill="#D97706", width=3)
    draw.line([(770, 450), (820, 450)], fill="#D97706", width=3)

    out_path = os.path.abspath("docs/evidence/diagram_arsitektur_sistem.png")
    img.save(out_path, "PNG")
    print(f"Architecture Diagram generated: {out_path}")

if __name__ == "__main__":
    generate_usecase_diagram()
    generate_architecture_diagram()
