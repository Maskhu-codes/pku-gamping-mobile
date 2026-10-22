/// Model Data Pasien RS PKU Muhammadiyah Gamping
class PasienModel {
  final String id;
  final String nama;
  final String noRm;
  final String nik;
  final String tanggalLahir;
  final bool isTerhubung;
  final String hubungan; // misal: "Diri Sendiri", "Istri", "Anak"

  const PasienModel({
    required this.id,
    required this.nama,
    required this.noRm,
    required this.nik,
    required this.tanggalLahir,
    this.isTerhubung = true,
    this.hubungan = 'Diri Sendiri',
  });

  String get inisial {
    final parts = nama.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'PS';
  }

  factory PasienModel.fromJson(Map<String, dynamic> json) => PasienModel(
        id: json['id'] as String? ?? '',
        nama: json['nama'] as String? ?? '',
        noRm: json['noRm'] as String? ?? json['no_rm'] as String? ?? '',
        nik: json['nik'] as String? ?? '',
        tanggalLahir: json['tanggalLahir'] as String? ??
            json['tanggal_lahir'] as String? ??
            '',
        isTerhubung: json['isTerhubung'] as bool? ?? true,
        hubungan: json['hubungan'] as String? ?? 'Diri Sendiri',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'noRm': noRm,
        'nik': nik,
        'tanggalLahir': tanggalLahir,
        'isTerhubung': isTerhubung,
        'hubungan': hubungan,
      };
}
