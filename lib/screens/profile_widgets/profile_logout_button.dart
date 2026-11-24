import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/app_feedback_service.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';

/// Tombol Keluar dari Akun (digunakan di ProfileScreen)
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = SessionManager.isGuestMode;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          if (isGuest) {
            SessionManager.setGuestMode(false);
            Navigator.of(context, rootNavigator: true)
                .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            return;
          }

          AppFeedback.showConfirmation(
            context,
            title: 'Konfirmasi',
            message: 'Yakin keluar akun?',
            confirmText: 'Ya, Keluar',
            cancelText: 'Batal',
            onConfirm: () async {
              await SimrsService.logout();
              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
          );
        },
        icon: Icon(
          Icons.logout_rounded,
          size: 17,
          color: isGuest ? const Color(0xFF475569) : const Color(0xFFB91C1C),
        ),
        label: Text(
          isGuest ? 'Keluar dari Mode Tamu' : 'Keluar dari Akun',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isGuest ? const Color(0xFF475569) : const Color(0xFFB91C1C),
            letterSpacing: 0.2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF1F5F9)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
