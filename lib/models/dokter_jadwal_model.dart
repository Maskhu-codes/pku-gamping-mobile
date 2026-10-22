import 'package:flutter/material.dart';

/// Data model dokter untuk tampilan jadwal RS PKU Gamping
class DokterJadwal {
  final String nama;
  final String poli;
  final String jamMulai;
  final String jamSelesai;
  final String? fotoUrl;
  final StatusDokter status;

  const DokterJadwal({
    required this.nama,
    required this.poli,
    required this.jamMulai,
    required this.jamSelesai,
    this.fotoUrl,
    this.status = StatusDokter.tersedia,
  });
}

/// Status ketersediaan dokter
enum StatusDokter {
  tersedia,
  selesai,
  cuti,
}

/// Label teks & warna status dokter
extension StatusDokterLabel on StatusDokter {
  String get label {
    switch (this) {
      case StatusDokter.tersedia:
        return 'Tersedia';
      case StatusDokter.selesai:
        return 'Selesai';
      case StatusDokter.cuti:
        return 'Cuti';
    }
  }

  Color get color {
    switch (this) {
      case StatusDokter.tersedia:
        return const Color(0xFF16A34A);
      case StatusDokter.selesai:
        return const Color(0xFF94A3B8);
      case StatusDokter.cuti:
        return const Color(0xFFDC2626);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case StatusDokter.tersedia:
        return const Color(0xFFDCFCE7);
      case StatusDokter.selesai:
        return const Color(0xFFF1F5F9);
      case StatusDokter.cuti:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get bgColor => backgroundColor;
}
