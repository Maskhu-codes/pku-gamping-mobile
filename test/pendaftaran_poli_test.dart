import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/services/mock/pendaftaran_mock_data.dart';
import 'package:pku_gamping_app/services/pendaftaran_service.dart';

void main() {
  const expectedPoliList = [
    'Anak',
    'Anak Neurologi',
    'Anestesi',
    'Andrologi',
    'Bedah Anak',
    'Bedah Digestif',
    'Bedah Mulut',
    'Bedah Onkologi',
    'Bedah Orthopedi',
    'Bedah Plastik',
    'Bedah Syaraf',
    'Bedah TKV',
    'Bedah Umum',
    'Bedah Urologi',
    'Bedah Vaskuler',
    'Dalam',
    'Dalam Ginjal dan Hipertensi',
    'Forensik',
    'Gigi Endodonsi',
    'Gigi Orthodonti',
    'Gigi Pedodonsi (Anak)',
    'Gigi Periodonti',
    'Gigi Prostodonti',
    'Hemato Onkologi',
    'Hip and Knee',
    'Home Care',
    'IVF dan Ingin Anak',
    'Jantung',
    'Jiwa',
    'Kardiologi Intervensi',
    'Kebidanan',
    'Kemoterapi',
    'Kulit dan Kelamin',
    'Mata',
    'Medical Check Up',
    'Neonatologi',
    'Neurologi Intervensi',
    'ODC Hemato Onkologi',
    'ODC Penyakit Dalam',
    'Onkologi Ginekologi',
    'Onkologi Radiasi',
    'Onkologi Toraks',
    'Paru',
    'Poli Eksekutif',
    'Poliklinik',
    'Psikologi',
    'Rehab Medik',
    'Syaraf',
    'T.H.T',
    'Telemedicine',
    'Tumbuh Kembang Anak',
    'Vaksin',
  ];

  group('Pendaftaran Poliklinik Tests', () {
    test('Jumlah total poli harus tepat 52 pilihan', () {
      expect(PendaftaranDummyData.listPoli.length, 52);
    });

    test('Tidak ada duplikasi id maupun nama poli', () {
      final names = PendaftaranDummyData.listPoli.map((p) => p.nama).toList();
      final ids = PendaftaranDummyData.listPoli.map((p) => p.id).toList();

      expect(names.toSet().length, 52, reason: 'Terdapat nama poli duplikat');
      expect(ids.toSet().length, 52, reason: 'Terdapat id poli duplikat');
    });

    test('Seluruh 52 pilihan poli sesuai dengan daftar referensi rumah sakit', () {
      final actualNames =
          PendaftaranDummyData.listPoli.map((p) => p.nama).toList();

      for (final expected in expectedPoliList) {
        expect(
          actualNames.contains(expected),
          isTrue,
          reason: 'Poli "$expected" tidak ditemukan dalam daftar',
        );
      }
    });

    test('PendaftaranService.getListPoli mengembalikan seluruh 52 poli saat fallback', () async {
      final list = await PendaftaranService.getListPoli();
      expect(list.length, 52);
    });

    test('Pencarian poli bekerja dengan benar', () {
      // Cari "Bedah" -> harus menemukan seluruh 11 poli bedah
      final bedahResults = PendaftaranDummyData.listPoli
          .where((p) => p.nama.toLowerCase().contains('bedah'))
          .toList();
      expect(bedahResults.length, 11);

      // Cari "Anak"
      final anakResults = PendaftaranDummyData.listPoli
          .where((p) => p.nama.toLowerCase().contains('anak'))
          .toList();
      expect(anakResults.length, 6);

      // Cari "Gigi"
      final gigiResults = PendaftaranDummyData.listPoli
          .where((p) => p.nama.toLowerCase().contains('gigi'))
          .toList();
      expect(gigiResults.length, 5);
    });

    test('Setiap dari 52 poli memiliki dokter dan jadwal kunjungan yang siap dipilih', () {
      for (final poli in PendaftaranDummyData.listPoli) {
        final dokters = PendaftaranDummyData.getDokterByPoliId(poli.id);
        expect(
          dokters.isNotEmpty,
          isTrue,
          reason: 'Poli "${poli.nama}" tidak memiliki dokter',
        );
        expect(
          dokters.first.jadwalSlots.isNotEmpty,
          isTrue,
          reason: 'Dokter untuk poli "${poli.nama}" tidak memiliki slot jadwal',
        );
      }
    });
  });
}
