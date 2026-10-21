import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/main.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';

void main() {
  testWidgets('Home screen shows patient dashboard and dynamic queue states', (
    WidgetTester tester,
  ) async {
    // 1. Kondisi Awal: Belum Ada Antrean
    AntreanService.kosongkanAntrean();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('RS PKU Gamping'), findsOneWidget);
    expect(find.text('Dahlan Muda'), findsOneWidget);
    expect(find.text('Belum Ada Antrean'), findsOneWidget);
    expect(find.text('Informasi & Berita'), findsOneWidget);
    expect(find.text('IGD 24 Jam RS PKU'), findsOneWidget);

    // 2. Simulasi: Pasang Antrean Aktif
    AntreanService.setAntreanDummy();
    await tester.pumpAndSettle();

    expect(find.text('NOMOR ANTREAN ANDA'), findsOneWidget);
    expect(find.text('A-014'), findsOneWidget);
  });
}
