/// Model Data Hasil Pemeriksaan Penunjang (Laboratorium & Radiologi)
class LabResult {
  const LabResult({
    required this.title,
    required this.date,
    required this.time,
  });

  final String title;
  final String date;
  final String time;

  factory LabResult.fromJson(Map<String, dynamic> json) => LabResult(
        title: json['title'] as String? ?? '',
        date: json['date'] as String? ?? '',
        time: json['time'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date,
        'time': time,
      };
}

class RadiologyResult {
  const RadiologyResult({
    required this.title,
    required this.date,
    required this.time,
  });

  final String title;
  final String date;
  final String time;

  factory RadiologyResult.fromJson(Map<String, dynamic> json) => RadiologyResult(
        title: json['title'] as String? ?? '',
        date: json['date'] as String? ?? '',
        time: json['time'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date,
        'time': time,
      };
}
