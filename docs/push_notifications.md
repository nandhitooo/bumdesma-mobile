# Push Notification ke Notif Bar HP (FCM)

Dokumen ini menjelaskan alur push notification end-to-end untuk notifikasi
piket dan keputusan izin/cuti, agar notif muncul di **notif bar HP**
(Android/iOS), bukan hanya di panel lonceng dalam app.

## Gambaran Alur

1. Karyawan login di app → `AuthProvider.login` memanggil
   `FcmPushService.instance.start(nip)`.
2. `FcmPushService` meminta izin notifikasi (Android 13+ / iOS), membuat
   channel Android `piket` & `izin_cuti`, lalu mengambil FCM token perangkat.
3. Token didaftarkan ke backend via `POST /api/push/register`
   (`{ nip, token, platform }`) dengan header `Authorization: Bearer` dari
   sesi login (lewat `ApiClient`, base URL = `API_BASE_URL`).
4. Saat Admin/Pimpinan memutuskan izin/cuti atau menekan tombol
   "Kirim Notifikasi" piket, backend `notifier.js` membuat notifikasi in-app
   (tabel `notifications`) **dan sekaligus** mengirim push FCM ke semua
   token milik karyawan tersebut (tabel `push_tokens`).
5. OS menampilkan notifikasi di notif bar (app boleh sedang background
   atau ditutup). Saat app foreground, `FcmPushService` menampilkannya
   sendiri via flutter_local_notifications.
6. Logout → app memanggil `POST /api/push/unregister` (masih membawa Bearer,
   sebelum `SessionStore` dibersihkan) → baris token dihapus.

## Setup Firebase (sekali)

1. Buka https://console.firebase.google.com → buat project (atau pakai
   yang sudah ada) — project saat ini: `absensi-bumdesma`.
2. Tambahkan aplikasi **Android** dengan package name
   `com.bumdesma.absensi_bumdesma` (harus persis sama dengan
   `applicationId`).
3. Unduh `google-services.json` → simpan di
   `android/app/google-services.json`. (Sudah ada; file ini di-apply
   kondisional oleh `android/app/build.gradle.kts` sehingga build tetap
   jalan meski file belum ada, mis. di CI.)
4. (Opsional, untuk iOS) tambahkan app iOS dan ikuti langkah
   APNs + `GoogleService-Info.plist`.
5. Buat **Service Account** (Project settings → Service accounts →
   Generate new private key) → unduh JSON → simpan aman di server
   backend, JANGAN di-commit.

## Sisi Frontend (sudah selesai)

- `pubspec.yaml`: `firebase_core`, `firebase_messaging`,
  `flutter_local_notifications`.
- `android/app/src/main/AndroidManifest.xml`: permission
  `POST_NOTIFICATIONS` (Android 13+) + meta-data channel default `piket`.
- `lib/services/fcm_push_service.dart`: izin notifikasi, channel, token,
  tampil notif saat foreground. Register/unregister token memakai
  `ApiClient` (otomatis `Authorization: Bearer` + retry 401 via refresh
  token) ke `/push/register` & `/push/unregister`.
- `lib/state/auth_provider.dart`: `start()` saat login; saat logout,
  `stop()` dipanggil **sebelum** `AuthService.logout()` supaya sesi masih
  ada saat unregister.
- `.env`: `PUSH_NOTIFICATIONS_ENABLED=true`. Endpoint pendaftaran token
  otomatis mengikuti `API_BASE_URL`.

## Sisi Backend (bumdesma-backend, sudah selesai)

### Struktur file

| File | Isi |
|------|-----|
| `src/migrations/20260914000001-create-push-tokens.js` | Tabel `push_tokens` (FK ke `users.id`, unique `(user_id, token)`) |
| `src/models/pushToken.model.js` | Model Sequelize `PushToken` |
| `src/services/push.service.js` | `pushToUser(userId, { title, message, type, notificationId })` via `firebase-admin` |
| `src/controllers/push.controller.js` | `register` / `unregister` token |
| `src/routes/push.routes.js` | `POST /api/push/register` & `/api/push/unregister` (diproteksi `authenticate`) |
| `src/utils/notifier.js` | Setiap `notifyUser`/`notifyUsers` otomatis menyisipkan push FCM |

### 1. Install & migrasi (sekali)

```bash
npm install                # firebase-admin sudah ada di package.json
npm run db:migrate         # membuat tabel push_tokens
```

### 2. Kredensial service account

Tambahkan ke `.env` backend:

```
GOOGLE_APPLICATION_CREDENTIALS=/var/secrets/bumdesma-firebase-sa.json
```

`push.service.js` memanggil `admin.initializeApp()` tanpa argumen, jadi
firebase-admin membaca env var tersebut otomatis. **Tanpa env ini server
tetap jalan** — push FCM dilewati dengan warning `[push]` di log, dan
notifikasi in-app tetap normal (penting untuk dev tanpa kredensial).

### 3. Titik pengiriman

Tidak perlu memanggil push manual di controller. Dua titik ini otomatis
terpush lewat `notifier.js`:

- `leave.controller.js#decide` → type `izin_cuti`
  (channel Android `izin_cuti`).
- `piket.controller.js#notify` → type `piket`
  (channel Android `piket`).

`pushToUser` menggunakan multicast `sendEachForMulticast` ke semua token
milik user (satu orang bisa login di >1 perangkat), memilih channel
Android sesuai `type`, lalu menghapus token invalid (app diuninstall)
dari `push_tokens`. Push gagal **tidak pernah** menggagalkan request
utama — semua error ditelan dengan log `[push]`.

## Format Payload

| Field | Keterangan |
|-------|-----------|
| `notification.title` | Judul di notif bar |
| `notification.body` | Isi notif |
| `android.channel_id` | `piket` atau `izin_cuti` |
| `data.type` | `piket` / `izin_cuti` |
| `data.notification_id` | UUID baris notifikasi in-app (untuk deeplink) |

## Checklist Testing

1. Setup service account di `.env` backend (langkah 2 di atas), lalu
   `npm run db:migrate` dan restart server.
2. `flutter clean && flutter pub get`, jalankan `flutter run`.
3. Saat pertama login, dialog "izinkan notifikasi" muncul → pilih izinkan.
4. Cek log backend saat login: `POST /api/push/register` 200 (dengan
   Bearer token), baris baru di tabel `push_tokens`.
5. Trigger keputusan izin dari akun Pimpinan → notif muncul di notif bar
   HP meski app di background.
6. App foreground → notif tetap muncul (dikirim flutter_local_notifications).
7. Logout → baris token terhapus dari `push_tokens`.
8. Matikan `GOOGLE_APPLICATION_CREDENTIALS` → server tetap hidup, muncul
   warning `[push]`, notifikasi in-app tetap jalan.
