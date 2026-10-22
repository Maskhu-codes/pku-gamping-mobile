/// Model Data Riwayat Pemeriksaan Pasien
class RiwayatPemeriksaan {
  const RiwayatPemeriksaan({
    required this.tanggal,
    required this.namaPemeriksaan,
    required this.poli,
    required this.dokter,
  });

  final String tanggal;
  final String namaPemeriksaan;
  final String poli;
  final String dokter;

  factory RiwayatPemeriksaan.fromJson(Map<String, dynamic> json) =>
      RiwayatPemeriksaan(
        tanggal: json['tanggal'] as String? ?? '',
        namaPemeriksaan: json['namaPemeriksaan'] as String? ?? '',
        poli: json['poli'] as String? ?? '',
        dokter: json['dokter'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'tanggal': tanggal,
        'namaPemeriksaan': namaPemeriksaan,
        'poli': poli,
        'dokter': dokter,
      };
}
