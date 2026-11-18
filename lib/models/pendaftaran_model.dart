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
        id: (json['fs_kd_layanan'] ?? json['FS_KD_LAYANAN'] ?? json['id'] ?? '').toString().trim(),
        nama: (json['fs_nm_layanan'] ?? json['FS_NM_LAYANAN'] ?? json['nama'] ?? '').toString().trim(),
        icon: Icons.local_hospital_outlined,
        deskripsi: (json['deskripsi'] ?? json['fs_deskripsi'] ?? 'Layanan rawat jalan terpadu').toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'deskripsi': deskripsi,
        'fs_kd_layanan': id,
        'fs_nm_layanan': nama,
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
  final bool isClosed;
  final bool canBook;
  final String tanggal;
  final String namaHari;
  final String kdDokter;
  final String kdLayanan;
  final String fnHari;
  final String kdSesionPoli;
  final String jamMulai;
  final int terdaftar;
  final String shift; // "Praktik Pagi" / "Praktik Sore"

  const JadwalSlotModel({
    required this.id,
    required this.hariTanggal,
    required this.jam,
    required this.sisaKuota,
    required this.totalKuota,
    this.isPenuh = false,
    this.isClosed = false,
    this.canBook = true,
    this.tanggal = '',
    this.namaHari = '',
    this.kdDokter = '',
    this.kdLayanan = '',
    this.fnHari = '',
    this.kdSesionPoli = '',
    this.jamMulai = '',
    this.terdaftar = 0,
    this.shift = 'Praktik Pagi',
  });

  String get kuotaLabel {
    if (isClosed) return 'Poli Tutup';
    if (isPenuh) return 'Penuh';
    return 'Sisa $sisaKuota/$totalKuota';
  }

  String get statusLabel {
    if (isClosed) return 'Poli Tutup';
    if (isPenuh) return 'Penuh';
    if (canBook) return 'Tersedia';
    return 'Tidak Tersedia';
  }

  static String formatTanggalIndo(String? yyyyMmDd) {
    if (yyyyMmDd == null || yyyyMmDd.isEmpty) return '';
    try {
      final parts = yyyyMmDd.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = int.tryParse(parts[1]) ?? 1;
        final day = int.tryParse(parts[2]) ?? 1;
        const bulan = [
          '',
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember'
        ];
        final namaBulan = (month >= 1 && month <= 12) ? bulan[month] : parts[1];
        return '$day $namaBulan $year';
      }
    } catch (_) {}
    return yyyyMmDd;
  }

  factory JadwalSlotModel.fromJson(Map<String, dynamic> json) {
    final tglRaw = (json['fd_tgl'] ?? json['tanggal'] ?? '').toString();
    final hariRaw = (json['fs_nm_hari'] ?? json['namaHari'] ?? '').toString();
    final noUrut = (json['FN_NO_URUT'] ?? json['no_urut'] ?? '1').toString();
    final jamMulai = (json['FS_JAM_MULAI'] ?? json['jam_mulai'] ?? '').toString();
    final jamSelesai = (json['FS_JAM_SELESAI'] ?? json['jam_selesai'] ?? '').toString();

    final maxVal = int.tryParse((json['FN_MAX'] ?? json['totalKuota'] ?? '0').toString()) ?? 0;
    final terdaftarVal = int.tryParse((json['terdaftar'] ?? '0').toString()) ?? 0;
    final sisa = json['sisaKuota'] != null
        ? (json['sisaKuota'] as num).toInt()
        : (maxVal - terdaftarVal).clamp(0, maxVal);

    final closed = json['is_closed'] == true || json['isClosed'] == true;
    final full = json['is_full'] == true || json['isPenuh'] == true || (maxVal > 0 && sisa <= 0);
    final bookable = json['can_book'] == true || json['canBook'] == true || (!closed && !full);

    String jamText = (json['jam'] ?? '').toString();
    if (jamText.isEmpty && jamMulai.isNotEmpty) {
      jamText = jamSelesai.isNotEmpty ? '$jamMulai - $jamSelesai WIB' : '$jamMulai WIB';
    }

    String hariTglText = (json['hariTanggal'] ?? '').toString();
    if (hariTglText.isEmpty && tglRaw.isNotEmpty) {
      final tglFormatted = formatTanggalIndo(tglRaw);
      hariTglText = hariRaw.isNotEmpty ? '$hariRaw, $tglFormatted' : tglFormatted;
    }

    final sesionPoli = (json['FS_KD_SESION_POLI'] ?? json['fs_kd_sesion_poli'] ?? '').toString().trim();
    final fnHariVal = (json['fn_hari'] ?? json['FN_HARI'] ?? json['fnHari'] ?? '').toString().trim();
    String shiftText = (json['shift'] ?? '').toString();
    if (shiftText.isEmpty) {
      shiftText = sesionPoli == '2' ? 'Praktik Sore' : 'Praktik Pagi';
    }

    return JadwalSlotModel(
      id: (json['id'] ?? (tglRaw.isNotEmpty ? '${tglRaw}_$noUrut' : '')).toString(),
      hariTanggal: hariTglText,
      jam: jamText,
      sisaKuota: sisa,
      totalKuota: maxVal,
      isPenuh: full,
      isClosed: closed,
      canBook: bookable,
      tanggal: tglRaw,
      namaHari: hariRaw,
      kdDokter: (json['FS_KD_DOKTER'] ?? json['kdDokter'] ?? '').toString(),
      kdLayanan: (json['FS_KD_LAYANAN'] ?? json['kdLayanan'] ?? '').toString(),
      fnHari: fnHariVal,
      kdSesionPoli: sesionPoli,
      jamMulai: jamMulai,
      terdaftar: terdaftarVal,
      shift: shiftText,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hariTanggal': hariTanggal,
        'jam': jam,
        'sisaKuota': sisaKuota,
        'totalKuota': totalKuota,
        'isPenuh': isPenuh,
        'shift': shift,
        'is_closed': isClosed,
        'is_full': isPenuh,
        'can_book': canBook,
        'fd_tgl': tanggal,
        'fs_nm_hari': namaHari,
        'terdaftar': terdaftar,
        'FS_KD_DOKTER': kdDokter,
        'FS_KD_LAYANAN': kdLayanan,
        'fn_hari': fnHari,
        'FS_KD_SESION_POLI': kdSesionPoli,
        'FS_JAM_MULAI': jamMulai,
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

  DokterPendaftaranModel copyWith({
    List<JadwalSlotModel>? jadwalSlots,
  }) =>
      DokterPendaftaranModel(
        id: id,
        nama: nama,
        poliId: poliId,
        spesialisasi: spesialisasi,
        fotoUrl: fotoUrl,
        jadwalSlots: jadwalSlots ?? this.jadwalSlots,
      );

  factory DokterPendaftaranModel.fromJson(Map<String, dynamic> json) =>
      DokterPendaftaranModel(
        id: (json['fs_kd_peg'] ?? json['FS_KD_PEG'] ?? json['id'] ?? '').toString().trim(),
        nama: (json['fs_nm_peg'] ?? json['FS_NM_PEG'] ?? json['nama'] ?? json['fs_nm_alias'] ?? '').toString().trim(),
        poliId: (json['fs_kd_layanan'] ?? json['FS_KD_LAYANAN'] ?? json['poliId'] ?? '').toString().trim(),
        spesialisasi: (json['spesialisasi'] ?? json['fs_nm_layanan'] ?? json['FS_NM_LAYANAN'] ?? '').toString().trim(),
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
        'fs_kd_peg': id,
        'fs_nm_peg': nama,
        'fs_kd_layanan': poliId,
        'fs_nm_layanan': spesialisasi,
      };
}

/// Jenis Jaminan Pembayaran Pasien Mandiri
enum JenisJaminan {
  umumPribadi,
  relasi,
  @Deprecated('Aplikasi ini khusus untuk pendaftaran pasien mandiri non-BPJS')
  bpjs,
}

extension JenisJaminanLabel on JenisJaminan {
  String get label {
    switch (this) {
      case JenisJaminan.umumPribadi:
        return 'Umum / Pribadi';
      case JenisJaminan.relasi:
        return 'Relasi';
      case JenisJaminan.bpjs:
        return 'BPJS Kesehatan';
    }
  }
}
