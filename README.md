# Absensi BUMDESMA Podo Rukun LKD — Mobile App (Flutter)

Aplikasi mobile untuk Sistem Manajemen Absensi Karyawan Berbasis QR Code
pada BUMDESMA Podo Rukun LKD, dibuat sesuai mockup dan workflow pada
Laporan Akhir (Sub Bab 3.2.6 – 3.2.10).

## Fitur yang sudah diimplementasikan

- **Login** dengan NIP + password, termasuk alur wajib ganti password
  pada login pertama.
- **Dashboard**: ringkasan absensi hari ini (jam masuk/pulang, status),
  panel notifikasi (jadwal piket & status izin/cuti).
- **Scan QR**: pilih Absen Masuk / Absen Pulang → kamera QR
  (`mobile_scanner`) → validasi token + **geofencing** (jarak GPS ke
  kantor, Haversine formula) → hasil (Tepat Waktu / Terlambat / Diterima /
  Lembur / Ditolak), sesuai mockup Gambar 3.26–3.34.
- **Ajukan Izin & Cuti**: tanggal, jenis, alasan, lampiran file
  (.pdf/.docx).
- **Riwayat**: daftar absensi bulanan dengan status berwarna.
- **Profile**: data pegawai, reset password, log-out.
- Aturan Sabtu piket: tombol absen otomatis disembunyikan jika karyawan
  tidak terjadwal piket pada hari Sabtu.

Semua data saat ini di-mock secara in-memory lewat `services/*_service.dart`
(masing-masing punya `abstract class` + implementasi mock), sehingga tinggal
menulis implementasi baru yang memanggil backend Node.js kamu dan mengganti
`SomeService.instance = RealService()` di `main.dart` / masing-masing file
service — tidak perlu mengubah UI sama sekali.

## Struktur proyek

```
lib/
  core/           # theme, .env wrapper, geofencing math (Haversine)
  models/         # AppUser, DailyAttendance, ScanResult, LeaveRequest, dll
  services/       # mock services (auth, attendance, leave, notification, settings)
  state/          # AuthProvider, AttendanceProvider (ChangeNotifier)
  screens/        # login, dashboard, scan, leave, history, profile
  shell/          # bottom navigation (Beranda/Riwayat/Scan/Izin/Profil)
  main.dart
.env                    # Maps API keys (JANGAN commit ke git — sudah di .gitignore)
.env.example            # template tanpa key asli
native_setup/           # panduan + snippet untuk wiring key Maps ke Android/iOS native
```

## Setup

### 1. Prasyarat

- Flutter SDK (channel stable, ≥ 3.22) — proyek ini dibuat/diuji secara
  manual tanpa akses ke `flutter` CLI, jadi jalankan `flutter doctor`
  dulu untuk memastikan environment kamu siap.

### 2. Install dependencies

```bash
cd absensi_bumdesma
flutter pub get
```

### 3. Generate folder platform (android/ ios/)

Folder `android/` dan `ios/` **belum disertakan** (dibuat oleh Flutter
tooling, bukan ditulis manual, supaya versi Gradle/Xcode selalu cocok
dengan Flutter SDK kamu). Generate dengan:

```bash
flutter create --platforms=android,ios --org com.bumdesma .
```

Perintah ini aman dijalankan di folder yang sudah berisi `lib/` dan
`pubspec.yaml` — ia hanya menambahkan folder platform yang belum ada,
tidak menimpa kode Dart kamu.

### 4. Wiring Google Maps API Key (Android & iOS)

Kunci di `.env` (`MAPS_API_ANDROID`, `MAPS_API_IOS`) dipakai oleh Maps
SDK secara **native**, bukan dibaca langsung oleh Dart saat runtime.
Ikuti file-file di `native_setup/`:

- `native_setup/android/AndroidManifest.xml.snippet` → tempel ke
  `android/app/src/main/AndroidManifest.xml`
- `native_setup/android/build.gradle.snippet` → tempel ke
  `android/app/build.gradle` (atau versi `.kts`)
- `native_setup/ios/Env.xcconfig.instructions` → buat
  `ios/Flutter/Env.xcconfig` dan sertakan di `Debug.xcconfig` /
  `Release.xcconfig`
- `native_setup/ios/Info.plist.snippet` → tempel ke
  `ios/Runner/Info.plist` dan `ios/Runner/AppDelegate.swift`

Dengan pola ini, key **hanya ada di satu tempat** (`.env`), tidak perlu
disalin manual ke berbagai file native, dan tidak pernah ter-commit ke
git (`.env` sudah masuk `.gitignore`; gunakan `.env.example` sebagai
referensi untuk kolaborator).

⚠️ **Catatan keamanan**: karena kedua key Maps sempat dibagikan secara
plaintext di percakapan ini, sebaiknya **rotate/regenerate** key
tersebut di Google Cloud Console, lalu batasi (restrict) key baru
berdasarkan nama paket Android / bundle ID iOS dan API yang diizinkan
(Maps SDK for Android/iOS saja).

### 5. Jalankan

```bash
flutter run
```

### Akun demo (mock)

| NIP | Password | Catatan |
|---|---|---|
| 3124510004 | temp1234 | Wajib ganti password (login pertama), terjadwal piket Sabtu |
| 3124510099 | sudahaman1 | Password sudah permanen |

QR Code yang valid untuk demo scan: buat QR Code apa saja yang berisi
teks persis berikut (misal via generator QR online), lalu scan dengan
kamera perangkat/emulator kamu:

```
BUMDESMA-PODORUKUN-LKD-OFFICE-TOKEN
```

Karena geofencing membandingkan lokasi GPS aktual perangkat terhadap
koordinat kantor di `.env` (`OFFICE_LATITUDE`/`OFFICE_LONGITUDE`,
radius `OFFICE_RADIUS_METERS`), saat testing di emulator kamu bisa
mengatur lokasi mock emulator ke koordinat yang sama agar validasi
lolos (di Android Studio: Extended Controls → Location).

## Menghubungkan ke backend nyata

Setiap file di `lib/services/` punya:

```dart
abstract class XxxService {
  static XxxService instance = MockXxxService();
  ...
}
```

Buat `class RealXxxService implements XxxService { ... }` yang memanggil
`Env.apiBaseUrl` via package `http`, lalu di `main.dart` (atau titik
inisialisasi lain) set `XxxService.instance = RealXxxService()` sebelum
`runApp()`. Tidak ada kode UI yang perlu diubah.
