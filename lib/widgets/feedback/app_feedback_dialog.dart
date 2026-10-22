import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Jenis UI State Popup sesuai 7 referensi desain RS PKU Gamping
enum FeedbackDialogType {
  confirmation,
  loading,
  notificationPermission,
  sessionExpired,
  error,
  noInternet,
  success,
}

/// Dialog Pop-up Terpadu untuk 7 UI State RS PKU Gamping:
/// 1. Konfirmasi (Confirmation)
/// 2. Memuat (Loading)
/// 3. Aktifkan Notifikasi (Notification Permission)
/// 4. Sesi Berakhir (Session Expired)
/// 5. Terjadi Kesalahan (Error State)
/// 6. Tidak Ada Koneksi Internet (No Internet Connection)
/// 7. Berhasil (Success)
class AppFeedbackDialog extends StatelessWidget {
  const AppFeedbackDialog({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  final FeedbackDialogType type;
  final String? title;
  final String? message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon Container
              _buildIconContainer(),
              const SizedBox(height: 18),

              // 2. Judul
              Text(
                _resolveTitle(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Deskripsi / Subteks
              Text(
                _resolveMessage(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Tombol Aksi
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun ikon melingkar sesuai tipe status
  Widget _buildIconContainer() {
    switch (type) {
      case FeedbackDialogType.confirmation:
        return _IconCircle(
          backgroundColor: const Color(0xFFEBF3FF),
          child: const Icon(
            Icons.help_outline_rounded,
            size: 34,
            color: AppColors.primary,
          ),
        );

      case FeedbackDialogType.loading:
        return const SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );

      case FeedbackDialogType.notificationPermission:
        return _IconCircle(
          backgroundColor: const Color(0xFFEBF3FF),
          child: const Icon(
            Icons.notifications_rounded,
            size: 34,
            color: AppColors.primary,
          ),
        );

      case FeedbackDialogType.sessionExpired:
        return _IconCircle(
          backgroundColor: const Color(0xFFEBF3FF),
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 34,
            color: AppColors.primary,
          ),
        );

      case FeedbackDialogType.error:
        return _IconCircle(
          backgroundColor: const Color(0xFFFEE2E2),
          child: const Icon(
            Icons.error_outline_rounded,
            size: 34,
            color: Color(0xFFDC2626),
          ),
        );

      case FeedbackDialogType.noInternet:
        return _IconCircle(
          backgroundColor: const Color(0xFFFEF3C7),
          child: const Icon(
            Icons.wifi_off_rounded,
            size: 32,
            color: Color(0xFF78350F),
          ),
        );

      case FeedbackDialogType.success:
        return _IconCircle(
          backgroundColor: const Color(0xFFDCFCE7),
          child: const Icon(
            Icons.check_rounded,
            size: 34,
            color: Color(0xFF16A34A),
          ),
        );
    }
  }

  String _resolveTitle() {
    if (title != null && title!.isNotEmpty) return title!;
    switch (type) {
      case FeedbackDialogType.confirmation:
        return 'Konfirmasi';
      case FeedbackDialogType.loading:
        return 'Memuat...';
      case FeedbackDialogType.notificationPermission:
        return 'Aktifkan Notifikasi';
      case FeedbackDialogType.sessionExpired:
        return 'Sesi Berakhir';
      case FeedbackDialogType.error:
        return 'Terjadi Kesalahan';
      case FeedbackDialogType.noInternet:
        return 'Tidak Ada Koneksi Internet';
      case FeedbackDialogType.success:
        return 'Berhasil';
    }
  }

  String _resolveMessage() {
    if (message != null && message!.isNotEmpty) return message!;
    switch (type) {
      case FeedbackDialogType.confirmation:
        return 'Apakah Anda yakin ingin melanjutkan tindakan ini?';
      case FeedbackDialogType.loading:
        return 'Mohon tunggu sebentar.';
      case FeedbackDialogType.notificationPermission:
        return 'Dapatkan informasi penting tentang antrean, jadwal, dan layanan kesehatan Anda.';
      case FeedbackDialogType.sessionExpired:
        return 'Sesi Anda telah berakhir. Silakan masuk kembali untuk melanjutkan.';
      case FeedbackDialogType.error:
        return 'Kami tidak dapat memproses permintaan. Silakan coba lagi.';
      case FeedbackDialogType.noInternet:
        return 'Periksa koneksi internet Anda lalu coba lagi.';
      case FeedbackDialogType.success:
        return 'Permintaan Anda berhasil diproses.';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (type) {
      // 1. Konfirmasi: 2 Tombol Berdampingan (Batal & Lanjutkan)
      case FeedbackDialogType.confirmation:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(false);
                    onCancel?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF475569),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    cancelText ?? 'Batal',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(true);
                    onConfirm?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    confirmText ?? 'Lanjutkan',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      // 2. Loading: Tidak memiliki tombol aksi
      case FeedbackDialogType.loading:
        return const SizedBox.shrink();

      // 3. Notifikasi: Tombol Solid Vertikal + TextButton "Nanti saja"
      case FeedbackDialogType.notificationPermission:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                  onConfirm?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  confirmText ?? 'Aktifkan Notifikasi',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(false);
                onCancel?.call();
              },
              child: Text(
                cancelText ?? 'Nanti saja',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        );

      // 4. Sesi Berakhir: Tombol "Masuk Kembali"
      case FeedbackDialogType.sessionExpired:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
              onConfirm?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              confirmText ?? 'Masuk Kembali',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      // 5. Error: Tombol "Coba Lagi"
      case FeedbackDialogType.error:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
              onConfirm?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              confirmText ?? 'Coba Lagi',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      // 6. Tidak Ada Internet: Tombol "Coba Lagi" dengan Ikon Refresh
      case FeedbackDialogType.noInternet:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
              onConfirm?.call();
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              confirmText ?? 'Coba Lagi',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        );

      // 7. Berhasil: Tombol "Selesai"
      case FeedbackDialogType.success:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
              onConfirm?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              confirmText ?? 'Selesai',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
    }
  }
}

/// Lingkaran Ikon Berlatar Warna Pastel
class _IconCircle extends StatelessWidget {
  const _IconCircle({
    required this.backgroundColor,
    required this.child,
  });

  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }
}
