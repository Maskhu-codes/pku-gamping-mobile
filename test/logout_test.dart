import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_logout_button.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();
  });

  tearDown(() async {
    await SessionManager.clearSession();
  });

  group('PROMPT 25 — Logout (Clear Local Session)', () {
    test('SimrsService.logout membersihkan seluruh data sesi lokal', () async {
      // 1. Simpan sesi aktif
      await SessionManager.saveSession(
        token: 'active_jwt_token_123',
        namaPasien: 'Dahlan Muda',
        fsMr: '347104100407951',
        fsNik: '347104100407039',
        fsEmail: 'dahlan@pku.id',
        username: 'dahlan',
      );
      await SessionManager.setActiveBooking(
        noBooking: 'BK-001',
        fsKdAntrian: 'AN-001',
        noUrut: '12',
      );

      expect(SessionManager.isLoggedIn, isTrue);
      expect(SessionManager.token, 'active_jwt_token_123');
      expect(SessionManager.fsMr, '347104100407951');
      expect(SessionManager.noBooking, 'BK-001');

      // 2. Panggil logout
      await SimrsService.logout();

      // 3. Verifikasi seluruh sesi terhapus
      expect(SessionManager.isLoggedIn, isFalse);
      expect(SessionManager.hasValidSession(), isFalse);
      expect(SessionManager.token, isNull);
      expect(SessionManager.fsMr, isEmpty);
      expect(SessionManager.fsNik, isNull);
      expect(SessionManager.fsEmail, isNull);
      expect(SessionManager.noBooking, isNull);
      expect(SessionManager.fsKdAntrian, isNull);
      expect(SessionManager.noUrutAntrean, isNull);
      expect(SessionManager.profilePhotoNotifier.value, isNull);
    });

    testWidgets('ProfileLogoutButton memunculkan dialog konfirmasi dan membatalkan jika pilih Batal', (tester) async {
      await SessionManager.saveSession(
        token: 'token_dummy',
        namaPasien: 'Dahlan Muda',
        fsMr: '01-88-24-90',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ProfileLogoutButton(),
            ),
          ),
        ),
      );

      expect(find.text('Keluar dari Akun'), findsOneWidget);

      // Tap tombol keluar
      await tester.tap(find.text('Keluar dari Akun'));
      await tester.pumpAndSettle();

      // Dialog konfirmasi muncul
      expect(find.text('Konfirmasi'), findsOneWidget);
      expect(find.text('Yakin keluar akun?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Ya, Keluar'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Dialog tertutup dan sesi tetap aktif
      expect(find.text('Konfirmasi'), findsNothing);
      expect(SessionManager.isLoggedIn, isTrue);
      expect(SessionManager.token, 'token_dummy');
    });

    testWidgets('ProfileLogoutButton menghapus sesi dan berpindah ke LoginScreen jika pilih Ya, Keluar', (tester) async {
      await SessionManager.saveSession(
        token: 'token_dummy_logout',
        namaPasien: 'Dahlan Muda',
        fsMr: '01-88-24-90',
      );

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => const Scaffold(body: ProfileLogoutButton()),
            AppRoutes.login: (context) => const Scaffold(
                  body: Center(
                    child: Text('Login Screen PKU'),
                  ),
                ),
          },
        ),
      );

      // Tap tombol keluar
      await tester.tap(find.text('Keluar dari Akun'));
      await tester.pumpAndSettle();

      // Tap Ya, Keluar
      await tester.tap(find.text('Ya, Keluar'));
      await tester.pumpAndSettle();

      // Verifikasi sesi bersih
      expect(SessionManager.isLoggedIn, isFalse);
      expect(SessionManager.token, isNull);

      // Verifikasi navigasi ke LoginScreen
      expect(find.text('Login Screen PKU'), findsOneWidget);
      expect(find.text('Keluar dari Akun'), findsNothing);
    });
  });
}
