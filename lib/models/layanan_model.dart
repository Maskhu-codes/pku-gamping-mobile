
class LayananModel {
  final String kodeLayanan;
  final String namaLayanan;

  const LayananModel({
    required this.kodeLayanan,
    required this.namaLayanan,
  });

  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel(
      kodeLayanan: json['fs_kd_layanan']?.toString() ?? '',
      namaLayanan: json['fs_nm_layanan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fs_kd_layanan': kodeLayanan,
      'fs_nm_layanan': namaLayanan,
    };
  }
}
