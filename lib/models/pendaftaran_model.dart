import 'package:flutter/material.dart';

/// Model Data Poli Klinik RS PKU Gamping
class PoliModel {
  final String id;
  final String nama;
  final IconData icon;
  final String deskripsi;

  const PoliModel({
    required this.id,
    required this.nama,
    required this.icon,
    this.deskripsi = 'Layanan rawat jalan terpadu',
  });

  factory PoliModel.fromJson(Map<String, dynamic> json) => PoliModel(
        id: json['id'] as String? ?? '',
        nama: json['nama'] as String? ?? '',
        icon: Icons.local_hospital_outlined,
        deskripsi: json['deskripsi'] as String? ?? 'Layanan rawat jalan terpadu',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'deskripsi': deskripsi,
      };
}

/// Model Slot Jadwal Kunjungan Rawat Jalan
class JadwalSlotModel {
  final String id;
  final String hariTanggal; // e.g. "Jumat, 9 Oktober 2026"
  final String jam; // e.g. "Pukul 07.30 WIB"
  final int sisaKuota;
  final int totalKuota;
  final bool isPenuh;
  final String shift; // "Praktik Pagi" / "Praktik Sore"

  const JadwalSlotModel({
    required this.id,
    required this.hariTanggal,
    required this.jam,
    required this.sisaKuota,
    required this.totalKuota,
    this.isPenuh = false,
    this.shift = 'Praktik Pagi',
  });

  String get kuotaLabel => isPenuh ? 'Penuh' : 'Sisa $sisaKuota/$totalKuota';

  factory JadwalSlotModel.fromJson(Map<String, dynamic> json) =>
      JadwalSlotModel(
        id: json['id'] as String? ?? '',
        hariTanggal: json['hariTanggal'] as String? ?? '',
        jam: json['jam'] as String? ?? '',
        sisaKuota: (json['sisaKuota'] as num?)?.toInt() ?? 0,
        totalKuota: (json['totalKuota'] as num?)?.toInt() ?? 0,
        isPenuh: json['isPenuh'] as bool? ?? false,
        shift: json['shift'] as String? ?? 'Praktik Pagi',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hariTanggal': hariTanggal,
        'jam': jam,
        'sisaKuota': sisaKuota,
        'totalKuota': totalKuota,
        'isPenuh': isPenuh,
        'shift': shift,
      };
}

/// Model Dokter untuk Alur Pendaftaran
class DokterPendaftaranModel {
  final String id;
  final String nama;
  final String poliId;
  final String spesialisasi;
  final String? fotoUrl;
  final List<JadwalSlotModel> jadwalSlots;

  const DokterPendaftaranModel({
    required this.id,
    required this.nama,
    required this.poliId,
    required this.spesialisasi,
    this.fotoUrl,
    required this.jadwalSlots,
  });

  factory DokterPendaftaranModel.fromJson(Map<String, dynamic> json) =>
      DokterPendaftaranModel(
        id: json['id'] as String? ?? '',
        nama: json['nama'] as String? ?? '',
        poliId: json['poliId'] as String? ?? '',
        spesialisasi: json['spesialisasi'] as String? ?? '',
        fotoUrl: json['fotoUrl'] as String?,
        jadwalSlots: (json['jadwalSlots'] as List<dynamic>?)
                ?.map((e) => JadwalSlotModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'poliId': poliId,
        'spesialisasi': spesialisasi,
        'fotoUrl': fotoUrl,
        'jadwalSlots': jadwalSlots.map((e) => e.toJson()).toList(),
      };
}

/// Jenis Jaminan Pembayaran Pasien
enum JenisJaminan {
  umumPribadi,
  relasi,
}

extension JenisJaminanLabel on JenisJaminan {
  String get label {
    switch (this) {
      case JenisJaminan.umumPribadi:
        return 'Umum / Pribadi';
      case JenisJaminan.relasi:
        return 'Relasi';
    }
  }
}
