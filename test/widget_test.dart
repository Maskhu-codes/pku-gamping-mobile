import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/main.dart';
import 'package:pku_gamping_app/screens/home_screen.dart';
import 'package:pku_gamping_app/screens/login_screen.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';

void main() {
  testWidgets('PkuGampingApp opens the login screen after splash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PkuGampingApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(PkuGampingApp), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Home screen shows empty and active queue states', (
    WidgetTester tester,
  ) async {
    AntreanService.kosongkanAntrean();
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
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
    AntreanService.kosongkanAntrean();
  });
}
