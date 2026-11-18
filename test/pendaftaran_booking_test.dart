import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/models/pendaftaran_model.dart';
import 'package:pku_gamping_app/screens/jadwal_widgets/jadwal_constants.dart'
    show DokterJadwal, StatusDokter;
import 'package:pku_gamping_app/screens/pendaftaran_screen.dart';
import 'package:pku_gamping_app/screens/pendaftaran_widgets/pendaftaran_pasien_card.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/services/pendaftaran_service.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RealHttpOverrides extends HttpOverrides {}

typedef _MockHandler = ResponseBody Function(RequestOptions options);

class _MockHttpClientAdapter implements HttpClientAdapter {
  _MockHttpClientAdapter(this.handler);

  final _MockHandler handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  late HttpClientAdapter originalAdapter;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();
    AntreanService.kosongkanAntrean();
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
    originalAdapter = ApiClient.dio.httpClientAdapter;
  });

  tearDown(() {
    ApiClient.dio.httpClientAdapter = originalAdapter;
    AntreanService.kosongkanAntrean();
  });

  group('PROMPT 16 - Model & SessionManager Booking Tests', () {
    test('JadwalSlotModel menyimpan fnHari, kdSesionPoli, jamMulai dari JSON jadwal', () {
      final slot = JadwalSlotModel.fromJson({
        'FS_KD_DOKTER': 'S379',
        'FN_NO_URUT': '1',
        'FS_JAM_MULAI': '16:00',
        'FS_JAM_SELESAI': '18:00',
        'FS_KD_LAYANAN': 'P003',
        'FS_KD_SESION_POLI': '2',
        'FN_HARI': '4',
        'FN_MAX': '50',
        'fd_tgl': '2026-11-18',
        'fs_nm_hari': 'Rabu',
        'is_closed': false,
        'is_full': false,
        'can_book': true,
        'terdaftar': 5,
      });

      expect(slot.fnHari, '4');
      expect(slot.kdSesionPoli, '2');
      expect(slot.jamMulai, '16:00');
      expect(slot.tanggal, '2026-11-18');
      expect(slot.shift, 'Praktik Sore');
    });

    test('SessionManager menyimpan & menghapus fs_kd_antrian dan fd_tgl_lahir', () async {
      await SessionManager.setTglLahir('1990-05-24');
      await SessionManager.setActiveBooking(
        fsKdAntrian: 'AN0001234A',
        noBooking: 'BO0001234A',
        noUrut: '12',
      );

      expect(SessionManager.fdTglLahir, '1990-05-24');
      expect(SessionManager.fsKdAntrian, 'AN0001234A');
      expect(SessionManager.noBooking, 'BO0001234A');
      expect(SessionManager.noUrutAntrean, '12');

      await SessionManager.clearSession();
      expect(SessionManager.fdTglLahir, isNull);
      expect(SessionManager.fsKdAntrian, isNull);
      expect(SessionManager.noBooking, isNull);
      expect(SessionManager.noUrutAntrean, isNull);
    });
  });

  group('PROMPT 16 - PendaftaranService.simpanBooking Contract Tests', () {
    test('Mengirim payload sesuai kontrak backend dan menyimpan fs_kd_antrian', () async {
      Map<String, dynamic>? capturedBody;
      String? capturedPath;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        capturedPath = options.path;
        capturedBody = Map<String, dynamic>.from(options.data as Map);
        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'message': 'Booking berhasil',
            'data': {
              'no_booking': 'BO2026111801',
              'no_antrian': 'AN2026111801',
              'no_urut': 9,
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await PendaftaranService.simpanBooking(
        fsMr: '347104100407039',
        fdTglLahir: '1998-10-27',
        fsKdLayanan: 'P003',
        fsKdPetugasMedis: 'S379',
        fnHari: '4',
        fdTglAntrian: '2026-11-18',
        fsKdSesionPoli: '1',
        fsJamMulai: '16:00',
      );

      expect(capturedPath, '/booking/simpan');
      expect(capturedBody, {
        'fs_mr': '347104100407039',
        'fd_tgl_lahir': '1998-10-27',
        'fs_kd_layanan': 'P003',
        'fs_kd_petugas_medis': 'S379',
        'fn_hari': '4',
        'fd_tgl_antrian': '2026-11-18',
        'fs_kd_sesion_poli': '1',
        'fs_jam_mulai': '16:00',
      });

      expect(result['fn_no_urut'], '9');
      expect(result['fs_kd_antrian'], 'AN2026111801');
      expect(result['no_booking'], 'BO2026111801');
      expect(SessionManager.fsKdAntrian, 'AN2026111801');
      expect(SessionManager.noBooking, 'BO2026111801');
    });

    test('Melempar Exception jika backend mengembalikan status false', () async {
      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((_) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': false,
            'message': 'Maksimal Pendaftaran 3 kali sehari',
          }),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      expect(
        () => PendaftaranService.simpanBooking(
          fsMr: '347104100407039',
          fdTglLahir: '1998-10-27',
          fsKdLayanan: 'P003',
          fsKdPetugasMedis: 'S379',
          fnHari: '4',
          fdTglAntrian: '2026-11-18',
          fsKdSesionPoli: '1',
          fsJamMulai: '16:00',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PROMPT 16 - Integrasi Backend SIMRS Real (Read + Endpoint Check)', () {
    test(
      'Login, fetch /auth/me (fd_tgl_lahir), jadwal dokter, dan cek endpoint POST /booking/simpan',
      tags: ['live_db'],
      () async {
      await SimrsService.login(
        email: 'dummy_pasien@gmail.com',
        password: 'admin123',
      );
      expect(SessionManager.hasValidSession(), isTrue);
      expect(SessionManager.fsMr, isNotEmpty);

      final me = await SimrsService.getMeProfile();
      expect(me, isNotEmpty);
      expect(SessionManager.fdTglLahir, isNotNull);
      expect(SessionManager.fdTglLahir, isNotEmpty);

      final jadwalList = await PendaftaranService.getJadwalDokter(
        poliId: 'P003',
        dokterId: 'S379',
      );
      expect(jadwalList, isNotEmpty);

      final sampleSlot = jadwalList.first;
      expect(sampleSlot.tanggal, isNotEmpty);
      expect(sampleSlot.fnHari, isNotEmpty);
      expect(sampleSlot.jamMulai, isNotEmpty);

      // Uji endpoint /booking/simpan aktif di backend tanpa mencemari antrean live SIMRS
      // (mengirim fs_mr tidak terdaftar agar ditolak validasi TC_MR oleh Booking.php)
      await expectLater(
        PendaftaranService.simpanBooking(
          fsMr: '000000000000000',
          fdTglLahir: SessionManager.fdTglLahir!,
          fsKdLayanan: 'P003',
          fsKdPetugasMedis: 'S379',
          fnHari: sampleSlot.fnHari,
          fdTglAntrian: sampleSlot.tanggal,
          fsKdSesionPoli:
              sampleSlot.kdSesionPoli.isNotEmpty ? sampleSlot.kdSesionPoli : '1',
          fsJamMulai: sampleSlot.jamMulai,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PROMPT 16 - Widget PendaftaranScreen Booking Flow', () {
    testWidgets('Submit booking menampilkan fn_no_urut dari API dan bukan A-014', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-test-token',
        fsMr: '347104100407039',
        fsNmPasien: 'PASIEN TEST BOOKING',
        fsNik: '3404052710980002',
        fsEmail: 'dummy_pasien@gmail.com',
      );
      await SessionManager.setTglLahir('1998-10-27');

      Map<String, dynamic>? submittedBody;
      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/layanan/list')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': [
                {'fs_kd_layanan': 'P001', 'fs_nm_layanan': 'DALAM'},
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (options.path.contains('/dokter/list')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': [
                {
                  'fs_kd_peg': 'S028',
                  'fs_nm_peg': 'dr. Hendra Wicaksono, Sp.PD',
                  'fs_kd_layanan': 'P001',
                  'fs_nm_layanan': 'DALAM',
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (options.path.contains('/jadwal/list')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': [
                {
                  'FS_KD_DOKTER': 'S028',
                  'FN_NO_URUT': '1',
                  'FS_JAM_MULAI': '07:30',
                  'FS_JAM_SELESAI': '10:30',
                  'FS_KD_LAYANAN': 'P001',
                  'FS_KD_SESION_POLI': '1',
                  'FN_HARI': '4',
                  'FN_MAX': '30',
                  'fd_tgl': '2026-11-18',
                  'fs_nm_hari': 'Rabu',
                  'is_closed': false,
                  'is_full': false,
                  'can_book': true,
                  'terdaftar': 5,
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (options.path.contains('/booking/simpan')) {
          submittedBody = Map<String, dynamic>.from(options.data as Map);
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'message': 'Booking berhasil',
              'data': {
                'no_booking': 'BO998877',
                'no_antrian': 'AN998877',
                'no_urut': 27,
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: PendaftaranScreen(
            initialDokter: DokterJadwal(
              nama: 'dr. Hendra Wicaksono, Sp.PD',
              poli: 'Poli Penyakit Dalam',
              jamMulai: '07.30',
              jamSelesai: '10.30',
              status: StatusDokter.tersedia,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll ke tombol Konfirmasi Pendaftaran & tekan
      final confirmFinder = find.text('Konfirmasi Pendaftaran');
      await tester.ensureVisible(confirmFinder);
      await tester.tap(confirmFinder);
      await tester.pumpAndSettle();

      // Tekan Lanjutkan pada dialog konfirmasi
      final lanjutFinder = find.text('Lanjutkan');
      expect(lanjutFinder, findsOneWidget);
      await tester.tap(lanjutFinder);
      await tester.pumpAndSettle();

      // Pastikan dialog sukses tampil dengan nomor antrean 27 dan TIDAK ada 'A-014'
      expect(find.text('Pendaftaran Berhasil!'), findsOneWidget);
      expect(find.text('27'), findsWidgets);
      expect(find.text('A-014'), findsNothing);
      expect(submittedBody?['fs_mr'], '347104100407039');
      expect(submittedBody?['fd_tgl_lahir'], '1998-10-27');
      expect(submittedBody?['fs_kd_layanan'], 'P001');
      expect(submittedBody?['fs_kd_petugas_medis'], 'S028');
      expect(submittedBody?['fn_hari'], '4');
      expect(submittedBody?['fd_tgl_antrian'], '2026-11-18');
      expect(submittedBody?['fs_jam_mulai'], '07:30');
      expect(AntreanService.antreanAktif.value?.nomorAntrean, '27');
      expect(SessionManager.fsKdAntrian, 'AN998877');
    });

    testWidgets('initialDokter dengan kode SIMRS langsung memuat /jadwal/list tanpa dummy data', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-test-token',
        fsMr: '347104100407039',
        fsNmPasien: 'PASIEN TEST KODE',
      );
      await SessionManager.setTglLahir('2000-03-18');

      var layananCalled = false;
      var dokterCalled = false;
      Map<String, dynamic>? submittedBody;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/layanan/list')) {
          layananCalled = true;
        }
        if (options.path.contains('/dokter/list')) {
          dokterCalled = true;
        }
        if (options.path.contains('/jadwal/list')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': [
                {
                  'FS_KD_DOKTER': 'S434',
                  'FN_NO_URUT': '1',
                  'FS_JAM_MULAI': '15:30',
                  'FS_JAM_SELESAI': '17:30',
                  'FS_KD_LAYANAN': 'P047',
                  'FS_KD_SESION_POLI': '2',
                  'FN_HARI': '3',
                  'FN_MAX': '20',
                  'fd_tgl': '2026-11-24',
                  'fs_nm_hari': 'Selasa',
                  'is_closed': false,
                  'is_full': false,
                  'can_book': true,
                  'terdaftar': 5,
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (options.path.contains('/booking/simpan')) {
          submittedBody = Map<String, dynamic>.from(options.data as Map);
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'message': 'Booking berhasil',
              'data': {
                'no_booking': 'BO1629860A',
                'no_antrian': 'AN1908583A',
                'no_urut': 6,
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: PendaftaranScreen(
            initialDokter: DokterJadwal(
              nama: 'Prof. Dr, dr. Dicky Moch Rizal.,M.Kes.,S',
              poli: 'ANDROLOGI',
              jamMulai: '15.30',
              jamSelesai: '17.30',
              status: StatusDokter.tersedia,
              fsKdLayanan: 'P047',
              fsKdPetugasMedis: 'S434',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(layananCalled, isFalse);
      expect(dokterCalled, isFalse);

      final confirmFinder = find.text('Konfirmasi Pendaftaran');
      await tester.ensureVisible(confirmFinder);
      await tester.tap(confirmFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      expect(submittedBody?['fs_kd_layanan'], 'P047');
      expect(submittedBody?['fs_kd_petugas_medis'], 'S434');
      expect(submittedBody?['fn_hari'], '3');
      expect(submittedBody?['fd_tgl_antrian'], '2026-11-24');
      expect(submittedBody?['fs_jam_mulai'], '15:30');

      // Pastikan AntreanService.buatAntrean menyimpan metadata SIMRS lengkap
      final active = AntreanService.antreanAktif.value;
      expect(active, isNotNull);
      expect(active!.fsKdLayanan, 'P047');
      expect(active.fsKdPetugasMedis, 'S434');
      expect(active.fsKdAntrian, 'AN1908583A');
      expect(active.noBooking, 'BO1629860A');
      expect(active.rawTanggal, '2026-11-24');
    });

    testWidgets('Kartu pasien memuat tanggal lahir & NIK dari sesi/auth-me tanpa data hardcoded', (tester) async {
      await SessionManager.clearSession();
      await SessionManager.saveSession(
        token: 'jwt-test-token',
        fsMr: '347104100407951',
        fsNmPasien: 'BY DUMMY ONLINE DUA',
      );
      // Sengaja belum set fdTglLahir & nik di sesi agar memicu auto-fetch /auth/me

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/auth/me')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'FS_MR': '347104100407951',
                'FS_NM_PASIEN': 'BY DUMMY ONLINE DUA',
                'FD_TGL_LAHIR': '2000-03-18',
                'FS_KD_IDENTITAS': '',
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: PendaftaranScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tidak boleh menampilkan tanggal lahir / NIK dummy hardcoded
      expect(find.text('24 Mei 1990'), findsNothing);
      expect(find.text('3471041234560001'), findsNothing);
      // Tanggal lahir dari /auth/me terformat Indonesia dan fallback NIK ramah
      expect(SessionManager.fdTglLahir, '2000-03-18');
      final pasienCard = tester.widget<PendaftaranPasienCard>(
        find.byType(PendaftaranPasienCard),
      );
      expect(pasienCard.pasien.tanggalLahir, '18 Maret 2000');
      expect(pasienCard.pasien.nik, '-');
    });

    testWidgets('Tidak fallback ke PendaftaranDummyData bila dokter tidak ditemukan di SIMRS', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-test-token',
        fsMr: '347104100407039',
        fsNmPasien: 'PASIEN TEST FALLBACK',
      );
      await SessionManager.setTglLahir('2000-03-18');

      var bookingCalled = false;
      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/layanan/list')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': [
                {'fs_kd_layanan': 'P001', 'fs_nm_layanan': 'DALAM'},
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (options.path.contains('/dokter/list')) {
          return ResponseBody.fromString(
            jsonEncode({'status': true, 'data': []}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (options.path.contains('/booking/simpan')) {
          bookingCalled = true;
        }
        return ResponseBody.fromString('{}', 404);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: PendaftaranScreen(
            initialDokter: DokterJadwal(
              nama: 'dr. H. Ahmad Farhan, Sp.PD',
              poli: 'Poli Penyakit Dalam',
              jamMulai: '09.00',
              jamSelesai: '12.00',
              status: StatusDokter.tersedia,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Poli asli SIMRS terpilih, tetapi dokter dummy tidak boleh terisi otomatis
      expect(find.text('DALAM'), findsWidgets);
      expect(find.text('PILIH DOKTER'), findsOneWidget);
      expect(find.text('dr. H. Ahmad Farhan, Sp.PD'), findsNothing);
      expect(bookingCalled, isFalse);
    });

    testWidgets(
      'Date picker menampilkan shortcut tanggal terdekat, membuka kalender, dan memberi info saat tanggal tutup/penuh ditap',
      (tester) async {
        await SessionManager.clearSession();
        await SessionManager.saveSession(
          token: 'jwt-test-token',
          fsMr: '347104100407951',
          fsNmPasien: 'PASIEN DATE PICKER',
          fsNik: '3404052710980003',
        );
        await SessionManager.setTglLahir('2000-03-18');

        ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
          if (options.path.contains('/jadwal/list')) {
            return ResponseBody.fromString(
              jsonEncode({
                'status': true,
                'data': [
                  {
                    'FS_KD_DOKTER': 'S434',
                    'FN_NO_URUT': '1',
                    'FS_JAM_MULAI': '09:00',
                    'FS_JAM_SELESAI': '11:00',
                    'FS_KD_LAYANAN': 'P047',
                    'FS_KD_SESION_POLI': '1',
                    'FN_HARI': '5',
                    'FN_MAX': '20',
                    'fd_tgl': '2026-11-19',
                    'fs_nm_hari': 'Kamis',
                    'is_closed': false,
                    'is_full': false,
                    'can_book': true,
                    'terdaftar': 4,
                  },
                  {
                    'FS_KD_DOKTER': 'S434',
                    'FN_NO_URUT': '1',
                    'FS_JAM_MULAI': '09:00',
                    'FS_JAM_SELESAI': '11:00',
                    'FS_KD_LAYANAN': 'P047',
                    'FS_KD_SESION_POLI': '1',
                    'FN_HARI': '6',
                    'FN_MAX': '20',
                    'fd_tgl': '2026-11-20',
                    'fs_nm_hari': 'Jumat',
                    'is_closed': true,
                    'is_full': false,
                    'can_book': false,
                    'terdaftar': 0,
                  },
                  {
                    'FS_KD_DOKTER': 'S434',
                    'FN_NO_URUT': '1',
                    'FS_JAM_MULAI': '15:30',
                    'FS_JAM_SELESAI': '17:30',
                    'FS_KD_LAYANAN': 'P047',
                    'FS_KD_SESION_POLI': '2',
                    'FN_HARI': '3',
                    'FN_MAX': '20',
                    'fd_tgl': '2026-11-24',
                    'fs_nm_hari': 'Selasa',
                    'is_closed': false,
                    'is_full': false,
                    'can_book': true,
                    'terdaftar': 2,
                  },
                ],
              }),
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }
          return ResponseBody.fromString('{}', 404);
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: PendaftaranScreen(
              initialDokter: DokterJadwal(
                nama: 'Prof. Dr, dr. Dicky Moch Rizal',
                poli: 'ANDROLOGI',
                jamMulai: '09:00',
                jamSelesai: '11:00',
                status: StatusDokter.tersedia,
                fsKdLayanan: 'P047',
                fsKdPetugasMedis: 'S434',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Field date picker + shortcut cepat tanggal tersedia tampil
        expect(find.byKey(const Key('pendaftaran_date_picker_field')), findsOneWidget);
        expect(find.byKey(const Key('quick_date_2026-11-19')), findsOneWidget);
        expect(find.byKey(const Key('quick_date_2026-11-24')), findsOneWidget);
        // Tanggal tutup tidak masuk shortcut tersedia
        expect(find.byKey(const Key('quick_date_2026-11-20')), findsNothing);

        // Buka bottom sheet kalender
        final dateField = find.byKey(const Key('pendaftaran_date_picker_field'));
        await tester.ensureVisible(dateField);
        await tester.tap(dateField);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('pendaftaran_date_picker_sheet')), findsOneWidget);

        // Tap tanggal tutup (20 Nov) -> sheet tetap terbuka & muncul tulisan informasi
        await tester.tap(find.byKey(const Key('calendar_day_2026-11-20')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('pendaftaran_date_picker_sheet')), findsOneWidget);
        expect(find.textContaining('Poli tutup pada'), findsOneWidget);

        // Tap tanggal tersedia (24 Nov) -> sheet menutup & tanggal terpilih berubah ke 24 Nov
        await tester.tap(find.byKey(const Key('calendar_day_2026-11-24')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('pendaftaran_date_picker_sheet')), findsNothing);
        expect(find.text('Selasa, 24 November 2026'), findsWidgets);
        expect(find.text('15:30 - 17:30 WIB'), findsWidgets);
      },
    );
  });
}
