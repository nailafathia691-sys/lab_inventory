# 📝 LAPORAN PROGRES MINGGU IV
## Transaksi Stok Atomik (RPC), Pengujian Device Fisik, SRD v2 & Finalisasi

---

### 👤 Identitas Mahasiswa & Informasi Proyek
- **Nama Mahasiswa**: Naila Fathia  
- **NPM**: 2413025076  
- **Mata Kuliah**: Pemrograman Mobile (Mobile Programming)  
- **Program Studi**: S1 Pendidikan Teknologi Informasi (PTI)  
- **Fakultas / Universitas**: FKIP / Universitas Lampung (UNILA)  
- **Dosen Pengampu**: Ghea Chandra Surawan, M.Pd.  
- **Tahap Proyek**: Minggu IV (Integritas Transaksi, Testing & Finalisasi)  
- **Status Capaian**: Selesai 100%  

---

## 1. Rincian Capaian & Aktivitas Minggu IV
Pada minggu keempat, sistem disempurnakan dengan jaminan integritas transaksi ACID, pengujian intensif pada smartphone Android fisik, serta finalisasi dokumentasi akademik:

1. **Implementasi Transaksi Atomik Database (PostgreSQL RPC)**:
   - Membuat fungsi stored procedure `approve_borrowing()`, `reject_borrowing()`, dan `return_borrowing()`.
   - Menggunakan row-level locking (`SELECT ... FOR UPDATE`) pada tabel `items` untuk mencegah *race condition* (dua laboran atau dua pengajuan memperebutkan unit terakhir barang yang sama).
   - Pengurangan stok barang terjadi seketika di dalam satu blok transaksi database saat pengajuan disetujui (`status = approved`).
2. **Alur Pengembalian Alat & Cek Kerusakan Fisik**:
   - Laboran dapat memproses pengembalian dengan memilih status kondisi: **Baik** atau **Rusak**.
   - Jika dikembalikan dalam kondisi **Baik**: unit dikembalikan ke kolom `stok` siap pakai.
   - Jika dikembalikan dalam kondisi **Rusak**: unit dialihkan ke kolom `stok_rusak`, dan catatan kerusakan disimpan pada riwayat transaksi. Unit barang sehat lainnya tetap aman dan dapat dipinjam.
3. **Mekanisme Idempotency Jaringan**:
   - Setiap operasi tulis menyertakan UUID request unik untuk mencegah transaksi duplikat saat sinyal seluler tidak stabil.
4. **Pengujian Perangkat Fisik (Physical Device Testing)**:
   - Melakukan instalasi berkas APK hasil kompilasi release pada perangkat smartphone Android nyata.
   - Menjalankan 12 checkpoint skenario pengujian: Login -> Katalog -> Peminjaman -> Approval Admin -> Pengembalian Rusak -> Rekonsiliasi Stok -> Audit Log. Seluruh checkpoint berhasil dilewati (*PASSED 100%*).
5. **Finalisasi Dokumentasi Proyek**:
   - Memperbarui *Software Requirement Document* menjadi SRD v2.0 dalam format Word (`.docx`) dan Markdown.
   - Menyusun 4 berkas Laporan Kemajuan Mingguan (Minggu 1, 2, 3, 4) lengkap dengan bukti tangkapan layar.

---

## 2. Hasil Verifikasi Pengujian Perangkat Fisik (12 Checkpoints)

