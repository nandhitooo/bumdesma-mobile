# Absensi BUMDESMA Podo Rukun LKD — Mobile App (Flutter)

Aplikasi mobile untuk Sistem Manajemen Absensi Pegawai Berbasis QR Code
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
- Aturan Sabtu piket: tombol absen otomatis disembunyikan jika pegawai
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
- **JDK 21** untuk build Android. Wajib diset lewat `flutter config --jdk-dir`,
  **bukan** `JAVA_HOME` dan **bukan** `android/gradle.properties`:

  ```bash
  # CachyOS
  flutter config --jdk-dir=/home/nandhitooo/.jdks/jdk-21.0.12.1+1
  # Windows (PowerShell)
  flutter config --jdk-dir="C:\Program Files\Java\jdk-21.0.12.1"
  ```

  Alasannya, urutan pencarian JDK di Flutter (`flutter_tools/lib/src/android/java.dart`)
  adalah: `flutter config --jdk-dir` → **JDK bawaan Android Studio** →
  `JAVA_HOME` → `java` di PATH. Artinya `JAVA_HOME` **kalah** oleh JBR Android
  Studio (di mesin ini JBR 25, sedangkan Gradle 8.14.1 hanya sampai Java 24 →
  `The Java version used for the build is 25.0.2, which is incompatible`).
  Cek JDK yang benar-benar dipakai: `flutter doctor -v` → baris `Java binary at:`.
- Copy `.env` dari `.env.example` kalau clone baru — `.env` di-`.gitignore`,
  dan `flutter_dotenv` akan error saat app start kalau asset-nya tidak ada.

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

## Menghubungkan app ke backend

`API_BASE_URL` di `.env` harus menunjuk ke backend yang benar — nilainya
berbeda tergantung cara menjalankan app (versi lengkap di `.env.example`):

| Cara menjalankan | Nilai | Catatan |
|---|---|---|
| HP/tablet fisik | `http://localhost:5000` | plus `adb reverse tcp:5000 tcp:5000` |
| Emulator (AVD) | `http://10.0.2.2:5000` | `10.0.2.2` = alias host dari dalam emulator |
| HP via Wi-Fi | `http://<IP-LAN-komputer>:5000` | satu jaringan + port 5000 diizinkan firewall |

Nilai ini **tanpa** akhiran `/api` — `ApiClient` yang menambahkan `/api`.

⚠️ `adb reverse` **hilang** setiap kali adb server restart atau device
tercabut. Gejalanya persis seperti backend mati: app tiba-tiba "tidak bisa
login" padahal server hidup. Solusinya cukup jalankan ulang:

```bash
adb reverse tcp:5000 tcp:5000
adb reverse --list   # untuk memastikan mapping-nya aktif
```

## Pindah OS (CachyOS ⇄ Windows)

Proyek ini dikerjakan di dua OS. Ada 2 hal yang **wajib** dijaga:

1. **Jangan commit/menyalin path absolut per-OS.** Yang sudah dibereskan:
   `org.gradle.java.home` di `android/gradle.properties` (dulu berisi path
   JDK CachyOS, bikin Gradle gagal total di Windows). Yang perlu kamu jaga:
   `android/local.properties` berisi `sdk.dir` + `flutter.sdk` yang berbeda
   tiap OS — file ini sudah di-`.gitignore`, jadi **jangan** disalin manual
   antar mesin dan jangan ditaruh di folder yang di-sync (OneDrive/drive
   bersama). Biarkan `flutter run`/Android Studio yang menulis ulang.
2. **Selalu bersihkan cache generated saat ganti OS**, karena isinya path
   absolut OS sebelumnya (`.flutter-plugins-dependencies` contohnya menunjuk
   ke pub cache Windows `C:\Users\...\Pub\Cache`, sedangkan di CachyOS
   pub cache-nya `~/.pub-cache`).
3. `android/app/build.gradle.kts` mem-pin `ndkVersion = "30.0.16248370"`
   (dan `compileSdk`/`targetSdk` 36). Kalau di OS satunya NDK/platform versi
   itu belum terinstall, Gradle berhenti dengan *“No version of NDK matched”*.
   Install lewat SDK Manager (`sdkmanager "ndk;30.0.16248370"
   "platforms;android-36"`), atau samakan `ndkVersion` di kedua mesin.

```bash
flutter clean
rm -rf .dart_tool build android/.gradle android/.kotlin .flutter-plugins-dependencies
flutter pub get
flutter run
```

Catatan: folder platform yang ada baru `android/`, `ios/`, dan `linux/`.
Kalau mau jalan di desktop Windows, generate dulu:

```bash
flutter create --platforms=windows .
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
