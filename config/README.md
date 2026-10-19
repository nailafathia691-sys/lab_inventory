# Konfigurasi client Supabase

Salin `supabase.example.json` menjadi `supabase.local.json`, lalu isi URL dan
public publishable key atau legacy anon key proyek. File lokal diabaikan Git.

Folder ini dibundel sebagai aset Flutter supaya `flutter run` biasa dan tombol
Run pada `main.dart` dapat membaca konfigurasi lokal. Simpan hanya konfigurasi
client publik di folder ini. Password database, password pengguna, secret key,
dan service-role key tidak boleh disimpan di sini atau dimasukkan ke APK.

`--dart-define-from-file` dapat mengganti konfigurasi aset dengan URL dan public
key lengkap dari lingkungan lain. Override parsial ditolak. Setelah mengubah
file konfigurasi atau daftar aset, hentikan sesi Flutter dan jalankan kembali
agar APK/aset yang terpasang ikut diperbarui.

Demo memakai entry point terpisah dan tidak memuat konfigurasi Supabase.
