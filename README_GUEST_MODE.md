# Dokumentasi Fitur Guest Mode (Mode Tamu)
**Aplikasi Mobile RS PKU Muhammadiyah Gamping**

---

## 1. Ringkasan Fitur
Fitur **Guest Mode (Mode Tamu)** memungkinkan masyarakat dan calon pasien untuk membuka dan menelusuri informasi **Jadwal Dokter & Poliklinik** secara langsung dari halaman Login tanpa perlu memiliki akun atau melakukan login terlebih dahulu. 

Hak akses pada mode ini dibatasi secara ketat (**Read-Only**) untuk mencegah tindakan pendaftaran/booking antrean maupun akses data rekam medis tanpa autentikasi yang sah.

---

## 2. Alur Pengguna (User Flow - Opsi A)

```
[Halaman Login]
       │
       ▼ (Klik "Lihat Jadwal Dokter (Mode Tamu)")
[Set Sesi: SessionManager.isGuest = true]
       │
       ▼
[Halaman Jadwal Dokter & Poliklinik]
  ├── Fitur Aktif:
  │    ├── Filter Tanggal Praktik (Date Strip)
  │    ├── Filter Kategori Poliklinik (Poli Chips)
  │    ├── Pencarian Nama Dokter & Spesialisasi (Search Bar)
  │    └── Lihat Jam Praktik & Status Dokter
  │
  └── Pembatasan Akses (Read-Only Guard):
       ├── Bottom Bar 5 Tab disembunyikan (agar tidak membingungkan)
       ├── Tombol Kembali (Back) & Tombol "Masuk" tersedia di Header
       ├── Banner Informatif Mode Tamu aktif di atas
       ├── Sticky Action Bar bawah: "Masuk untuk Mendaftar Antrean"
       │
       └── Klik Kartu Dokter ──► Membuka [GuestLoginPromptDialog]
                                  ├── Tombol "Masuk ke Akun Pasien"
                                  ├── Tombol "Daftar Pasien Baru"
                                  └── Tombol "Lanjut Lihat Jadwal"
```

---

## 3. Daftar File yang Ditambahkan & Dimodifikasi

### A. File Baru
| No | File Path | Fungsi / Deskripsi |
|---|---|---|
| 1 | `lib/widgets/guest_login_prompt_dialog.dart` | Dialog modal informatif yang muncul saat tamu mencoba melakukan booking/pendaftaran dokter. Mengarahkan pengguna untuk login atau mendaftar akun baru. |
| 2 | `README_GUEST_MODE.md` | Dokumentasi arsitektur, alur, dan file implementasi fitur Mode Tamu. |

### B. File yang Dimodifikasi
| No | File Path | Perubahan yang Dilakukan |
|---|---|---|
| 1 | `lib/core/session/session_manager.dart` | - Menambahkan key `_keyIsGuest = 'pku_is_guest'`.<br>- Menambahkan getter `SessionManager.isGuest`.<br>- Menambahkan method `SessionManager.setGuestMode(bool)`.<br>- Auto-reset status tamu saat login sukses (`saveSession`) atau logout (`clearSession`). |
| 2 | `lib/core/routes/app_router.dart` | - Menambahkan rute terpusat baru `AppRoutes.jadwal = '/jadwal'`.<br>- Menambahkan handler rute `case AppRoutes.jadwal` dengan flag tamu.<br>- Menambahkan **Route Guard** pada `AppRoutes.pendaftaran`: jika diakses oleh tamu, otomatis dialihkan ke halaman login dengan notifikasi. |
| 3 | `lib/screens/login_screen.dart` | - Menambahkan tombol pill ramping `[Mode Tamu ➔]` di pojok kanan atas layar login.<br>- Menjaga area tombol Masuk tetap bersih, elegan, dan fokus tanpa elemen bertumpuk di bawah form.<br>- Handler tombol mengaktifkan status tamu (`SessionManager.setGuestMode(true)`) dan bernavigasi ke layar jadwal. |
| 4 | `lib/widgets/hospital_brand_header.dart` | - Menambahkan dukungan `leadingWidget` dan `trailingWidget`.<br>- Memungkinkan penempatan tombol Back di kiri dan tombol cepat *"Masuk"* di kanan khusus saat Mode Tamu aktif. |
| 5 | `lib/screens/jadwal_screen.dart` | - Menambahkan parameter `isGuestMode` dan deteksi status tamu.<br>- Menampilkan banner info Mode Tamu bernuansa biru lembut di bawah header.<br>- Menyembunyikan bottom navigation 5 tab bawaan.<br>- Menambahkan sticky bar bawah berisi tombol *"Masuk untuk Mendaftar Antrean"*. |
| 6 | `lib/screens/jadwal_widgets/jadwal_dokter_list.dart` | - Menambahkan proteksi klik pada `JadwalDokterCard`.<br>- Jika pengguna berstatus tamu, sistem memicu `GuestLoginPromptDialog.show(...)` dengan membawa konteks nama dokter dan poli yang dipilih, alih-alih membuka form pendaftaran. |

---

## 4. Keamanan & Pembatasan Hak Akses (Multi-Layer Protection)

