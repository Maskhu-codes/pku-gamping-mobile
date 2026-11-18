import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/models/dokter_jadwal_model.dart';
import 'package:pku_gamping_app/models/pendaftaran_model.dart';
import 'package:pku_gamping_app/screens/jadwal_screen.dart';
import 'package:pku_gamping_app/services/pendaftaran_service.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';

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

  setUpAll(() {
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  group('JadwalSlotModel.fromJson tests', () {
    test('parses closed slot correctly (is_closed: true, can_book: false)', () {
      final json = {
        'FS_KD_DOKTER': 'S379',
        'FN_NO_URUT': '3',
        'FS_JAM_MULAI': '13:00',
        'FS_JAM_SELESAI': '14:00',
        'FS_KD_LAYANAN': 'P003',
        'FN_HARI': '7',
        'FN_MAX': '100',
        'fd_tgl': '2026-11-14',
        'fs_nm_hari': 'Sabtu',
        'is_closed': true,
        'is_full': false,
        'can_book': false,
        'terdaftar': 2,
      };

      final slot = JadwalSlotModel.fromJson(json);
      expect(slot.tanggal, '2026-11-14');
      expect(slot.namaHari, 'Sabtu');
      expect(slot.hariTanggal, 'Sabtu, 14 November 2026');
      expect(slot.jam, '13:00 - 14:00 WIB');
      expect(slot.totalKuota, 100);
      expect(slot.terdaftar, 2);
      expect(slot.sisaKuota, 98);
      expect(slot.isClosed, isTrue);
      expect(slot.isPenuh, isFalse);
      expect(slot.canBook, isFalse);
      expect(slot.kuotaLabel, 'Poli Tutup');
      expect(slot.statusLabel, 'Poli Tutup');
    });

    test('parses available slot correctly (is_closed: false, can_book: true)', () {
      final json = {
        'FS_KD_DOKTER': 'S379',
        'FN_NO_URUT': '1',
        'FS_JAM_MULAI': '16:00',
        'FS_JAM_SELESAI': '18:00',
        'FS_KD_LAYANAN': 'P003',
        'FN_HARI': '2',
        'FN_MAX': '50',
        'fd_tgl': '2026-11-16',
        'fs_nm_hari': 'Senin',
        'is_closed': false,
        'is_full': false,
        'can_book': true,
        'terdaftar': 5,
      };

      final slot = JadwalSlotModel.fromJson(json);
      expect(slot.tanggal, '2026-11-16');
      expect(slot.namaHari, 'Senin');
      expect(slot.hariTanggal, 'Senin, 16 November 2026');
      expect(slot.jam, '16:00 - 18:00 WIB');
      expect(slot.totalKuota, 50);
      expect(slot.terdaftar, 5);
      expect(slot.sisaKuota, 45);
      expect(slot.isClosed, isFalse);
      expect(slot.isPenuh, isFalse);
      expect(slot.canBook, isTrue);
      expect(slot.kuotaLabel, 'Sisa 45/50');
      expect(slot.statusLabel, 'Tersedia');
    });

    test('parses full slot correctly (is_full: true, can_book: false)', () {
      final json = {
        'FS_KD_DOKTER': 'S379',
        'FN_MAX': '30',
        'fd_tgl': '2026-11-18',
        'fs_nm_hari': 'Rabu',
        'is_closed': false,
        'is_full': true,
        'can_book': false,
        'terdaftar': 30,
      };

      final slot = JadwalSlotModel.fromJson(json);
      expect(slot.isClosed, isFalse);
      expect(slot.isPenuh, isTrue);
      expect(slot.canBook, isFalse);
      expect(slot.kuotaLabel, 'Penuh');
      expect(slot.statusLabel, 'Penuh');
    });
  });

  group('PROMPT 15 - SimrsService.getJadwalDokter() Real API tests', () {
    test('returns empty list if params are missing or empty', () async {
      final empty1 = await SimrsService.getJadwalDokter();
      expect(empty1, isEmpty);

      final empty2 = await SimrsService.getJadwalDokter(
        fsKdLayanan: 'P003',
        fsKdPetugasMedis: '',
      );
      expect(empty2, isEmpty);
    });

    test('fetches real 45-day schedule for Poli Anak (P003) & dr. Gina Puspita (S379)', () async {
      final listJadwal = await SimrsService.getJadwalDokter(
        fsKdLayanan: 'P003',
        fsKdPetugasMedis: 'S379',
      );

      expect(listJadwal, isNotEmpty);
      // The doctor practices multiple days per week across 45 days
      expect(listJadwal.length, greaterThanOrEqualTo(10));

      final first = listJadwal.first;
      expect(first.tanggal, isNotEmpty);
      expect(first.namaHari, isNotEmpty);
      expect(first.hariTanggal, isNotEmpty);
      expect(first.jam, isNotEmpty);
      expect(first.totalKuota, greaterThan(0));

      // Verifikasi parsing status can_book, is_full, is_closed
      for (final slot in listJadwal) {
        expect(slot.statusLabel, isIn(['Tersedia', 'Penuh', 'Poli Tutup']));
        if (slot.isClosed || slot.isPenuh) {
          expect(slot.canBook, isFalse);
        } else {
          expect(slot.canBook, isTrue);
        }
      }
    }, tags: ['live_db']);

    test('PendaftaranService.getJadwalDokter forwards to SimrsService and returns valid slots', () async {
      final listJadwal = await PendaftaranService.getJadwalDokter(
        poliId: 'P003',
        dokterId: 'S379',
      );

      expect(listJadwal, isNotEmpty);
      expect(listJadwal.first.kdLayanan, 'P003');
      expect(listJadwal.first.kdDokter, 'S379');
    }, tags: ['live_db']);
  });

  group('JadwalScreen SIMRS Integration Widget Tests', () {
    late HttpClientAdapter originalAdapter;

    setUp(() {
      originalAdapter = ApiClient.dio.httpClientAdapter;
    });

    tearDown(() {
      ApiClient.dio.httpClientAdapter = originalAdapter;
    });

    testWidgets(
      'Memuat poli & jadwal dari API SIMRS, memetakan status, dan meneruskan kode SIMRS ke PendaftaranScreen',
      (tester) async {
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final tomorrowStr = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().add(const Duration(days: 1)));

        ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
          if (options.path.contains('/layanan/list')) {
            return ResponseBody.fromString(
              jsonEncode({
                'status': true,
                'data': [
                  {'fs_kd_layanan': 'P003', 'fs_nm_layanan': 'ANAK'},
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
                    'fs_kd_peg': 'S379',
                    'fs_nm_peg': 'dr. Gina Puspita, Sp.A',
                    'fs_kd_layanan': 'P003',
                    'fs_nm_layanan': 'ANAK',
                  },
                  {
                    'fs_kd_peg': 'S380',
                    'fs_nm_peg': 'dr. Penuh Test, Sp.A',
                    'fs_kd_layanan': 'P003',
                    'fs_nm_layanan': 'ANAK',
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
            final kdMedis = options.queryParameters['fs_kd_petugas_medis'];
            if (kdMedis == 'S379') {
              return ResponseBody.fromString(
                jsonEncode({
                  'status': true,
                  'data': [
                    {
                      'FS_KD_DOKTER': 'S379',
                      'FS_KD_LAYANAN': 'P003',
                      'FS_JAM_MULAI': '08:00',
                      'FS_JAM_SELESAI': '11:00',
                      'FN_MAX': '30',
                      'fd_tgl': todayStr,
                      'is_closed': false,
                      'is_full': false,
                      'can_book': true,
                      'terdaftar': 5,
                    },
                    {
                      'FS_KD_DOKTER': 'S379',
                      'FS_KD_LAYANAN': 'P003',
                      'FS_JAM_MULAI': '16:00',
                      'FS_JAM_SELESAI': '18:00',
                      'FN_MAX': '30',
                      'fd_tgl': tomorrowStr,
                      'is_closed': true,
                      'is_full': false,
                      'can_book': false,
                      'terdaftar': 0,
                    },
                  ],
                }),
                200,
                headers: {
                  Headers.contentTypeHeader: [Headers.jsonContentType],
                },
              );
            }
            return ResponseBody.fromString(
              jsonEncode({
                'status': true,
                'data': [
                  {
                    'FS_KD_DOKTER': 'S380',
                    'FS_KD_LAYANAN': 'P003',
                    'FS_JAM_MULAI': '13:00',
                    'FS_JAM_SELESAI': '15:00',
                    'FN_MAX': '20',
                    'fd_tgl': todayStr,
                    'is_closed': false,
                    'is_full': true,
                    'can_book': false,
                    'terdaftar': 20,
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

        DokterJadwal? navigatedDokter;
        await tester.pumpWidget(
          MaterialApp(
            home: const JadwalScreen(embedded: true),
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.pendaftaran) {
                final args = settings.arguments as Map<String, dynamic>?;
                navigatedDokter = args?['initialDokter'] as DokterJadwal?;
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Pendaftaran Target')),
                );
              }
              return null;
            },
          ),
        );
        await tester.pumpAndSettle();

        // Tidak ada dokter dummy statis
        expect(find.text('dr. H. Ahmad Farhan, Sp.PD'), findsNothing);
        // Dokter real dari API tampil dengan status yang benar
        expect(find.text('dr. Gina Puspita, Sp.A'), findsOneWidget);
        expect(find.text('dr. Penuh Test, Sp.A'), findsOneWidget);
        expect(find.text('Tersedia'), findsOneWidget);
        expect(find.text('Penuh'), findsOneWidget);

        // Tap kartu dokter -> meneruskan fsKdLayanan & fsKdPetugasMedis asli SIMRS
        await tester.tap(find.text('dr. Gina Puspita, Sp.A'));
        await tester.pumpAndSettle();

        expect(navigatedDokter, isNotNull);
        expect(navigatedDokter!.fsKdLayanan, 'P003');
        expect(navigatedDokter!.fsKdPetugasMedis, 'S379');
      },
    );

    testWidgets('Menampilkan error state dan tombol Coba Lagi saat gagal memuat API', (tester) async {
      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((_) {
        return ResponseBody.fromString(
          jsonEncode({'status': false, 'message': 'Server SIMRS bermasalah'}),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: JadwalScreen(embedded: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gagal Memuat Jadwal'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });
  });
}

