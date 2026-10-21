import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/screens/register_screen.dart';
import 'package:pku_gamping_app/screens/login_screen.dart';

void main() {
  Widget createRegisterTestWidget() {
    return MaterialApp(
      initialRoute: '/register',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }

  testWidgets('Register Flow: Header, form inputs, steps, and submit',
      (WidgetTester tester) async {
    // Set realistic mobile phone viewport
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createRegisterTestWidget());
    await tester.pumpAndSettle();

    // 1. Verifikasi Header Halaman Daftar Pasien Baru
    expect(find.text('Daftar Pasien Baru'), findsOneWidget);
    expect(find.text('Lengkapi data diri Anda untuk mendaftar akun baru'),
        findsOneWidget);
    expect(find.text('Registrasi Online SIMRS'), findsOneWidget);
    expect(find.text('Buat Akun Baru'), findsOneWidget);

    // 2. Verifikasi NIK Input & Cek NIK
    final nikField = find.byType(TextFormField).first;
    await tester.enterText(nikField, '3471041234560001');
    await tester.pumpAndSettle();

    // Tap Cek NIK button
    await tester.tap(find.text('Cek NIK'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Valid'), findsOneWidget);

    // Lanjut ke Langkah 2
    final cekNikButton = find.text('Cek NIK & Lanjutkan →');
    await tester.ensureVisible(cekNikButton);
    await tester.tap(cekNikButton);
    await tester.pumpAndSettle();

    // 3. Verifikasi Langkah 2 aktif & bisa diketik
    expect(find.text('Langkah 2 dari 3'), findsOneWidget);
    expect(find.text('Data Pasien'), findsWidgets);

    // Cari field Nama Lengkap dan masukkan teks
    final namaField = find.widgetWithText(TextFormField, 'Masukkan nama lengkap sesuai KTP');
    expect(namaField, findsOneWidget);
    await tester.enterText(namaField, 'Ahmad Fauzi');
    await tester.pumpAndSettle();

    // Cari field Tempat Lahir dan masukkan teks
    final tempatLahirField = find.widgetWithText(TextFormField, 'Kota Lahir');
    expect(tempatLahirField, findsOneWidget);
    await tester.enterText(tempatLahirField, 'Yogyakarta');
    await tester.pumpAndSettle();

    // Isi email di kontak pasien
    final emailKontakField = find.widgetWithText(TextFormField, 'contoh@email.com');
    await tester.ensureVisible(emailKontakField);
    await tester.enterText(emailKontakField, 'ahmad.fauzi@gmail.com');
    await tester.pumpAndSettle();

    // Lanjut ke Langkah 3
    final lanjutStep3Button = find.text('Lanjut Langkah 3 →');
    await tester.ensureVisible(lanjutStep3Button);
    await tester.tap(lanjutStep3Button);
    await tester.pumpAndSettle();

    // 4. Verifikasi Langkah 3 aktif & bisa diketik
    expect(find.text('Langkah 3 dari 3'), findsOneWidget);
    expect(find.text('Akun & Sandi'), findsOneWidget);

    // Verifikasi field Username ada dan terisi saran atau bisa diketik
    final usernameField = find.widgetWithText(TextFormField, 'ahmadfauzi_0001');
    expect(usernameField, findsOneWidget);
    await tester.enterText(usernameField, 'ahmad_fauzi23');
    await tester.pumpAndSettle();

    // Masukkan password & konfirmasi password
    final passField = find.widgetWithText(TextFormField, 'Minimal 8 karakter');
    expect(passField, findsOneWidget);
    await tester.enterText(passField, 'Rahasia123!');
    await tester.pumpAndSettle();

    final confirmField = find.widgetWithText(TextFormField, 'Ulangi kata sandi');
    expect(confirmField, findsOneWidget);
    await tester.enterText(confirmField, 'Rahasia123!');
    await tester.pumpAndSettle();

    // Verifikasi tombol adalah 'Daftar' (bukan OTP / preview modal)
    final daftarButton = find.widgetWithText(ElevatedButton, 'Daftar');
    expect(daftarButton, findsOneWidget);

    // Tap Daftar
    await tester.ensureVisible(daftarButton);
    await tester.tap(daftarButton);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // 5. Verifikasi selesai daftar kembali ke login dengan notifikasi
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Pendaftaran berhasil! Silakan masuk ke akun Anda.'), findsOneWidget);
  });

  testWidgets('Navigation "Sudah punya akun? Masuk" leads to LoginScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createRegisterTestWidget());
    await tester.pumpAndSettle();

    // Tap "Sudah punya akun? Masuk"
    final masukFinder = find.text('Masuk');
    expect(masukFinder, findsWidgets);
    await tester.tap(masukFinder.first);
    await tester.pumpAndSettle();

    // Verifikasi navigasi ke LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