| No | Checkpoint Pengujian | Aktor | Hasil Verifikasi | Status |
| :---: | :--- | :--- | :--- | :---: |
| 1 | Autentikasi Mahasiswa (`tes@1.com`) | Mahasiswa | Berhasil masuk dashboard mahasiswa | **PASSED** |
| 2 | Pencarian Katalog Real-time | Mahasiswa | Menemukan alat berdasarkan nama/kategori | **PASSED** |
| 3 | Pengajuan Peminjaman Alat | Mahasiswa | Form tersimpan di cloud (status pending) | **PASSED** |
| 4 | Verifikasi SafeArea Form | Mahasiswa | Form bebas tumpang tindih keyboard | **PASSED** |
| 5 | Autentikasi Laboran (`admin@lab.com`) | Laboran | Metrik & pengajuan pending muncul | **PASSED** |
| 6 | Persetujuan Pengajuan (Approve) | Laboran | Status approved & stok live berkurang | **PASSED** |
| 7 | Sinkronisasi Status Peminjaman | Mahasiswa | Status terupdate approved di user | **PASSED** |
| 8 | Pengembalian Alat Rusak | Laboran | Pilihan kondisi rusak & catatan tersimpan | **PASSED** |
| 9 | Rekonsiliasi Stok Rusak | Laboran | Stok siap pakai aman, stok_rusak bertambah | **PASSED** |
| 10 | Pendaftaran Alat Baru | Laboran | Kode INV-[KAT]-[RANDOM] terbentuk otomatis | **PASSED** |
| 11 | Audit Log Seluruh Lab | Laboran | Riwayat transaksi lab tercatat transparan | **PASSED** |
| 12 | Status Akhir Mahasiswa | Mahasiswa | Badge status berubah menjadi RETURNED | **PASSED** |

---

## 3. Bukti Pengujian Alur Transaksi & Pengembalian (Tangkapan Layar)

### 3.1 Dialog Pengembalian Alat & Inspeksi Fisik
![Pengembalian Alat](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/06-damaged-return.png)
*Gambar 4.1: Dialog pengembalian alat oleh laboran dengan pilihan kondisi Rusak dan input catatan evaluasi.*

### 3.2 Penyesuaian Otomatis Stok Siap Pakai & Rusak
![Stok Pasca Rusak](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/07-stock-after-damage.png)
*Gambar 4.2: Stok siap pakai berkurang dan unit rusak tercatat pada kolom stok rusak tanpa merusak master data barang.*

### 3.3 Audit Log Lengkap Transaksi Laboratorium
![Audit Log Riwayat](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/11-final-history.png)
*Gambar 4.3: Halaman riwayat transaksi seluruh laboratorium yang dapat diaudit oleh laboran.*

### 3.4 Riwayat Akhir Peminjaman Mahasiswa
![Riwayat Mahasiswa](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/device/12-student-final-history.png)
*Gambar 4.4: Tampilan transaksi mahasiswa yang telah berstatus 'RETURNED' / Selesai.*

### 3.5 Pengujian Automasi E2E (Playwright Test)
![Playwright Test](file:///d:/Kuliah%20Arya/NGODING/Joki%20Nayla/lab_inventory/docs/evidence/playwright-desktop.png)
*Gambar 4.5: Bukti pengujian automasi E2E untuk memvalidasi konsistensi state transaksi.*

---

## 4. Kendala dan Solusi
- **Kendala**: Jika barang dikembalikan dalam kondisi rusak, mengubah kondisi master barang menjadi 'Rusak' menyebabkan sisa stok unit lain yang masih bagus ikut tidak bisa dipinjam.  
- **Solusi**: Memperkenalkan kolom `stok_rusak` pada tabel `items`. Saat 1 unit rusak, kolom `stok` berkurang 1 dan `stok_rusak` bertambah 1, sedangkan status master barang tetap aktif sehingga unit yang masih baik tetap dapat digunakan untuk praktikum berikutnya.

---

## 5. Kesimpulan Akhir Proyek
Pengembangan aplikasi mobile **LabInventory** telah diselesaikan 100% dari Minggu 1 hingga Minggu 4. Aplikasi ini terbukti berfungsi dengan prima pada perangkat smartphone Android nyata, terhubung real-time ke Supabase Cloud Database, dan siap dipresentasikan untuk penilaian tugas besar mata kuliah Pemrograman Mobile.
