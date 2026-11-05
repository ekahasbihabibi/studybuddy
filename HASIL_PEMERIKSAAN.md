# Hasil pemeriksaan paket akun bersama

Paket terbaru mempertahankan aplikasi mobile Flutter dan alur VS Code tanpa
Android Studio, serta menambahkan backend PHP dan MySQL/MariaDB untuk beberapa HP.

## Perubahan utama

- Registrasi akun di database server dan login menggunakan email/password sendiri.
- Sesi terpisah per perangkat; logout online hanya mencabut sesi perangkat tersebut.
- Password di-hash, token server disimpan sebagai hash, dan token pada HP memakai secure storage.
- Profil, foto profil, dan leaderboard menggunakan identitas yang diverifikasi server.
- Endpoint tidak mempercayai email/nama yang dikirim klien untuk memilih pemilik data.
- Validasi input, pembatasan percobaan daftar/login, serta pembatasan foto maksimal 2 MB.
- Tombol login/daftar menampilkan proses, batas waktu 12 detik, dan pesan gagal yang tetap terlihat.
- Skrip setup database dan server lokal serta panduan memakai server HTTPS.

## Verifikasi yang dilakukan

| Pemeriksaan | Hasil |
| --- | --- |
| `flutter pub get` | Berhasil; tambahan secure storage dan dependency terkait |
| Tes Flutter biasa | 17 tes lolos tanpa server |
| Tes Flutter layanan-ke-server | 1 tes lolos dengan PHP/MySQL sungguhan; dua sesi, profil bersama, skor, dan logout |
| Tes backend HTTP/database | 39 pemeriksaan lolos |
| Sintaks PHP | 20 berkas lolos pemeriksaan PHP |
| Setup backend PowerShell | Lolos dengan database sungguhan dan folder dengan spasi; konfigurasi API diperbarui dan environment proses dipulihkan |
| Parser PowerShell | Seluruh skrip valid |
| JSON VS Code/config dan XML Android | Valid |
| `flutter analyze` | 0 error, 4 warning, 33 info lint; belum sepenuhnya bersih dari lint |

Tes backend membuktikan email unik tanpa membedakan huruf besar/kecil, password
salah ditolak, password/token tidak disimpan sebagai plaintext, dua sesi akun yang
sama dapat aktif bersamaan, profil antar-akun terpisah, foto ditangani sesuai sesi,
leaderboard bersama, logout satu sesi tidak mencabut sesi lainnya, kedaluwarsa sesi,
setup ulang mempertahankan akun, serta percobaan login berulang dibatasi.

Lingkungan verifikasi: Linux, Flutter 3.32.8/Dart 3.8.1, PHP 8.3.6,
MariaDB 10.11.7, dan PowerShell 7.4.6. Simulasi dua klien dilakukan melalui HTTP
nyata. Penyimpanan perangkat pada tes Flutter memakai mock; belum diuji dengan
perangkat Android fisik atau Windows asli. APK native dan iOS belum dibangun di sini.

## Batas penggunaan

Server belum dipasang di laptop/domain pengguna. Ikuti `BACKEND_SERVER.md` untuk
menyalakan MySQL, membuat konfigurasi backend, serta memeriksa `health.php` dari HP.
Tidak ada akun/password demo; daftar akun setelah server aktif.

Akun, profil, foto, dan skor memakai server. Data belajar yang sebelumnya lokal
seperti favorit, jadwal, target, dan flashcard tambahan belum disinkronkan.
Verifikasi email, reset password, anticurang kuis, dan dashboard admin belum termasuk.
Pengujian lokal memakai server PHP bawaan; penggunaan internet memerlukan server HTTPS.
