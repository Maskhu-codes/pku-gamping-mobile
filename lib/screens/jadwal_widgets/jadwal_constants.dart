import 'package:flutter/material.dart';

/// ─── Konstanta Warna & Gaya untuk Screen Jadwal ───
/// Satu sumber kebenaran (single source of truth) agar
/// seluruh widget jadwal konsisten dan mudah diperbarui.

const Color kPrimaryBlue = Color(0xFF0D4FC1);
const Color kInk = Color(0xFF182238);
const Color kMuted = Color(0xFF91A3BE);
const Color kPageBg = Color(0xFFF7F9FC);
const Color kCardBorder = Color(0xFFE2E7EE);
const Color kDivider = Color(0xFFE1E6EE);

const Color kGreenStatus = Color(0xFF16A34A);
const Color kGreenBg = Color(0xFFDCFCE7);
const Color kGrayStatus = Color(0xFF94A3B8);
const Color kGrayBg = Color(0xFFF1F5F9);

const String kFontFamily = 'Plus Jakarta Sans';

/// Data model dokter untuk tampilan jadwal.
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

/// Status ketersediaan dokter.
enum StatusDokter {
  tersedia,
  selesai,
  cuti,
}

/// Label teks Indonesia untuk [StatusDokter].
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
        return kGreenStatus;
      case StatusDokter.selesai:
        return kGrayStatus;
      case StatusDokter.cuti:
        return const Color(0xFFDC2626);
    }
  }

  Color get bgColor {
    switch (this) {
      case StatusDokter.tersedia:
        return kGreenBg;
      case StatusDokter.selesai:
        return kGrayBg;
      case StatusDokter.cuti:
        return const Color(0xFFFEE2E2);
    }
  }
}
