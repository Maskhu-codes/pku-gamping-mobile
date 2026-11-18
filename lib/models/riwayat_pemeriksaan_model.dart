/// Model Data Riwayat Pemeriksaan Pasien RS PKU Muhammadiyah Gamping.
class RiwayatPemeriksaan {
  const RiwayatPemeriksaan({
    required this.tanggal,
    required this.namaPemeriksaan,
    required this.poli,
    required this.dokter,
    this.kdReg = '',
    this.terapi = '',
    this.rawTanggal = '',
  });

  final String tanggal;
  final String namaPemeriksaan;
  final String poli;
  final String dokter;
  final String kdReg;
  final String terapi;
  final String rawTanggal;

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

  factory RiwayatPemeriksaan.fromJson(Map<String, dynamic> json) {
    final rawDate =
        (json['FD_TGL_MASUK'] ?? json['tanggal'] ?? '').toString().trim();
    final formattedDate = _formatTanggal(rawDate);

    final poli =
        (json['poli'] ?? json['FS_NM_LAYANAN'] ?? '').toString().trim();
    final dokter =
        (json['dokter'] ?? json['FS_NM_PEG'] ?? '').toString().trim();
    final kdReg =
        (json['FS_KD_REG'] ?? json['kd_reg'] ?? '').toString().trim();
    final terapi =
        (json['FS_TERAPI'] ?? json['terapi'] ?? '').toString().trim();
    final nama = (json['namaPemeriksaan'] ??
            (poli.isNotEmpty
                ? 'Pemeriksaan $poli'
                : 'Pemeriksaan Rawat Jalan'))
        .toString()
        .trim();

    return RiwayatPemeriksaan(
      tanggal: formattedDate.isNotEmpty ? formattedDate : rawDate,
      namaPemeriksaan: nama,
      poli: poli,
      dokter: dokter,
      kdReg: kdReg,
      terapi: terapi,
      rawTanggal: rawDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'tanggal': tanggal,
        'namaPemeriksaan': namaPemeriksaan,
        'poli': poli,
        'dokter': dokter,
        'FS_KD_REG': kdReg,
        'FS_TERAPI': terapi,
        'FD_TGL_MASUK': rawTanggal,
      };
}

/// Model Paginasi Riwayat Pemeriksaan / Kunjungan Pasien (`GET /riwayat/list`).
class RiwayatPaginationModel {
  final List<RiwayatPemeriksaan> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNext;

  const RiwayatPaginationModel({
    this.items = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.hasNext = false,
  });

  factory RiwayatPaginationModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    final items = rawList
        .map((e) => RiwayatPemeriksaan.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();

    final pagination = json['pagination'] is Map<String, dynamic>
        ? json['pagination'] as Map<String, dynamic>
        : <String, dynamic>{};

    final currentPage =
        int.tryParse(pagination['current_page']?.toString() ?? '1') ?? 1;
    final totalPages =
        int.tryParse(pagination['total_pages']?.toString() ?? '1') ?? 1;
    final totalItems =
        int.tryParse(pagination['total_items']?.toString() ?? '0') ??
            items.length;
    final hasNext = pagination['has_next'] == true || (currentPage < totalPages);

    return RiwayatPaginationModel(
      items: items,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      hasNext: hasNext,
    );
  }
}
