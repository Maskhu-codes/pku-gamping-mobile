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
  });

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
      );

  /// Menghitung nomor antrean yang sedang dilayani saat ini
  /// Contoh: nomorAntrean="A-014", sisaAntrean=3 → "A-011"
  String get nomorSedangDilayani {
    final match = RegExp(r'^([A-Z])-(\d+)$').firstMatch(nomorAntrean);
    if (match == null) return '-';
    final prefix = match.group(1)!;
    final angka = int.tryParse(match.group(2)!) ?? 0;
    final serving = angka - sisaAntrean;
    if (serving < 1) return '$prefix-001';
    return '$prefix-${serving.toString().padLeft(3, '0')}';
  }

  /// Menghitung nomor antrean satu sebelum nomor saat ini untuk petunjuk bersiap
  /// Contoh: "A-014" → "A-013"
  String get nomorSebelumnya {
    final match = RegExp(r'^([A-Z])-(\d+)$').firstMatch(nomorAntrean);
    if (match == null) return nomorAntrean;
    final prefix = match.group(1)!;
    final angka = int.tryParse(match.group(2)!) ?? 0;
    if (angka <= 1) return nomorAntrean;
    return '$prefix-${(angka - 1).toString().padLeft(3, '0')}';
  }
}
