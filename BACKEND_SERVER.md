# Akun bersama untuk beberapa HP

Backend PHP dan database MySQL/MariaDB sudah disertakan dalam folder `backend`.
Daftar akun satu kali di HP pertama, lalu login dengan email/password yang sama
pada HP lain. Semua HP harus memakai alamat server yang sama.

## Yang tersimpan di server

| Data | Lokasi |
| --- | --- |
| Akun, nama, email, dan hash password | MySQL/MariaDB |
| Sesi masing-masing HP | MySQL; HP menyimpan token sesi di secure storage |
| Nama dan foto profil | MySQL dan folder `backend/public/uploads` |
| Skor dan leaderboard | MySQL |
| Favorit, flashcard tambahan, jadwal, dan target yang sebelumnya lokal | Tetap menggunakan penyimpanan lokal aplikasi; belum disinkronkan ke server |

Tidak ada akun admin/demo bawaan. Buat akun melalui menu **Daftar**.
Password minimal 8 karakter, maksimal 72 byte. Password asli tidak disimpan.
Keluar dari satu HP tidak mengeluarkan HP lain; sesi berlaku 30 hari.
Jika logout dilakukan saat server tidak terjangkau, sesi di HP dihapus dan sesi
server berakhir sesuai masa berlakunya.

## 1. Siapkan PHP dan MySQL di laptop

1. Gunakan XAMPP Windows dengan PHP 8.2 atau lebih baru. PHP 8.3 sesuai versi utama
   yang dipakai untuk pengujian. Unduh dari <https://www.apachefriends.org/download.html>.
2. Buka **XAMPP Control Panel** dan klik **Start** pada **MySQL**.
3. Pastikan HP dan laptop terhubung ke Wi-Fi/jaringan lokal yang sama.

Alur lokal ini memakai PHP dari XAMPP dan MySQL. Apache tidak perlu dinyalakan
karena skrip menyediakan server PHP tersendiri. Kode Flutter tetap dikerjakan di VS Code.

## 2. Jika memakai ZIP terbaru sebagai folder proyek baru

Jika SDK sudah disiapkan pada versi sebelumnya, salin file `.studybuddy-tools.json`
dari folder proyek lama ke folder `studybuddy` dalam ZIP terbaru. File ini berisi
lokasi SDK laptop, sehingga pemasangan SDK tidak perlu diulang. Buka folder proyek
baru tersebut melalui **File > Open Folder** di VS Code.

Untuk instalasi yang benar-benar baru, jalankan `scripts/setup-windows.ps1`
sesuai `MULAI_DI_SINI.md` terlebih dahulu. Jika Developer Mode Windows belum aktif,
buka `ms-settings:developers` dan aktifkan agar plugin Flutter dapat membuat symlink.

Jika sebelumnya sudah memasang backend revisi ini, pertahankan
`backend/config.local.php` dan isi `backend/public/uploads` ketika memperbarui kode.
Database tetap berada di MySQL, terpisah dari folder Flutter.

## 3. Buat database dan hubungkan alamat server

Dari terminal PowerShell VS Code pada folder yang berisi `pubspec.yaml`, jalankan:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-backend.ps1
```

Skrip memilih IPv4 jaringan laptop. Jika ada beberapa pilihan, gunakan IPv4 Wi-Fi
yang terhubung ke jaringan HP. Password administrator MySQL diminta sekali;
untuk XAMPP lokal dengan password root yang masih kosong, tekan **Enter**.
Password tersebut tidak ditulis ke kode aplikasi Flutter.

Skrip akan membuat database `studybuddy_app`, tabel yang diperlukan, akun database
khusus aplikasi, konfigurasi backend, dan memperbarui `config/dev.json`.
Akun database aplikasi mendapat izin SELECT/INSERT/UPDATE/DELETE saja.
Menjalankan ulang setup mempertahankan data akun yang sudah dibuat.

Jika perlu menentukan lokasi PHP, IPv4, atau port secara manual:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-backend.ps1 -PhpPath "C:\xampp\php\php.exe" -ServerIp "192.168.1.10" -Port 8080 -DbPort 3306
```

Alamat IPv4 di atas hanya contoh; gunakan alamat laptopmu.

## 4. Jalankan server dan cek dari HP

Di terminal pertama:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-backend.ps1
```

Biarkan terminal itu tetap terbuka. Jika Windows Firewall meminta izin untuk PHP,
izinkan pada jaringan **Private** yang dipakai laptop dan HP.

Skrip menampilkan alamat pemeriksaan. Buka alamat tersebut dari **browser HP**,
misalnya:

```text
http://192.168.1.10:8080/health.php
```

Hasil yang benar:

```json
{"success":true,"service":"StudyBuddy API","database":"connected"}
```

Jika browser HP belum bisa membuka alamat itu, perbaiki jaringan/firewall/port dahulu.
Hindari jaringan tamu yang mengisolasi perangkat. Pastikan IPv4, MySQL, dan terminal
server masih aktif. Gunakan alamat yang dicetak skrip, bukan alamat contoh di panduan.

## 5. Jalankan Flutter dan buat akun

Buka **terminal kedua** di VS Code:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter-command.ps1 pub get
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-android.ps1
```

Ada tambahan plugin secure storage pada versi ini. Hentikan aplikasi lama dan build
ulang; hot reload saja tidak cukup.

