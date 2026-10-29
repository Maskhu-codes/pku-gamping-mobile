import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/screens/edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pku_gamping_app/core/session/session_manager.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'pku_nama_pasien': 'Dahlan Muda',
      'pku_no_rm': '01-88-24-90',
      'pku_nik': '3471040506920001',
      'pku_user_password': 'password123',
    });
    await SessionManager.init();
  });

  testWidgets(
      'EditProfileScreen renders sections and supports change password modal with current password validation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: EditProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verifikasi Section-Section Utama
    expect(find.text('Data Pasien'), findsOneWidget);
    expect(find.text('Alamat'), findsOneWidget);
    expect(find.text('Kontak'), findsOneWidget);
    expect(find.text('Keamanan Akun'), findsOneWidget);

    // 2. Verifikasi Tombol Ubah Sandi
    final ubahSandiBtn = find.widgetWithText(OutlinedButton, 'Ubah Sandi');
    expect(ubahSandiBtn, findsOneWidget);

    // 3. Buka Modal Bottom Sheet Ubah Kata Sandi
    await tester.ensureVisible(ubahSandiBtn);
    await tester.tap(ubahSandiBtn);
    await tester.pumpAndSettle();

    // Pastikan modal bottom sheet terbuka
    expect(find.text('Ubah Kata Sandi'), findsOneWidget);
    expect(find.text('Kata Sandi Saat Ini *'), findsOneWidget);
    expect(find.text('Kata Sandi Baru *'), findsOneWidget);
    expect(find.text('Konfirmasi Kata Sandi Baru *'), findsOneWidget);
    expect(find.text('Perbarui Kata Sandi'), findsOneWidget);

    // 4. Coba submit tanpa sandi saat ini -> muncul error
    final perbaruiBtn =
        find.widgetWithText(ElevatedButton, 'Perbarui Kata Sandi');
    await tester.tap(perbaruiBtn);
    await tester.pumpAndSettle();

    expect(find.text('Masukkan kata sandi saat ini.'), findsOneWidget);

    // 5. Coba masukkan sandi saat ini yang salah
    final currentPassField =
        find.widgetWithText(TextFormField, 'Masukkan kata sandi saat ini');
    await tester.enterText(currentPassField, 'wrongpass');
    await tester.tap(perbaruiBtn);
    await tester.pumpAndSettle();

    expect(find.text('Kata sandi saat ini tidak sesuai.'), findsOneWidget);

    // 6. Masukkan sandi saat ini yang benar dan sandi baru valid
    await tester.enterText(currentPassField, 'password123');

    final newPassField =
        find.widgetWithText(TextFormField, 'Minimal 8 karakter');
    await tester.enterText(newPassField, 'newsecret123');

    final confirmPassField =
        find.widgetWithText(TextFormField, 'Ulangi kata sandi baru');
    await tester.enterText(confirmPassField, 'newsecret123');

    // Submit ganti sandi
    await tester.tap(perbaruiBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // 7. Notifikasi berhasil dan modal tertutup
    expect(find.text('Kata sandi berhasil diperbarui'), findsOneWidget);
    expect(find.text('Ubah Kata Sandi'), findsNothing);
  });
}
