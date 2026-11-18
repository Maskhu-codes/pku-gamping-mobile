/// Model Data Hasil Pemeriksaan Penunjang (Laboratorium & Radiologi)
class LabResult {
  const LabResult({
    required this.title,
    required this.date,
    required this.time,
    this.kdTrs = '',
    this.rawDate = '',
    this.details = const [],
  });

  final String title;
  final String date;
  final String time;
  final String kdTrs;
  final String rawDate;
  final List<LabParameterDetail> details;

  static String _formatTanggal(String raw) {
    if (raw.isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw);
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
        'Desember',
      ];
      return '${parsed.day} ${bulan[parsed.month]} ${parsed.year}';
    } catch (_) {
      return raw;
    }
  }

  factory LabResult.fromJson(Map<String, dynamic> json) {
    final kdTrs =
        (json['FS_KD_TRS'] ?? json['kd_trs'] ?? json['id'] ?? '').toString().trim();
    final rawDate =
        (json['FD_TGL_TRS'] ?? json['date'] ?? json['tanggal'] ?? '').toString().trim();
    final rawTime =
        (json['FS_JAM_TRS'] ?? json['time'] ?? json['jam'] ?? '').toString().trim();
    final formattedDate = _formatTanggal(rawDate);
    final title = (json['title'] ??
            (kdTrs.isNotEmpty
                ? 'Pemeriksaan Lab #$kdTrs'
                : 'Pemeriksaan Laboratorium'))
        .toString()
        .trim();

    return LabResult(
      kdTrs: kdTrs,
      title: title,
      date: formattedDate.isNotEmpty ? formattedDate : rawDate,
      time: rawTime.isNotEmpty ? rawTime : '',
      rawDate: rawDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date,
        'time': time,
        'FS_KD_TRS': kdTrs,
        'FD_TGL_TRS': rawDate,
        'FS_JAM_TRS': time,
      };
}

/// Model Parameter Rincian Hasil Laboratorium (`GET /penunjang/laboratorium_detail`).
class LabParameterDetail {
  final String pemeriksaan;
  final String hasil;
  final String satuan;
  final String nilaiRujukan;
  final String flag; // 'H', 'L', 'N'

  const LabParameterDetail({
    required this.pemeriksaan,
    required this.hasil,
    required this.satuan,
    required this.nilaiRujukan,
    this.flag = 'N',
  });

  factory LabParameterDetail.fromJson(Map<String, dynamic> json) {
    final flagVal = (json['flag'] ?? json['FS_FLAG_HASIL'] ?? 'N')
        .toString()
        .trim()
        .toUpperCase();
    return LabParameterDetail(
      pemeriksaan:
          (json['pemeriksaan'] ?? json['fs_nm_jenis_pemeriksaan'] ?? '')
              .toString()
              .trim(),
      hasil: (json['hasil'] ?? json['FS_HASIL'] ?? '').toString().trim(),
      satuan: (json['satuan'] ?? json['FS_SATUAN'] ?? '').toString().trim(),
      nilaiRujukan:
          (json['nilai_rujukan'] ?? json['FS_NILAI_RUJUKAN'] ?? '')
              .toString()
              .trim(),
      flag: flagVal.isNotEmpty ? flagVal : 'N',
    );
  }

  Map<String, dynamic> toJson() => {
        'pemeriksaan': pemeriksaan,
        'hasil': hasil,
        'satuan': satuan,
        'nilai_rujukan': nilaiRujukan,
        'flag': flag,
      };

  bool get isHigh => flag == 'H';
  bool get isLow => flag == 'L';
  bool get isNormal => flag == 'N' || flag.isEmpty;
}

/// Model Data Hasil Pemeriksaan Radiologi SIMRS (`GET /penunjang/radiologi`).
class RadiologyResult {
  const RadiologyResult({
    required this.title,
    required this.date,
    required this.time,
    this.kdTrs = '',
    this.rawDate = '',
    this.keterangan = '',
    this.urlFoto = '',
  });

  final String title;
  final String date;
  final String time;
  final String kdTrs;
  final String rawDate;
  final String keterangan;
  final String urlFoto;

  String get namaTindakan => title;
  String get linkFoto => urlFoto;
  bool get hasFoto => urlFoto.trim().isNotEmpty;

  static String _formatTanggal(String raw) {
    if (raw.isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw);
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
        'Desember',
      ];
      return '${parsed.day} ${bulan[parsed.month]} ${parsed.year}';
    } catch (_) {
      return raw;
    }
  }

  factory RadiologyResult.fromJson(Map<String, dynamic> json) {
    final kdTrs = (json['fs_kd_trs'] ?? json['kd_trs'] ?? json['id'] ?? '')
        .toString()
        .trim();
    final rawDate = (json['fd_tgl_trs'] ?? json['date'] ?? json['tanggal'] ?? '')
        .toString()
        .trim();
    final rawTime = (json['fs_jam_keterangan'] ?? json['time'] ?? json['jam'] ?? '')
        .toString()
        .trim();
    final formattedDate = _formatTanggal(rawDate);
    final title = (json['FS_NM_TARIF'] ??
            json['nama_tindakan'] ??
            json['title'] ??
            (kdTrs.isNotEmpty
                ? 'Pemeriksaan Radiologi #$kdTrs'
                : 'Pemeriksaan Radiologi'))
        .toString()
        .trim();
    final keterangan = (json['fs_keterangan'] ??
            json['FS_KETERANGAN2HASIL_RAD'] ??
            json['keterangan'] ??
            '')
        .toString()
        .trim();
    final urlFoto = (json['urllink1'] ?? json['url_foto'] ?? json['link_foto'] ?? '')
        .toString()
        .trim();

    return RadiologyResult(
      title: title,
      date: formattedDate.isNotEmpty ? formattedDate : rawDate,
      time: rawTime,
      kdTrs: kdTrs,
      rawDate: rawDate,
      keterangan: keterangan,
      urlFoto: urlFoto,
    );
  }

  Map<String, dynamic> toJson() => {
        'fs_kd_trs': kdTrs,
        'fd_tgl_trs': rawDate,
        'fs_jam_keterangan': time,
        'FS_NM_TARIF': title,
        'fs_keterangan': keterangan,
        'urllink1': urlFoto,
        'title': title,
        'date': date,
        'time': time,
      };
}
