/// Model data antrean aktif untuk pasien rawat jalan RS PKU Muhammadiyah Gamping.
class AntreanAktifModel {
  final String nomorAntrean; // e.g. "A-014"
  final String namaPasien; // e.g. "Dahlan Muda"
  final String noRm; // e.g. "01-88-24-90"
  final String poli; // e.g. "Poli Penyakit Dalam"
  final String gedungLokasi; // e.g. "Gedung A • Lt. 2"
  final String dokter; // e.g. "dr. Hendra Wicaksono, Sp.PD"
  final String jam; // e.g. "07:30 WIB"
  final String statusAntrean; // e.g. "Antrean Berjalan"
  final int sisaAntrean; // e.g. 3
  final String tanggal; // e.g. "Jumat, 9 Oktober 2026"
  final String jenisJaminan; // e.g. "Umum / Pribadi"
  final String fsKdLayanan; // e.g. "P003"
  final String fsKdPetugasMedis; // e.g. "S379"
  final String fsKdAntrian; // e.g. "AN202611130001"
  final String noBooking; // e.g. "BO202611130001"
  final String rawTanggal; // e.g. "2026-11-13"
  final int statusPasien; // 0: Booking, 1: Triage, 2: Poli, 3: Selesai
  final String? sedangDilayaniLive;

  const AntreanAktifModel({
    required this.nomorAntrean,
    required this.namaPasien,
    required this.noRm,
    required this.poli,
    this.gedungLokasi = 'Gedung A • Lt. 2',
    required this.dokter,
    required this.jam,
    this.statusAntrean = 'Antrean Berjalan',
    this.sisaAntrean = 3,
    required this.tanggal,
    this.jenisJaminan = 'Umum / Pribadi',
    this.fsKdLayanan = '',
    this.fsKdPetugasMedis = '',
    this.fsKdAntrian = '',
    this.noBooking = '',
    this.rawTanggal = '',
    this.statusPasien = 0,
    this.sedangDilayaniLive,
  });

  AntreanAktifModel copyWith({
    String? nomorAntrean,
    String? namaPasien,
    String? noRm,
    String? poli,
    String? gedungLokasi,
    String? dokter,
    String? jam,
    String? statusAntrean,
    int? sisaAntrean,
    String? tanggal,
    String? jenisJaminan,
    String? fsKdLayanan,
    String? fsKdPetugasMedis,
    String? fsKdAntrian,
    String? noBooking,
    String? rawTanggal,
    int? statusPasien,
    String? sedangDilayaniLive,
  }) =>
      AntreanAktifModel(
        nomorAntrean: nomorAntrean ?? this.nomorAntrean,
        namaPasien: namaPasien ?? this.namaPasien,
        noRm: noRm ?? this.noRm,
        poli: poli ?? this.poli,
        gedungLokasi: gedungLokasi ?? this.gedungLokasi,
        dokter: dokter ?? this.dokter,
        jam: jam ?? this.jam,
        statusAntrean: statusAntrean ?? this.statusAntrean,
        sisaAntrean: sisaAntrean ?? this.sisaAntrean,
        tanggal: tanggal ?? this.tanggal,
        jenisJaminan: jenisJaminan ?? this.jenisJaminan,
        fsKdLayanan: fsKdLayanan ?? this.fsKdLayanan,
        fsKdPetugasMedis: fsKdPetugasMedis ?? this.fsKdPetugasMedis,
        fsKdAntrian: fsKdAntrian ?? this.fsKdAntrian,
        noBooking: noBooking ?? this.noBooking,
        rawTanggal: rawTanggal ?? this.rawTanggal,
        statusPasien: statusPasien ?? this.statusPasien,
        sedangDilayaniLive: sedangDilayaniLive ?? this.sedangDilayaniLive,
      );

  String get statusPasienLabel {
    switch (statusPasien) {
      case 1:
        return 'Terdaftar (Menuju Triage)';
      case 2:
        return 'Triage Selesai (Menunggu Poli)';
      case 3:
        return 'Poli Selesai (Menuju Farmasi)';
      case 0:
      default:
        return 'Booking Terjadwal';
    }
  }

  Map<String, dynamic> toJson() => {
        'nomorAntrean': nomorAntrean,
        'namaPasien': namaPasien,
        'noRm': noRm,
        'poli': poli,
        'gedungLokasi': gedungLokasi,
        'dokter': dokter,
        'jam': jam,
        'statusAntrean': statusAntrean,
        'sisaAntrean': sisaAntrean,
        'tanggal': tanggal,
        'jenisJaminan': jenisJaminan,
        'fsKdLayanan': fsKdLayanan,
        'fsKdPetugasMedis': fsKdPetugasMedis,
        'fsKdAntrian': fsKdAntrian,
        'noBooking': noBooking,
        'rawTanggal': rawTanggal,
        'statusPasien': statusPasien,
        'sedangDilayaniLive': sedangDilayaniLive,
      };

