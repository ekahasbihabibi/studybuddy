# Menjalankan StudyBuddy di VS Code

StudyBuddy tetap aplikasi mobile Flutter. Akun, profil, dan leaderboard sekarang
memakai backend PHP dan database MySQL bersama untuk beberapa HP.

## Jika Flutter sudah berhasil dibuka di HP

1. Ekstrak ZIP terbaru ke folder baru.
2. Salin `.studybuddy-tools.json` dari folder proyek lama ke folder `studybuddy`
   yang baru. Buka folder baru itu di VS Code.
3. Buka XAMPP Control Panel dan **Start MySQL**. Gunakan PHP 8.2+.
   Jika belum memiliki XAMPP: <https://www.apachefriends.org/download.html>.
4. Di terminal VS Code, jalankan:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-backend.ps1
   ```

   Password MySQL lokal diminta; tekan Enter jika password root XAMPP masih kosong.
5. Jalankan server, lalu biarkan terminal ini terbuka:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-backend.ps1
   ```

6. Dari browser HP, buka alamat `.../health.php` yang ditampilkan skrip. Pastikan
   hasilnya menunjukkan `"database":"connected"`. Laptop dan HP berada di Wi-Fi yang sama.
7. Buka terminal kedua dan jalankan:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter-command.ps1 pub get
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-android.ps1
   ```

8. Pilih **Daftar** di aplikasi, buat email/password sendiri, lalu login. Akun yang
   sama bisa dipakai pada HP lain yang mengakses server yang sama.

Tidak ada akun/password demo bawaan. Backend harus tetap berjalan untuk penggunaan
lokal. Panduan lengkap, pemasangan APK di HP lain, dan hosting HTTPS ada di `BACKEND_SERVER.md`.

## Jika baru pertama kali memasang Flutter

1. Pasang Git for Windows, VS Code, dan extension Flutter dari Dart Code.
2. Ekstrak proyek ke folder pendek, lalu buka folder yang berisi `pubspec.yaml`.
3. Aktifkan Developer Mode Windows untuk symlink plugin Flutter.
4. Jalankan setup SDK tanpa Android Studio:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1
   ```

5. Baca/setujui lisensi Android jika setuju, tunggu selesai, lalu buka ulang VS Code.
6. Ikuti langkah XAMPP/backend di atas mulai langkah 3.
7. Untuk debug di HP, aktifkan Opsi Pengembang > USB debugging, sambungkan kabel
   data, dan setujui izin debugging pada layar HP.
