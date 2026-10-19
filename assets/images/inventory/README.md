# Foto ilustrasi inventaris

Foto disimpan lokal dan digunakan sebagai ilustrasi jenis barang, bukan bukti
model atau kondisi unit laboratorium. Tidak ada unggahan maupun perubahan
skema database untuk penggunaan aset ini. Kredit dan tautan sumber/lisensi
tersedia melalui tombol **Kredit foto** di detail dan formulir peminjaman.

| Aset | Foto dan sumber | Pembuat | Lisensi |
| --- | --- | --- | --- |
| projector.jpg | [Epson EB-U04-5358.jpg](https://commons.wikimedia.org/wiki/File:Epson_EB-U04-5358.jpg) | © Raimond Spekking | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) |
| laptop.jpg | [Lenovo G500s laptop-2905.jpg](https://commons.wikimedia.org/wiki/File:Lenovo_G500s_laptop-2905.jpg) | © Raimond Spekking | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) |
| hdmi.jpg | [HDMI Cable.JPG](https://commons.wikimedia.org/wiki/File:HDMI_Cable.JPG) | © Kannan shanmugam, shanmugam studio, Kollam | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) |
| speaker.jpg | [JBL EON 1500.jpg](https://commons.wikimedia.org/wiki/File:JBL_EON_1500.jpg) | © Blurred Ren | [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/) |

Diunduh 19 Oktober 2026 melalui Wikimedia Commons. Aset menggunakan thumbnail
sumber: lebar 960 piksel untuk proyektor/laptop/HDMI dan 500 piksel untuk
speaker. Tidak disunting lagi setelah diunduh. Aplikasi menampilkan seluruh
gambar dengan BoxFit.contain.

Pemilihan berdasarkan kata pada nama barang: proyektor/projector,
laptop/notebook, HDMI, serta speaker/pengeras suara. Barang lainnya menampilkan
ikon netral dengan keterangan foto belum tersedia. Implementasi ada di
lib/presentation/inventory_image.dart. Untuk mengganti dengan foto unit asli,
perbarui aset dan keterangannya agar tidak lagi menyatakan foto ilustrasi.

Verifikasi: flutter analyze bersih; 7 test antarmuka lulus. Playwright pada
Chrome memverifikasi foto proyektor dan laptop di detail serta formulir,
tautan sumber pada dialog kredit, dan respons HTTP 200 image/jpeg untuk
keempat aset lokal. Tidak ada error console pada sesi pemeriksaan gambar.
Bukti: [form proyektor](../../../docs/evidence/assets-borrowing-form.png) dan
[form laptop](../../../docs/evidence/assets-laptop-form.png).