1. **Proteksi UI / UX Level:**
   - Elemen interaktif pendaftaran pada kartu dokter diintersep dengan dialog autentikasi.
   - Tab navigasi lain (Beranda, Antrean Pasien, Profil) tidak dimuat ke dalam antarmuka tamu.
2. **Proteksi Routing Level:**
   - Navigasi programatik ke rute `/pendaftaran` dijaga oleh pengecekan `SessionManager.isGuest`.
3. **Proteksi State Sesi:**
   - Flag `isGuest` disimpan terisolasi dan akan otomatis di-reset saat sesi login sebenarnya dibuat.


### BEDA

Implementasi **Fitur Guest Mode (Mode Tamu - Opsi A)** telah selesai dibuat. Seluruh dokumentasi teknis dan alurnya juga telah dibuatkan dalam file [README_GUEST_MODE.md](file:///d:/pku-gamping-mobile/README_GUEST_MODE.md).

Berikut adalah rangkuman detail apa saja yang ditambahkan dan dimodifikasi:

---

### 1. File Baru yang Ditambahkan

1. [guest_login_prompt_dialog.dart](file:///d:/pku-gamping-mobile/lib/widgets/guest_login_prompt_dialog.dart)
   * **Deskripsi**: Widget dialog modal interaktif yang muncul saat tamu mencoba booking/mendaftar dokter.
   * **Konten**: Memberikan pesan bahwa pendaftaran dengan dokter terkait memerlukan akun terdaftar, dilengkapi 3 tombol aksi:
     * **"Masuk ke Akun Pasien"** (navigasi ke Login)
     * **"Daftar Pasien Baru"** (navigasi ke Register)
     * **"Lanjut Lihat Jadwal"** (menutup dialog dan tetap di halaman jadwal)
2. [README_GUEST_MODE.md](file:///d:/pku-gamping-mobile/README_GUEST_MODE.md)
   * **Deskripsi**: File dokumentasi lengkap berisi diagram alur (flowchart), daftar file yang diubah, dan mekanisme proteksi hak akses.

---

### 2. File yang Dimodifikasi

1. [session_manager.dart](file:///d:/pku-gamping-mobile/lib/core/session/session_manager.dart)
   * Menambahkan key penyimpanan `pku_is_guest`.
   * Menambahkan getter `SessionManager.isGuest` untuk memeriksa apakah sesi aktif saat ini adalah tamu.
   * Menambahkan method `SessionManager.setGuestMode(bool)`.
   * Mengintegrasikan auto-reset flag tamu saat user berhasil login (`saveSession`) atau saat logout (`clearSession`).

2. [app_router.dart](file:///d:/pku-gamping-mobile/lib/core/routes/app_router.dart)
   * Mendaftarkan rute terpusat baru `AppRoutes.jadwal = '/jadwal'`.
   * Menambahkan handling rute `AppRoutes.jadwal` dengan passing argumen `isGuestMode`.
   * Menambahkan **Route Guard** pada `AppRoutes.pendaftaran`: jika rute ini diakses secara paksa/ilegal saat status `SessionManager.isGuest == true`, aplikasi otomatis mengalihkannya ke halaman login dengan pesan edukatif.

3. [login_screen.dart](file:///d:/pku-gamping-mobile/lib/screens/login_screen.dart)
   * Menambahkan pemisah visual divider *"atau"*.
   * Menambahkan tombol sekunder elegan bertuliskan **"Lihat Jadwal Dokter (Mode Tamu)"** dengan border biru khas PKU Gamping di bawah tombol Masuk.
   * Mengatur event tombol agar mengaktifkan `SessionManager.setGuestMode(true)` lalu langsung membuka layar jadwal.

4. [hospital_brand_header.dart](file:///d:/pku-gamping-mobile/lib/widgets/hospital_brand_header.dart)
   * Menambahkan parameter fleksibel `leadingWidget` dan `trailingWidget`.
   * Mengizinkan tampilan tombol **Back** di sisi kiri dan tombol cepat **"Masuk"** di sisi kanan khusus saat Mode Tamu aktif.

5. [jadwal_screen.dart](file:///d:/pku-gamping-mobile/lib/screens/jadwal_screen.dart)
   * Menambahkan parameter `isGuestMode` (dan fallback deteksi otomatis via `SessionManager.isGuest`).
   * Menampilkan **Banner Mode Tamu** di bawah header (*"Mode Tamu: Anda dapat melihat jadwal & poli. Masuk untuk mendaftar antrean"*).
   * Menyembunyikan bottom navigation 5 tab reguler (Beranda, Antrean, (+) Daftar, Jadwal, Profil) agar tamu tidak bingung dengan tab yang terkunci.
   * Menambahkan **Sticky Bottom Action Bar** berisi tombol: *"Masuk untuk Mendaftar Antrean"*.

6. [jadwal_dokter_list.dart](file:///d:/pku-gamping-mobile/lib/screens/jadwal_widgets/jadwal_dokter_list.dart)
   * Memproteksi event klik (`onTap`) pada setiap kartu dokter (`JadwalDokterCard`).
   * Jika user berstatus tamu, aplikasi tidak membuka form pendaftaran, melainkan memunculkan `GuestLoginPromptDialog` lengkap dengan nama dokter dan poli yang diklik.