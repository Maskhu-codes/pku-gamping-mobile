
class StatusAntreanModel {
  final int sedangDilayani;
  final int statusPasien;

  const StatusAntreanModel({
    required this.sedangDilayani,
    required this.statusPasien,
  });

  factory StatusAntreanModel.fromJson(
    Map<String, dynamic> json,
  ) {
    int bacaAngka(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return StatusAntreanModel(
      sedangDilayani: bacaAngka(json['sedang_dilayani']),
      statusPasien: bacaAngka(json['status_pasien']),
    );
  }

  String get keteranganStatus {
    switch (statusPasien) {
      case 0:
        return 'Belum Terdaftar';
      case 1:
        return 'Terdaftar - Menuju Triase';
      case 2:
        return 'Selesai Triase - Menunggu Poli';
      case 3:
        return 'Selesai Poli - Menuju Farmasi';
      default:
        return 'Status Tidak Diketahui';
    }
  }
}
