# StudyBuddy — Flutter mobile, VS Code, dan akun bersama

StudyBuddy adalah aplikasi belajar Flutter/Dart yang dapat dikembangkan dari VS Code
tanpa Android Studio. Paket ini menyertakan backend PHP dan database MySQL/MariaDB
untuk pendaftaran, login di beberapa HP, profil, dan leaderboard.

Repositori asal: <https://github.com/ekahasbihabibi/studybuddy>

Mulai dari **[MULAI_DI_SINI.md](MULAI_DI_SINI.md)**.
Panduan akun/server: **[BACKEND_SERVER.md](BACKEND_SERVER.md)**.

## Isi aplikasi

- Modul belajar dan favorit.
- Kuis, penyimpanan skor, dan leaderboard bersama.
- Flashcard, target, jadwal, dan statistik belajar.
- Informasi beasiswa, TOEFL, kuliah, dan kerja di luar negeri.
- Daftar/login akun pada MySQL, sesi per perangkat, serta nama/foto profil bersama.

Favorit, tambahan flashcard, jadwal, dan target yang sebelumnya lokal tetap lokal;
belum menjadi sinkronisasi seluruh data belajar antarperangkat.

## Kebutuhan

| Komponen | Kegunaan |
| --- | --- |
| VS Code + Flutter/Dart extension | Editor, debug, hot reload |
| Flutter 3.32.8 / Dart 3.8.1 | Versi yang sesuai basis proyek |
| JDK 17 + Android SDK API 35/NDK 27 | Build Android; dipasang tanpa Android Studio |
| HP Android dan kabel data | Menjalankan/debug aplikasi |
| PHP 8.2+ dan MySQL/MariaDB, misalnya XAMPP | Backend akun bersama |
| Jaringan yang menjangkau server | Akses dari beberapa HP |

Setup SDK: `scripts/setup-windows.ps1`.
Setup database: `scripts/setup-backend.ps1`.
Server lokal: `scripts/start-backend.ps1`.
Menjalankan aplikasi: `scripts/run-android.ps1`.

Untuk instalasi yang sudah memiliki SDK, salin `.studybuddy-tools.json` dari proyek
lama ke folder proyek baru sebelum menggunakan wrapper Flutter.

## Menjalankan setelah database siap

Terminal pertama:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-backend.ps1
```

Terminal kedua, dengan HP terhubung:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter-command.ps1 pub get
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-android.ps1
```

Buat akun lewat menu **Daftar**. Tidak ada akun demo bawaan. Pada HP lain, login
menggunakan email/password yang sama dan alamat server yang sama.

Alamat API ada di `config/dev.json`; setup backend mengisinya menggunakan IPv4
laptop. Setelah mengubah alamat, hentikan aplikasi dan build/jalankan ulang.
Untuk HP di jaringan berbeda, gunakan server HTTPS sesuai `BACKEND_SERVER.md`.

## APK dan pengujian

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter-command.ps1 build apk --debug --dart-define-from-file=config/dev.json
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter-command.ps1 test
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter-command.ps1 analyze
```

APK debug: `build\app\outputs\flutter-apk\app-debug.apk`.
Hasil verifikasi dan batas pengujian ada di `HASIL_PEMERIKSAAN.md`.
Tes backend ada di `backend/tests`; gunakan database uji terpisah.

Konfigurasi F5 dan tugas setup/build/server tersedia pada folder `.vscode`.
Pada `flutter doctor`, yang perlu siap untuk Android adalah Flutter, Android toolchain,
dan HP. Peringatan Android Studio tidak terpasang tidak mengharuskan memasang editor itu.

## Pemecahan masalah

| Gejala | Langkah |
| --- | --- |
| `flutter` tidak ditemukan | Buka ulang VS Code atau gunakan wrapper `flutter-command.ps1`. |
| `.studybuddy-tools.json` belum ada | Salin dari proyek lama yang sudah berhasil, atau jalankan setup SDK. |
| Symlink tidak didukung | Aktifkan Developer Mode Windows, kemudian ulangi `pub get`. |
| MySQL belum dapat dihubungi | Start MySQL di XAMPP, periksa password administrator dan port. |
| PHP tidak ditemukan | Pasang XAMPP PHP 8.2+; gunakan parameter `-PhpPath` bila lokasinya berbeda. |
| Browser HP tidak bisa membuka `health.php` | Periksa IPv4, Wi-Fi, firewall Private, port, dan terminal server. |
| Daftar/login menampilkan waktu tunggu habis | Pastikan `health.php` dapat dibuka dari HP dan konfigurasi API benar. |
| Sesi berakhir | Login kembali; perubahan profil/score memerlukan sesi server yang valid. |
| Plugin belum tersedia setelah pembaruan | Hentikan aplikasi lalu lakukan build penuh setelah `pub get`. |
| HP `unauthorized` | Izinkan USB debugging pada layar HP. |
| Tidak ada HP terdeteksi | Periksa kabel data, port USB, dan driver merek HP. |

## Struktur dan versi

- `lib`: aplikasi Flutter.
- `backend/public`: document root API dan upload foto.
- `backend/src`: koneksi, autentikasi, dan endpoint backend.
- `backend/database/schema.sql`: struktur tabel.
- `backend/bin`: pemasangan/administrasi melalui CLI saja.
- `scripts`: setup dan perintah PowerShell.

Versi Flutter dipilih untuk kompatibilitas, bukan klaim sebagai versi terbaru.
Dependency lama dipertahankan; versi ini menambahkan `flutter_secure_storage` 9.2.4.
Folder iOS tetap tersedia; build iOS memerlukan macOS, Xcode, dan konfigurasi plugin
Keychain yang sesuai. Pengujian native iOS belum dilakukan.

Perubahan tersedia dalam ZIP dan tidak otomatis dipush ke GitHub. Hindari mengirim
`backend/config.local.php`, foto pengguna, `.studybuddy-tools.json`,
`android/local.properties`, `.dart_tool`, atau `build` ke repositori.
Backend lokal untuk pengujian; penggunaan internet memakai server HTTPS.
Konfigurasi release Android bawaan masih memakai debug key dan perlu signing sendiri
untuk publikasi Play Store.

Referensi: [Flutter/VS Code](https://docs.flutter.dev/install/with-vs-code),
[XAMPP](https://www.apachefriends.org/download.html),
[PHP](https://www.php.net/manual/en/),
[secure storage](https://pub.dev/packages/flutter_secure_storage/versions/9.2.4).
