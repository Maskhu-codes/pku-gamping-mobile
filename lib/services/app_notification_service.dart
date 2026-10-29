import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/models/app_notification_item.dart';
import 'package:pku_gamping_app/widgets/feedback/app_feedback_dialog.dart';
import 'package:pku_gamping_app/widgets/notifications/notification_center_sheet.dart';

/// Layanan terpusat untuk mengelola status, perizinan, dan daftar notifikasi pasien.
class AppNotificationService {
  AppNotificationService._();

  static final ValueNotifier<bool> isEnabledNotifier =
      ValueNotifier<bool>(false);

  static final ValueNotifier<List<AppNotificationItem>> notificationsNotifier =
      ValueNotifier<List<AppNotificationItem>>([]);

  static final ValueNotifier<int> unreadCountNotifier =
      ValueNotifier<int>(0);

  /// Inisialisasi saat aplikasi pertama kali dimuat
  static Future<void> init() async {
    final enabled = SessionManager.isNotificationEnabled;
    isEnabledNotifier.value = enabled;

    // Data simulasi awal notifikasi medis pasien RS PKU Gamping
    notificationsNotifier.value = [
      AppNotificationItem(
        id: 'notif_1',
        title: 'Panggilan Antrean Poli Anak',
        message:
            'Nomor antrean Anda (A-014) tersisa 2 pasien lagi. Silakan bersiap di ruang tunggu Poli Anak Gedung A.',
        time: '5 menit yang lalu',
        category: NotificationCategory.antrean,
        route: AppRoutes.queueDetail,
        isRead: false,
      ),
      AppNotificationItem(
        id: 'notif_2',
        title: 'Hasil Lab Darah Lengkap Selesai',
        message:
            'Hasil pemeriksaan Hematologi Rutin & Glukosa telah divalidasi oleh dr. Ratna, Sp.PK dan siap diunduh.',
        time: '1 jam yang lalu',
        category: NotificationCategory.lab,
        route: AppRoutes.hasilLab,
        isRead: false,
      ),
      AppNotificationItem(
        id: 'notif_3',
        title: 'Resep Obat Sedang Disiapkan',
        message:
            'Resep obat Anda sedang diracik oleh instalasi Farmasi Rawat Jalan. Notifikasi pengambilan akan dikirim setelah selesai.',
        time: '2 jam yang lalu',
        category: NotificationCategory.farmasi,
        route: AppRoutes.riwayatResep,
        isRead: false,
      ),
      AppNotificationItem(
        id: 'notif_4',
        title: 'Pengingat Jadwal Pemeriksaan',
        message:
            'Jadwal pemeriksaan Poli Anak hari ini pukul 13.00 – 16.00 WIB bersama dr. Spesialis Anak.',
        time: 'Pagi ini',
        category: NotificationCategory.jadwal,
        route: AppRoutes.queueDetail,
        isRead: true,
      ),
    ];

    _recalculateUnread();
  }

  /// Hitung ulang jumlah notifikasi yang belum dibaca
  static void _recalculateUnread() {
    if (!isEnabledNotifier.value) {
      unreadCountNotifier.value = 0;
      return;
    }
    unreadCountNotifier.value =
        notificationsNotifier.value.where((n) => !n.isRead).length;
  }

  /// Menangani aksi saat ikon lonceng ditekan:
  /// - Jika BELUM AKTIF: Tampilkan popup perizinan (seperti screenshot)
  /// - Jika SUDAH AKTIF: Tampilkan Pusat Notifikasi (Notification Center)
  static void handleBellTap(BuildContext context) {
    if (!isEnabledNotifier.value) {
      showPermissionDialog(context);
    } else {
      showNotificationCenter(context);
    }
  }

  /// Tampilkan Dialog Permintaan Izin Edukatif (Sebelum Aktif)
  static Future<bool?> showPermissionDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AppFeedbackDialog(
        type: FeedbackDialogType.notificationPermission,
        title: 'Aktifkan Notifikasi',
        message:
            'Dapatkan informasi penting tentang antrean, jadwal, dan layanan kesehatan Anda.',
        confirmText: 'Aktifkan Notifikasi',
        cancelText: 'Nanti saja',
        onConfirm: () async {
          await enableNotifications(context);
        },
      ),
    );
  }

  /// Aktifkan notifikasi
  static Future<void> enableNotifications(BuildContext context) async {
    await SessionManager.setNotificationEnabled(true);
    isEnabledNotifier.value = true;
    _recalculateUnread();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Notifikasi aktif! Anda akan menerima info antrean & hasil lab.',
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Nonaktifkan notifikasi
  static Future<void> disableNotifications(BuildContext context) async {
    await SessionManager.setNotificationEnabled(false);
    isEnabledNotifier.value = false;
    _recalculateUnread();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi dinonaktifkan'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Toggle on/off
  static Future<void> toggleNotifications(BuildContext context, bool value) async {
    if (value) {
      await enableNotifications(context);
    } else {
      await disableNotifications(context);
    }
  }

  /// Tandai satu notifikasi sebagai telah dibaca
  static void markAsRead(String id) {
    final list = List<AppNotificationItem>.from(notificationsNotifier.value);
    final idx = list.indexWhere((n) => n.id == id);
    if (idx != -1) {
      list[idx] = list[idx].copyWith(isRead: true);
      notificationsNotifier.value = list;
      _recalculateUnread();
    }
  }

  /// Tandai semua notifikasi sebagai telah dibaca
  static void markAllAsRead() {
    final list = notificationsNotifier.value
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notificationsNotifier.value = list;
    _recalculateUnread();
  }

  /// Buka Pusat Notifikasi (Setelah Aktif)
  static void showNotificationCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const NotificationCenterSheet(),
    );
  }
}
