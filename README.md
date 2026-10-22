# MatchDay

## Deskripsi Singkat
**MatchDay** adalah aplikasi mobile berbasis Flutter yang menampilkan jadwal pertandingan sepak bola dunia beserta skor, history pertandingan, dan formasi kedua tim. Data diambil secara dinamis dari ESPN public soccer API (gratis, tanpa API key) dan mencakup beberapa liga top dunia: Premier League, La Liga, Serie A, Bundesliga, Ligue 1, Champions League, dan Liga 1 Indonesia.

Aplikasi ini dibuat sebagai tugas UTS mata kuliah Pemrograman Mobile.

## Fitur Utama
1. **Home**
   - *Live Now*: carousel kartu pertandingan yang sedang berlangsung (skor, menit, pencetak gol). Jika tidak ada pertandingan live, ditampilkan *Latest Results*.
   - *Upcoming Fixtures*: daftar pertandingan mendatang (jam, stadion, kedua tim).
   - Pemilih tanggal (Today + 4 hari ke depan + kalender) di antara *Live Now/Latest Results* dan *Upcoming Fixtures* untuk melihat jadwal pada hari tertentu.
2. **Matches**
   - Tab **Upcoming**: seluruh jadwal pertandingan yang akan datang, dikelompokkan per tanggal.
   - Tab **Results**: riwayat pertandingan dengan skor akhir.
   - Filter per liga (All, EPL, La Liga, Serie A, Bundesliga, Ligue 1, UCL, Liga 1).
3. **Match Details** (buka dengan menekan pertandingan)
   - Skor, status, stadion, dan waktu pertandingan.
   - Kejadian pertandingan (gol, kartu, pergantian pemain).
   - **Formasi kedua tim** pada visual lapangan + daftar susunan pemain (Starting XI).
4. Penanganan state asynchronous dengan `FutureBuilder`: **Loading**, **Success**, dan **Error** (dengan tombol *Try again*), serta *pull-to-refresh*.

## Teknologi / Package yang Digunakan
| Teknologi | Fungsi |
|---|---|
| Flutter & Dart | Framework dan bahasa pemrograman |
| `http` | Mengirim permintaan HTTP ke API |
| `intl` | Format tanggal dan jam |
| ESPN Public Soccer API | Sumber data (gratis, tanpa API key) |

Endpoint yang dipakai:
- Jadwal & skor: `https://site.api.espn.com/apis/site/v2/sports/soccer/{kode-liga}/scoreboard?dates=YYYYMMDD-YYYYMMDD`
- Detail (formasi, kejadian pertandingan): `https://site.api.espn.com/apis/site/v2/sports/soccer/{kode-liga}/summary?event={id}`

> Catatan: Formasi baru tersedia setelah susunan pemain diumumkan (sekitar 1 jam sebelum kick-off).

## Langkah Menjalankan Aplikasi
1. Pastikan **Flutter SDK** (Dart 3.3+) sudah terpasang. Cek dengan `flutter doctor`.
2. Buat project Flutter kosong:
   ```bash
   flutter create matchday
   cd matchday
   ```
3. Salin isi folder ini ke project tersebut:
   - Ganti folder `lib/` dengan folder `lib/` dari repositori ini.
   - Ganti `pubspec.yaml` dengan `pubspec.yaml` dari repositori ini.
   - Hapus file `test/widget_test.dart` (bawaan template, merujuk ke aplikasi counter).
4. **Android**: buka `android/app/src/main/AndroidManifest.xml`, lalu tambahkan di dalam tag `<manifest>` (di atas `<application>`):
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```
5. Install dependensi:
   ```bash
   flutter pub get
   ```
6. Jalankan (emulator/perangkat Android, iOS simulator, atau Chrome):
   ```bash
   flutter run
   ```
   Atau buka `lib/main.dart` di VS Code / Android Studio lalu tekan **Run**.