  factory AntreanAktifModel.fromJson(Map<String, dynamic> json) =>
      AntreanAktifModel(
        nomorAntrean: json['nomorAntrean'] as String? ?? 'A-001',
        namaPasien: json['namaPasien'] as String? ?? 'Dahlan Muda',
        noRm: json['noRm'] as String? ?? '01-88-24-90',
        poli: json['poli'] as String? ?? 'Poli Penyakit Dalam',
        gedungLokasi: json['gedungLokasi'] as String? ?? 'Gedung A • Lt. 2',
        dokter: json['dokter'] as String? ?? 'dr. Hendra Wicaksono, Sp.PD',
        jam: json['jam'] as String? ?? '07:30 WIB',
        statusAntrean: json['statusAntrean'] as String? ?? 'Antrean Berjalan',
        sisaAntrean: (json['sisaAntrean'] as num?)?.toInt() ?? 3,
        tanggal: json['tanggal'] as String? ?? 'Hari Ini',
        jenisJaminan: json['jenisJaminan'] as String? ?? 'Umum / Pribadi',
        fsKdLayanan: json['fsKdLayanan'] as String? ?? '',
        fsKdPetugasMedis: json['fsKdPetugasMedis'] as String? ?? '',
        fsKdAntrian: json['fsKdAntrian'] as String? ?? '',
        noBooking: json['noBooking'] as String? ?? '',
        rawTanggal: json['rawTanggal'] as String? ?? '',
        statusPasien: (json['statusPasien'] as num?)?.toInt() ?? 0,
        sedangDilayaniLive: json['sedangDilayaniLive'] as String?,
      );

  /// Factory untuk memetakan response dari endpoint `GET /booking/aktif`
  factory AntreanAktifModel.fromBookingJson(Map<String, dynamic> json) {
    final rawNoUrut = json['no_urut'] ?? json['fn_no_urut'];
    final rawNoAntrian = json['no_antrian'] ?? json['fs_kd_antrian'];
    final nomorAntrean =
        (rawNoUrut ?? rawNoAntrian ?? 'A-001').toString().trim();

    final poli = (json['poliName'] ??
            json['FS_NM_LAYANAN'] ??
            json['fs_nm_layanan'] ??
            json['poli'] ??
            'Poli Rawat Jalan')
        .toString()
        .trim();

    final dokter = (json['dokterName'] ??
            json['FS_NM_PEG'] ??
            json['fs_nm_peg'] ??
            json['dokter'] ??
            'Dokter Spesialis')
        .toString()
        .trim();

    final rawTgl =
        (json['fd_tgl_periksa'] ?? json['tanggal'] ?? '').toString().trim();
    String tanggalFormatted = rawTgl;
    if (rawTgl.contains('-')) {
      final parts = rawTgl.split('-');
      if (parts.length == 3) {
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
        final month = int.tryParse(parts[1]) ?? 1;
        final namaBulan =
            (month >= 1 && month <= 12) ? bulan[month] : parts[1];
        final day = int.tryParse(parts[2]) ?? parts[2];
        tanggalFormatted = '$day $namaBulan ${parts[0]}';
      }
    }

    final rawJam =
        (json['fs_jam_mulai'] ?? json['jam'] ?? '08:00').toString().trim();
    final jamText = rawJam.contains('WIB') ? rawJam : '$rawJam WIB';

    final noRm = (json['fs_mr'] ?? '').toString().trim();
    final namaPasien = (json['namaPasien'] ??
            json['fs_nm_pasien'] ??
            '')
        .toString()
        .trim();

    final kdLayanan =
        (json['fs_kd_layanan'] ?? json['kdLayanan'] ?? '').toString().trim();
    final kdPetugasMedis = (json['fs_kd_petugas_medis'] ??
            json['kdPetugasMedis'] ??
            json['kdDokter'] ??
            '')
        .toString()
        .trim();
    final noAntrian =
        (json['no_antrian'] ?? json['fs_kd_antrian'] ?? '').toString().trim();
    final noBooking =
        (json['no_booking'] ?? json['fs_kd_trs'] ?? '').toString().trim();
    final statusPasien =
        int.tryParse(json['status_pasien']?.toString() ?? '0') ?? 0;
    final sedangDilayani = json['sedang_dilayani']?.toString();
    final initialSisa = hitungSisaAntrean(
      nomorAntrean: nomorAntrean,
      sedangDilayani: sedangDilayani,
      fallback: (json['sisaAntrean'] as num?)?.toInt() ?? 0,
    );

    return AntreanAktifModel(
      nomorAntrean: nomorAntrean,
      namaPasien: namaPasien.isNotEmpty ? namaPasien : 'Pasien',
      noRm: noRm.isNotEmpty ? noRm : '01-88-24-90',
      poli: poli.isNotEmpty ? poli : 'Poli Rawat Jalan',
      dokter: dokter.isNotEmpty ? dokter : 'Dokter Spesialis',
      jam: jamText,
      sisaAntrean: initialSisa,
      tanggal: tanggalFormatted.isNotEmpty ? tanggalFormatted : 'Hari Ini',
      gedungLokasi: (json['gedungLokasi'] ?? 'Gedung A • Lt. 2').toString(),
      jenisJaminan: (json['jenisJaminan'] ?? 'Umum / Pribadi').toString(),
      fsKdLayanan: kdLayanan,
      fsKdPetugasMedis: kdPetugasMedis,
      fsKdAntrian: noAntrian,
      noBooking: noBooking,
      rawTanggal: rawTgl,
      statusPasien: statusPasien,
      sedangDilayaniLive: sedangDilayani,
    );
  }

