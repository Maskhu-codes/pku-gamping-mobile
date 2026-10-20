// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:pku_gamping_app/main.dart';

void main() {
  testWidgets('Home screen shows patient dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('RS PKU Gamping'), findsOneWidget);
    expect(find.text('Dahlan Muda'), findsOneWidget);
    expect(find.text('Belum Ada Antrean'), findsOneWidget);
    expect(find.text('Informasi & Berita'), findsOneWidget);
    expect(find.text('IGD 24 Jam RS PKU'), findsOneWidget);
  });
}
