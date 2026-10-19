# Pengendalian Android dengan Playwright

Helper ini menggunakan Playwright `AndroidDevice` untuk mengetuk, mengisi,
menggeser, membaca widget, dan mengambil bukti layar aplikasi Android native.
Perangkat harus muncul pada `adb devices` dengan status `device`.
Gunakan package demo agar pengujian tidak mengubah database operasional.

Jalankan dari root repository:

```powershell
npm.cmd --prefix tools/device-tests ci --ignore-scripts --no-audit --no-fund
$env:PLAYWRIGHT_BROWSERS_PATH = Join-Path (Get-Location) '.dart_tool/playwright-browsers'
node tools/device-tests/node_modules/playwright/cli.js install android
flutter run -d SERIAL --flavor demo -t lib/main_demo.dart
```

Pada terminal kedua:

```powershell
node tools/device-tests/session.mjs SERIAL
```

Playwright memasang dua APK driver saat metode widget pertama dipakai. Ponsel
harus mengizinkan debugging dan instalasi melalui USB. Jika pemasangan otomatis
terputus, gunakan ADB dari SDK yang sama untuk memasang driver tanpa streaming:

```powershell
adb -s SERIAL install --no-streaming -r -t --user 0 .dart_tool/playwright-browsers/android-1001/android-driver.apk
adb -s SERIAL install --no-streaming -r -t --user 0 .dart_tool/playwright-browsers/android-1001/android-driver-target.apk
node tools/device-tests/session.mjs SERIAL --reuse-driver
```

Nomor direktori driver mengikuti versi Playwright yang terkunci di package-lock.
Opsi pemasangan ADB yang sama bisa digunakan untuk APK aplikasi yang dibangun
pada `build/app/outputs/flutter-apk/app-demo-debug.apk`.

Session menerima satu objek JSON per baris. Contoh setelah berada di login:

```json
{"action":"info","selector":{"desc":"MASUK"}}
{"action":"tap","selector":{"desc":"MASUK"}}
{"action":"tap","selector":{"desc":"Inventaris\nTab 2 of 4"}}
{"action":"info","selector":{"descRegex":"Laptop Demo[\\s\\S]*Stok: 3$"}}
{"action":"screenshot","filename":"student-catalog.png"}
{"action":"quit"}
```

Selector dibatasi secara default ke `com.example.lab_inventory.demo`. Tersedia
`info`, `tap`, `fill`, `wait`, `press`, `type`, `swipe`, `scroll`, `screenshot`,
dan `quit`. Pencocokan pola memakai `descRegex`, `textRegex`, atau `clazzRegex`.
`info`, `tap`, dan `fill` menunggu selector melalui polling; aksi UI diberi
jeda singkat agar animasi Flutter selesai. Sesuaikan selector dengan layar
serta role aktif.

Screenshot dibaca dari file sementara perangkat dalam potongan base64 8 KiB
untuk mengatasi transfer PNG terpotong yang ditemukan pada perangkat uji.
Panjang file dan penanda PNG diperiksa sebelum disimpan. File sementara milik
helper kemudian dihapus. Nama bukti dibatasi ke karakter aman dan direktori
`docs/evidence/device`. Setiap aksi ditambahkan ke `actions.jsonl`, termasuk
percobaan gagal; keberadaan helper belum membuktikan alur bisnis berhasil.

Untuk memeriksa checkpoint pada log sesi pengujian yang tercatat:

```powershell
node tools/device-tests/summarize.mjs
```

Skrip ini membaca log dan APK hasil build, memvalidasi PNG, lalu menulis
`native-checkpoints.json`. Skrip tidak menjalankan ulang alur dan tidak
menggantikan pemeriksaan urutan/status/stok pada perangkat. Nama item dan
checkpoint khusus untuk skenario demo dalam
[laporan pengujian fisik](../../docs/PENGUJIAN_DEVICE_2026-10-19.md).

Dokumentasi API: [Playwright AndroidDevice](https://playwright.dev/docs/api/class-androiddevice).