  /// Mengekstrak angka nomor antrean dari string seperti "15", "6", atau "A-014".
  static int? extractQueueNumber(String? raw) {
    if (raw == null) return null;
    final clean = raw.trim();
    if (clean.isEmpty || clean == '-') return null;
    final direct = int.tryParse(clean);
    if (direct != null) return direct;
    final match = RegExp(r'(\d+)$').firstMatch(clean);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Menghitung sisa antrean secara dinamis dari selisih nomor pasien dan nomor sedang dilayani.
  static int hitungSisaAntrean({
    required String nomorAntrean,
    String? sedangDilayani,
    int fallback = 0,
  }) {
    final myNum = extractQueueNumber(nomorAntrean);
    final servingNum = extractQueueNumber(sedangDilayani);
    if (myNum != null && servingNum != null) {
      final diff = myNum - servingNum;
      return diff < 0 ? 0 : diff;
    }
    return fallback < 0 ? 0 : fallback;
  }

  /// Sisa antrean live (dihitung dari `sedangDilayaniLive` jika tersedia).
  int get sisaAntreanLive => hitungSisaAntrean(
        nomorAntrean: nomorAntrean,
        sedangDilayani: sedangDilayaniLive,
        fallback: sisaAntrean,
      );

  /// Menandakan apakah tanggal booking (`rawTanggal` format YYYY-MM-DD) berada di hari mendatang.
  bool get isUpcomingSchedule {
    final clean = rawTanggal.trim();
    if (clean.isEmpty) return false;
    final parsed = DateTime.tryParse(clean);
    if (parsed == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDay = DateTime(parsed.year, parsed.month, parsed.day);
    return bookingDay.isAfter(today);
  }

  /// Menghitung nomor antrean yang sedang dilayani saat ini
  /// Contoh: nomorAntrean="A-014", sisaAntrean=3 → "A-011"
  String get nomorSedangDilayani {
    if (sedangDilayaniLive != null &&
        sedangDilayaniLive!.trim().isNotEmpty &&
        sedangDilayaniLive!.trim() != '-') {
      final clean = sedangDilayaniLive!.trim();
      final match = RegExp(r'^([A-Z])-(\d+)$').firstMatch(nomorAntrean);
      if (match != null) {
        final prefix = match.group(1)!;
        final rawNum = int.tryParse(clean) ?? 0;
        return '$prefix-${rawNum.toString().padLeft(3, '0')}';
      }
      return clean;
    }

    // Jika belum ada data live dari server dan sisaAntrean belum diketahui (0),
    // tampilkan '-' agar tidak menampilkan nomor pasien sendiri sebagai sedang dilayani.
    if (sisaAntrean <= 0) {
      return '-';
    }

    final match = RegExp(r'^([A-Z])-(\d+)$').firstMatch(nomorAntrean);
    if (match != null) {
      final prefix = match.group(1)!;
      final angka = int.tryParse(match.group(2)!) ?? 0;
      final serving = angka - sisaAntrean;
      if (serving < 1) return '$prefix-001';
      return '$prefix-${serving.toString().padLeft(3, '0')}';
    }
    final numOnly = int.tryParse(nomorAntrean);
    if (numOnly != null) {
      final serving = numOnly - sisaAntrean;
      if (serving < 1) return '1';
      return serving.toString();
    }
    return '-';
  }

  /// Menghitung nomor antrean satu sebelum nomor saat ini untuk petunjuk bersiap
  /// Contoh: "A-014" → "A-013"
  String get nomorSebelumnya {
    final match = RegExp(r'^([A-Z])-(\d+)$').firstMatch(nomorAntrean);
    if (match != null) {
      final prefix = match.group(1)!;
      final angka = int.tryParse(match.group(2)!) ?? 0;
      if (angka <= 1) return nomorAntrean;
      return '$prefix-${(angka - 1).toString().padLeft(3, '0')}';
    }
    final numOnly = int.tryParse(nomorAntrean);
    if (numOnly != null) {
      if (numOnly <= 1) return nomorAntrean;
      return (numOnly - 1).toString();
    }
    return nomorAntrean;
  }
}
