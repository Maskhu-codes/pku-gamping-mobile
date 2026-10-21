
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/main.dart';
import 'package:pku_gamping_app/screens/register_screen.dart';
import 'package:pku_gamping_app/screens/home_screen.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';

void main() {
  testWidgets('PkuGampingApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PkuGampingApp());
    await tester.pumpAndSettle();

    expect(find.byType(PkuGampingApp), findsOneWidget);
  });

  testWidgets('RegisterScreen render smoke test', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    expect(find.text('Daftar Pasien Baru'), findsOneWidget);
    expect(
      find.text('Lengkapi data diri Anda untuk mendaftar akun baru'),
      findsOneWidget,
    );
    expect(find.text('Langkah 1 dari 3'), findsOneWidget);
    expect(find.text('Cek NIK & Lanjutkan →'), findsOneWidget);
  });

  testWidgets('Home screen shows patient dashboard and queue states', (
      WidgetTester tester,
      ) async {
    AntreanService.kosongkanAntrean();

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RS PKU Gamping'), findsOneWidget);
    expect(find.text('Dahlan Muda'), findsOneWidget);
    expect(find.text('Belum Ada Antrean'), findsOneWidget);
    expect(find.text('Informasi & Berita'), findsOneWidget);
    expect(find.text('IGD 24 Jam RS PKU'), findsOneWidget);

    AntreanService.setAntreanDummy();
    await tester.pumpAndSettle();

    expect(find.text('NOMOR ANTREAN ANDA'), findsOneWidget);
    expect(find.text('A-014'), findsOneWidget);
  });
}
