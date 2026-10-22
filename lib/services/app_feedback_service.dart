import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/widgets/feedback/app_feedback_dialog.dart';

/// Service Helper Terpusat untuk memanggil 7 UI State Popups RS PKU Gamping
/// Mendukung pemanggilan berbasis [BuildContext] maupun Global via [navigatorKey].
class AppFeedback {
  AppFeedback._();

  /// Kunci navigator global agar dialog dapat dipicu dari interceptor jaringan
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get _currentContext =>
      navigatorKey.currentContext;

  /// 1. Tampilkan Pop-up Konfirmasi
  static Future<bool?> showConfirmation(
    BuildContext context, {
    String? title,
    String? message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppFeedbackDialog(
        type: FeedbackDialogType.confirmation,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  /// 2. Tampilkan Pop-up Memuat (Loading)
  static void showLoading(
    BuildContext context, {
    String? title,
    String? message,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false,
        child: AppFeedbackDialog(
          type: FeedbackDialogType.loading,
          title: title,
          message: message,
        ),
      ),
    );
  }

  /// Tutup Pop-up Memuat (Loading)
  static void dismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  /// 3. Tampilkan Pop-up Izin Notifikasi
  static Future<bool?> showNotificationPermission(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onAllow,
    VoidCallback? onLater,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppFeedbackDialog(
        type: FeedbackDialogType.notificationPermission,
        title: title,
        message: message,
        onConfirm: onAllow,
        onCancel: onLater,
      ),
    );
  }

  /// 4. Tampilkan Pop-up Sesi Berakhir (Session Expired)
  static Future<void> showSessionExpired({
    BuildContext? context,
    VoidCallback? onLogin,
  }) async {
    final ctx = context ?? _currentContext;
    if (ctx == null) return;

    await showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AppFeedbackDialog(
          type: FeedbackDialogType.sessionExpired,
          onConfirm: () async {
            await SessionManager.clearSession();
            onLogin?.call();
            final targetContext = context ?? _currentContext;
            if (targetContext != null && targetContext.mounted) {
              Navigator.of(targetContext, rootNavigator: true)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
            }
          },
        ),
      ),
    );
  }

  /// 5. Tampilkan Pop-up Terjadi Kesalahan (Error State)
  static Future<bool?> showError(
    BuildContext context, {
    String? title,
    String? message,
    String? confirmText,
    VoidCallback? onRetry,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppFeedbackDialog(
        type: FeedbackDialogType.error,
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onRetry,
      ),
    );
  }

  /// 6. Tampilkan Pop-up Tidak Ada Koneksi Internet (No Internet)
  static Future<bool?> showNoInternet({
    BuildContext? context,
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    final ctx = context ?? _currentContext;
    if (ctx == null) return Future.value(null);

    return showDialog<bool>(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => AppFeedbackDialog(
        type: FeedbackDialogType.noInternet,
        title: title,
        message: message,
        onConfirm: onRetry,
      ),
    );
  }

  /// 7. Tampilkan Pop-up Berhasil (Success)
  static Future<bool?> showSuccess(
    BuildContext context, {
    String? title,
    String? message,
    String? confirmText,
    VoidCallback? onDone,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppFeedbackDialog(
        type: FeedbackDialogType.success,
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onDone,
      ),
    );
  }
}
