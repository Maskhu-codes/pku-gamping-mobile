@Tags(['live_db'])
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/screens/register_screen.dart';

class _RealHttpOverrides extends HttpOverrides {}

Widget createRegisterApp() {
  return const MaterialApp(
    home: RegisterScreen(),
  );
}

DropdownButton<String> getDropdown(WidgetTester tester, Finder parentFinder) {
  return tester.widget<DropdownButton<String>>(
    find.descendant(
      of: parentFinder,
      matching: find.byType(DropdownButton<String>),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  setUp(() {
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  testWidgets(
    'PROMPT 11: Cascading Dropdown Wilayah (Provinsi -> Kabupaten -> Kecamatan -> Kelurahan) terhubung ke SIMRS & Step 3 Navigasi',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(createRegisterApp());
        // Tunggu load master data awal (master agama, pekerjaan, provinsi, dll)
        await Future.delayed(const Duration(milliseconds: 800));
      });
      await tester.pumpAndSettle();

      // 1. Step 1: Input NIK & Cek NIK
      final nikField = find.byType(TextFormField).first;
      expect(nikField, findsOneWidget);
      await tester.enterText(nikField, '0402161711150001');
      await tester.pumpAndSettle();

      final cekNikBtn = find.text('Cek NIK');
      expect(cekNikBtn, findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(cekNikBtn);
        await Future.delayed(const Duration(milliseconds: 1000));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Valid'), findsOneWidget);

      // Lanjut ke Step 2
      final lanjutBtn = find.text('Lanjutkan →');
      expect(lanjutBtn, findsOneWidget);

      ScaffoldMessenger.of(tester.element(lanjutBtn)).hideCurrentSnackBar();
      await tester.pumpAndSettle();

      await tester.tap(lanjutBtn);
      await tester.pumpAndSettle();

      // 2. Step 2: Pastikan nama ter-prefill dari SIMRS
      expect(find.text('NAJIB IBADURROHMAN'), findsOneWidget);

      // 3. Scroll ke bagian Alamat Domisili
      final provLabelFinder = find.text('Provinsi *');
      expect(provLabelFinder, findsOneWidget);
      await tester.ensureVisible(provLabelFinder);
      await tester.pumpAndSettle();

      // 4. Cari dropdown Provinsi
      final provDropdownFinder = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<String> && widget.key.toString().contains('FS_KD_PROPINSI'),
      );
      expect(provDropdownFinder, findsOneWidget);

      final provDropdown = getDropdown(tester, provDropdownFinder);
      expect(provDropdown.items!.isNotEmpty, isTrue);
      // Memastikan Jawa Tengah ('33') dan DIY ('34') ada dalam daftar provinsi dari SIMRS
      expect(provDropdown.items!.any((item) => item.value == '33'), isTrue);
      expect(provDropdown.items!.any((item) => item.value == '34'), isTrue);

      // Pilih Provinsi JAWA TENGAH ('33')
      await tester.runAsync(() async {
        provDropdown.onChanged!('33');
        await Future.delayed(const Duration(milliseconds: 1000));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 5. Dropdown Kabupaten harus sudah terisi kabupaten di Jawa Tengah
      final kabDropdownFinder = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<String> && widget.key.toString().contains('FS_KD_KABUPATEN'),
      );
      expect(kabDropdownFinder, findsOneWidget);

      final kabDropdown = getDropdown(tester, kabDropdownFinder);
      expect(kabDropdown.items!.isNotEmpty, isTrue);
      // BANJARNEGARA ('3304') ada di Jawa Tengah
      expect(kabDropdown.items!.any((item) => item.value == '3304'), isTrue);

      // Pilih Kabupaten BANJARNEGARA ('3304')
      await tester.runAsync(() async {
        kabDropdown.onChanged!('3304');
        await Future.delayed(const Duration(milliseconds: 1000));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 6. Dropdown Kecamatan harus sudah terisi kecamatan di Banjarnegara
      final kecDropdownFinder = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<String> && widget.key.toString().contains('FS_KD_KECAMATAN'),
      );
      expect(kecDropdownFinder, findsOneWidget);

      final kecDropdown = getDropdown(tester, kecDropdownFinder);
      expect(kecDropdown.items!.isNotEmpty, isTrue);
      // BAYAT ('3304001') ada di Banjarnegara
      expect(kecDropdown.items!.any((item) => item.value == '3304001'), isTrue);

      // Pilih Kecamatan BAYAT ('3304001')
      await tester.runAsync(() async {
        kecDropdown.onChanged!('3304001');
        await Future.delayed(const Duration(milliseconds: 1000));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 7. Dropdown Kelurahan harus sudah terisi kelurahan di Bayat
      final kelDropdownFinder = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<String> && widget.key.toString().contains('FS_KD_KELURAHAN'),
      );
      expect(kelDropdownFinder, findsOneWidget);

      final kelDropdown = getDropdown(tester, kelDropdownFinder);
      expect(kelDropdown.items!.isNotEmpty, isTrue);
      // BANYURIPAN ('3304001001') ada di Bayat
      expect(kelDropdown.items!.any((item) => item.value == '3304001001'), isTrue);

      // Pilih Kelurahan BANYURIPAN ('3304001001')
      await tester.runAsync(() async {
        kelDropdown.onChanged!('3304001001');
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 8. Uji reset cascading: Ganti Provinsi ke D.I. YOGYAKARTA ('34')
      final provDropdownFinder2 = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<String> && widget.key.toString().contains('FS_KD_PROPINSI'),
      );
      final provDropdown2 = getDropdown(tester, provDropdownFinder2);

      await tester.runAsync(() async {
        provDropdown2.onChanged!('34'); // D.I. Yogyakarta
        await Future.delayed(const Duration(milliseconds: 1000));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi kabupaten baru termuat untuk DIY (misal Sleman '3404')
      final kabDropdownFinder2 = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<String> && widget.key.toString().contains('FS_KD_KABUPATEN'),
      );
      final kabDropdown2 = getDropdown(tester, kabDropdownFinder2);
      expect(kabDropdown2.items!.any((item) => item.value == '3404'), isTrue);

      // Verifikasi kecamatan dan kelurahan direset (anak direset saat induk berganti)
      final kecDropdownFinder2 = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<String> && widget.key.toString().contains('FS_KD_KECAMATAN'),
      );
      final kecDropdown2 = getDropdown(tester, kecDropdownFinder2);
      expect(kecDropdown2.items!.isEmpty, isTrue);

      // 9. Pilih Tempat Lahir (scroll up ke tempat lahir jika belum terisi)
      final tempatLahirFinder = find.text('Pilih Tempat Lahir');
      if (tempatLahirFinder.evaluate().isNotEmpty) {
        await tester.ensureVisible(tempatLahirFinder);
        await tester.pumpAndSettle();
        await tester.tap(tempatLahirFinder);
        await tester.pumpAndSettle();

        final firstCity = find.byType(ListTile).first;
        await tester.tap(firstCity);
        await tester.pumpAndSettle();
      }

      // 10. Navigasi ke Step 3 (Lanjut Langkah 3 →)
      final step2NextBtn = find.text('Lanjut Langkah 3 →');
      expect(step2NextBtn, findsOneWidget);
      await tester.ensureVisible(step2NextBtn);
      await tester.pumpAndSettle();

      await tester.tap(step2NextBtn);
      await tester.pumpAndSettle();

      // 11. Verifikasi Step 3 (Akun & Sandi) ditampilkan
      expect(find.text('Akun & Sandi'), findsOneWidget);
      expect(find.text('Alamat Email *'), findsOneWidget);
      expect(find.text('Kata Sandi *'), findsOneWidget);
      expect(find.text('Konfirmasi Kata Sandi *'), findsOneWidget);
    },
  );
}
