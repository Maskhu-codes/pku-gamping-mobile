
class StatusAntreanModel {
  final String sedangDilayani;
  final int statusPasien;

  const StatusAntreanModel({
    required this.sedangDilayani,
    required this.statusPasien,
  });

  factory StatusAntreanModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StatusAntreanModel(
      sedangDilayani:
          json['sedang_dilayani']?.toString() ?? '-',
      statusPasien:
          int.tryParse(json['status_pasien']?.toString() ?? '') ?? 0,
    );
  }

  String get keteranganStatus {
    switch (statusPasien) {
      case 0:
        return 'Belum Terdaftar';
      case 1:
        return 'Terdaftar - Menuju Triage';
      case 2:
        return 'Selesai Triage - Menunggu Poli';
      case 3:
        return 'Tercatat di Pelayanan Medis';
      default:
        return 'Status Tidak Diketahui';
    }
  }
}
