
import 'package:flutter/material.dart';
import 'package:pku_gamping_app/services/antrean_api_service.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/dokter_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.init();

  try {
    debugPrint('=== MULAI TES DOKTER API ===');

    final daftarDokter =
        await DokterApiService.getDaftarDokter(
      kodeLayanan: 'P001',
    );

    debugPrint('Koneksi API: BERHASIL');
    debugPrint('Jumlah dokter: ${daftarDokter.length}');

    if (daftarDokter.isNotEmpty) {
      final dokter = daftarDokter.first;

      debugPrint('Dokter pertama:');
      debugPrint('Kode dokter: ${dokter.kodeDokter}');
      debugPrint('Nama dokter: ${dokter.namaDokter}');
      debugPrint('Nama alias: ${dokter.namaAlias}');
      debugPrint('Kode layanan: ${dokter.kodeLayanan}');
      debugPrint('Nama layanan: ${dokter.namaLayanan}');
    } else {
      debugPrint('Tidak ada dokter untuk layanan tersebut.');
    }
  } catch (e) {
    debugPrint('Koneksi API: GAGAL');
    debugPrint('Error: $e');
  }


// 1. Ambil daftar dokter untuk layanan P001
const kodeLayanan = 'P001';

final daftarDokter = await DokterApiService.getDaftarDokter(
  kodeLayanan: kodeLayanan,
);

if (daftarDokter.isEmpty) {
  debugPrint('Tidak ada dokter pada layanan ini.');
  return;
}

// 2. Gunakan dokter pertama dari hasil API
final dokter = daftarDokter.first;

debugPrint('=== PENGUJIAN STATUS ANTREAN ===');

// 3. Panggil endpoint status antrean
final status = await AntreanApiService.getStatusAntreanModel(
  kodeLayanan: kodeLayanan,
  kodeDokter: dokter.kodeDokter,
  tanggal: DateTime.now().toIso8601String().substring(0, 10),
);

// 4. Tampilkan hasil parsing model
debugPrint('Sedang dilayani: ${status.sedangDilayani}');
debugPrint('Status pasien: ${status.statusPasien}');
debugPrint('Keterangan: ${status.keteranganStatus}');


  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Tes Dokter API selesai.'),
        ),
      ),
    ),
  );
}
