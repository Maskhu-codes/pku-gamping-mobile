import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/main.dart';
import 'package:pku_gamping_app/screens/register_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('PkuGampingApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PkuGampingApp());
    await tester.pumpAndSettle();
    expect(find.byType(PkuGampingApp), findsOneWidget);
  });

  testWidgets('RegisterScreen render smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    // Verifikasi header
    expect(find.text('Daftar Pasien Baru'), findsOneWidget);
    expect(find.text('Lengkapi data diri Anda untuk mendaftar akun baru'), findsOneWidget);

    // Verifikasi stepper awal
    expect(find.text('Langkah 1 dari 3'), findsOneWidget);
    expect(find.text('Cek NIK & Lanjutkan →'), findsOneWidget);
  });
}
