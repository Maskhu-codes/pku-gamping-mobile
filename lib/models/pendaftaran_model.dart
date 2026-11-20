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

/// Model jadwal praktik dokter dari API SIMRS
class JadwalSimrsModel {
  final String kodeDokter;
  final String kodeLayanan;
  final int hari;
  final String tanggal;
  final String namaHari;
  final String sesiPoli;
  final String jamMulai;
  final String jamSelesai;
  final int totalKuota;
  final int terdaftar;
  final bool isClosed;
  final bool isFull;
  final bool canBook;

  const JadwalSimrsModel({
    required this.kodeDokter,
    required this.kodeLayanan,
    required this.hari,
    required this.tanggal,
    required this.namaHari,
    required this.sesiPoli,
    required this.jamMulai,
    required this.jamSelesai,
    required this.totalKuota,
    required this.terdaftar,
    required this.isClosed,
    required this.isFull,
    required this.canBook,
  });

  factory JadwalSimrsModel.fromJson(Map<String, dynamic> json) {
    return JadwalSimrsModel(
      kodeDokter: json['FS_KD_DOKTER']?.toString() ?? '',
      kodeLayanan: json['FS_KD_LAYANAN']?.toString() ?? '',
      hari: int.tryParse(
            (json['FN_HARI'] ?? json['fn_hari']).toString(),
          ) ??
          0,
      tanggal: json['fd_tgl']?.toString() ?? '',
      namaHari: json['fs_nm_hari']?.toString() ?? '',
      sesiPoli: json['FS_KD_SESION_POLI']?.toString() ?? '',
      jamMulai: json['FS_JAM_MULAI']?.toString() ?? '',
      jamSelesai: json['FS_JAM_SELESAI']?.toString() ?? '',
      totalKuota: int.tryParse(json['FN_MAX'].toString()) ?? 0,
      terdaftar: int.tryParse(json['terdaftar'].toString()) ?? 0,
      isClosed: json['is_closed'] == true,
      isFull: json['is_full'] == true,
      canBook: json['can_book'] == true,
    );
  }
}