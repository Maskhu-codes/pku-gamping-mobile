
class DokterModel {
  final String kodeDokter;
  final String namaDokter;
  final String namaAlias;
  final String kodeLayanan;
  final String namaLayanan;

  const DokterModel({
    required this.kodeDokter,
    required this.namaDokter,
    required this.namaAlias,
    required this.kodeLayanan,
    required this.namaLayanan,
  });

  factory DokterModel.fromJson(Map<String, dynamic> json) {
    return DokterModel(
      kodeDokter: json['fs_kd_peg']?.toString() ?? '',
      namaDokter: json['fs_nm_peg']?.toString() ?? '',
      namaAlias: json['fs_nm_alias']?.toString() ?? '',
      kodeLayanan: json['fs_kd_layanan']?.toString() ?? '',
      namaLayanan: json['fs_nm_layanan']?.toString() ?? '',
    );
  }
}
