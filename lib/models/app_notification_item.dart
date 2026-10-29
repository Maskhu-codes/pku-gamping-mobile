/// Kategori notifikasi medis & layanan pasien RS PKU Gamping
enum NotificationCategory {
  antrean,
  lab,
  farmasi,
  jadwal,
  info,
}

/// Model item notifikasi pasien
class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationCategory category;
  final String? route;
  final dynamic routeArguments;
  bool isRead;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    this.route,
    this.routeArguments,
    this.isRead = false,
  });

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    NotificationCategory? category,
    String? route,
    dynamic routeArguments,
    bool? isRead,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      category: category ?? this.category,
      route: route ?? this.route,
      routeArguments: routeArguments ?? this.routeArguments,
      isRead: isRead ?? this.isRead,
    );
  }
}