Di HP pertama, pilih **Daftar**, masukkan nama, email, serta password minimal 8 karakter.
Setelah berhasil, login memakai akun tersebut. Di HP kedua, gunakan akun yang sama.
Jika memakai akun berbeda, daftar dengan email lain. Foto/nama profil serta leaderboard
mengikuti data pada server yang sama.

## 6. Pasang di HP lain

Buat APK debug dengan alamat server yang sudah diatur:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter-command.ps1 build apk --debug --dart-define-from-file=config/dev.json
```

Hasil ada di `build\app\outputs\flutter-apk\app-debug.apk`.
Pasang APK pada HP lain yang dapat menjangkau server, lalu login.
Kabel USB hanya diperlukan untuk menjalankan/debug langsung dari laptop; APK yang
sudah dipasang memakai jaringan untuk mengakses server.

Untuk pengujian lokal, laptop dan MySQL harus tetap menyala. Jika IPv4 laptop berubah,
jalankan setup backend dengan IPv4 baru, kemudian bangun ulang aplikasi untuk semua HP.

## 7. Jika HP berada di jaringan atau lokasi berbeda

Gunakan hosting/server yang menyediakan PHP 8.2+, MySQL/MariaDB, dan HTTPS.
Server PHP bawaan pada skrip lokal ditujukan untuk pengujian di jaringan lokal tepercaya.
Untuk penggunaan internet, gunakan Apache/Nginx atau layanan hosting PHP.

1. Buat database serta pengguna database khusus pada hosting.
2. Import `backend/database/schema.sql` ke database tersebut menggunakan pengguna
   administrator/migrasi. Pengguna runtime aplikasi cukup mendapat izin data.
3. Unggah folder backend. Atur **document root hanya ke `backend/public`**.
   Folder `src`, `bin`, `database`, dan konfigurasi harus berada di luar document root.
4. Salin `backend/config.example.php` menjadi `backend/config.local.php`.
   Isi host/port/nama/pengguna/password database dan `base_url` HTTPS yang benar.
   Biarkan `environment` bernilai `production`.
5. Pastikan proses PHP dapat membaca konfigurasi dan menulis ke `public/uploads`.
   Jika memakai Apache, izinkan aturan `.htaccess` yang disertakan. Pada Nginx,
   teruskan header Authorization ke PHP dan larang eksekusi skrip di folder uploads.
6. Pastikan PHP mengetahui koneksi HTTPS. Jika TLS diakhiri oleh reverse proxy,
   atur HTTPS pada konfigurasi web server/FastCGI yang dipercaya, bukan melalui
   header publik tanpa validasi.
7. Buka `https://alamat-servermu/health.php`. Setelah database terhubung, ubah
   `config/dev.json` pada Flutter ke base URL HTTPS tersebut dan bangun ulang APK.

Hosting/domain tidak disediakan atau dipublikasikan oleh paket ini. Konfigurasi
release asli aplikasi masih memakai debug key; gunakan signing milikmu sebelum
publikasi ke Play Store.

## Endpoint

| Endpoint | Metode | Sesi login |
| --- | --- | --- |
| `health.php` | GET | Tidak |
| `register.php` | POST JSON | Tidak |
| `login.php` | POST JSON | Tidak |
| `logout.php` | POST JSON | Ya |
| `get_profile.php` | GET | Ya |
| `update_profile.php` | POST JSON | Ya |
| `upload_profile.php` | POST multipart, field `image` | Ya |
| `delete_profile_picture.php` | POST JSON | Ya |
| `insert_score.php` | POST JSON | Ya |
| `get_leaderboard_by_subject.php?subject=...` | GET | Ya |
| `get_all_leaderboard.php` | GET | Ya |

Endpoint terproteksi memerlukan `Authorization: Bearer <token>` yang diperoleh dari
login. Identitas profil dan pemilik skor ditentukan oleh token; email/nama kiriman
klien tidak dapat dipakai untuk mengubah akun orang lain.

Tabel: `users`, `sessions`, `quiz_scores`, dan `rate_limits`. Password dan token sesi
pada database berbentuk hash. Foto menerima JPG/PNG/WebP yang diverifikasi, maksimal
2 MB, dengan nama file acak. Percobaan daftar/login dibatasi. Skor masih berasal dari
klien Flutter; sistem anticurang dan penilaian kuis di server belum dibuat.
Verifikasi email, reset password lewat email, dan dashboard admin belum termasuk.

Untuk membersihkan sesi kedaluwarsa dan catatan pembatasan lama, jalankan pada server:

```sh
php backend/bin/prune.php
```

Cadangkan database dan folder uploads. Contoh ekspor di Windows menggunakan
`--result-file` agar tidak terkena encoding redirection PowerShell:

```powershell
C:\xampp\mysql\bin\mysqldump.exe -u root -p --single-transaction --result-file=C:\Backups\studybuddy_app.sql studybuddy_app
```

Buat folder `C:\Backups` dahulu dan sesuaikan database/kredensial bila berbeda.

## Referensi resmi

- XAMPP: <https://www.apachefriends.org/download.html>
- PHP password hashing: <https://www.php.net/manual/en/ref.password.php>
- PDO prepared statements: <https://www.php.net/manual/en/pdo.prepared-statements.php>
- PHP development server: <https://www.php.net/manual/en/features.commandline.webserver.php>
- Flutter secure storage: <https://pub.dev/packages/flutter_secure_storage/versions/9.2.4>
