# Login dan pendaftaran dengan backend bersama

Revisi terbaru sudah menambahkan backend PHP dan database MySQL/MariaDB.
Panduan sekarang ada di **MULAI_DI_SINI.md** dan **BACKEND_SERVER.md**.

Tombol Login/Daftar memiliki indikator proses, batas tunggu 12 detik, serta pesan
gagal yang tetap terlihat. Pendaftaran memerlukan password minimal 8 karakter.
Sesi login disimpan melalui secure storage dan diverifikasi server.

Karena revisi ini menambahkan plugin native dan backend, gunakan paket lengkap terbaru.
Jangan hanya menyalin folder `lib` dari revisi ini ke proyek lama. Cara mempertahankan
SDK yang sudah terpasang dijelaskan pada bagian awal `BACKEND_SERVER.md`.

Tidak ada akun/password demo bawaan. Aktifkan MySQL, jalankan setup backend dan server,
pastikan alamat `health.php` dapat dibuka dari HP, lalu daftar akun sendiri.
