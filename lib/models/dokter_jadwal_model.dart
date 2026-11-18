import 'package:flutter/material.dart';

/// Data model dokter untuk tampilan jadwal RS PKU Gamping
class DokterJadwal {
  final String nama;
  final String poli;
  final String jamMulai;
  final String jamSelesai;
  final String? fotoUrl;
  final StatusDokter status;
  final String? fsKdLayanan;
  final String? fsKdPetugasMedis;

  const DokterJadwal({
    required this.nama,
    required this.poli,
    required this.jamMulai,
    required this.jamSelesai,
    this.fotoUrl,
    this.status = StatusDokter.tersedia,
    this.fsKdLayanan,
    this.fsKdPetugasMedis,
  });
}

/// Status ketersediaan dokter
enum StatusDokter {
  tersedia,
  penuh,
  tutup,
  selesai,
  cuti,
}

/// Label teks & warna status dokter
extension StatusDokterLabel on StatusDokter {
  String get label {
    switch (this) {
      case StatusDokter.tersedia:
        return 'Tersedia';
      case StatusDokter.penuh:
        return 'Penuh';
      case StatusDokter.tutup:
        return 'Tutup';
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
      case StatusDokter.penuh:
        return const Color(0xFFD97706);
      case StatusDokter.tutup:
        return const Color(0xFFDC2626);
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
      case StatusDokter.penuh:
        return const Color(0xFFFEF3C7);
      case StatusDokter.tutup:
        return const Color(0xFFFEE2E2);
      case StatusDokter.selesai:
        return const Color(0xFFF1F5F9);
      case StatusDokter.cuti:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get bgColor => backgroundColor;
}
