/// Model Data Antrean Farmasi / Apotek RS PKU Muhammadiyah Gamping.
///
/// Memisahkan nomor antrean obat racik (kode antrean B & D)
/// dan obat non-racik (kode antrean A & C) dari endpoint `GET /farmasi/antrean`.
class AntreanFarmasiModel {
  final List<String> racik;
  final List<String> nonRacik;

  const AntreanFarmasiModel({
    this.racik = const [],
    this.nonRacik = const [],
  });

  factory AntreanFarmasiModel.fromJson(Map<String, dynamic> json) {
    List<String> parseUniqueList(dynamic raw) {
      if (raw is! List) return const [];
      final seen = <String>{};
      final result = <String>[];
      for (final entry in raw) {
        if (entry == null) continue;
        final value = entry.toString().trim();
        if (value.isNotEmpty && seen.add(value)) {
          result.add(value);
        }
      }
      return result;
    }

    return AntreanFarmasiModel(
      racik: parseUniqueList(json['racik']),
      nonRacik: parseUniqueList(json['non_racik']),
    );
  }

  Map<String, dynamic> toJson() => {
        'racik': racik,
        'non_racik': nonRacik,
      };

  bool get isEmpty => racik.isEmpty && nonRacik.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

