import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';
import 'package:pku_gamping_app/services/app_feedback_service.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';

/// Tombol Keluar dari Akun (digunakan di ProfileScreen)
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
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
        icon: const Icon(
          Icons.logout_rounded,
          size: 18,
          color: Color(0xFFDC2626),
        ),
        label: const Text(
          'Keluar dari Akun',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFDC2626),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFECACA)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFFFFF5F5),
        ),
      ),
    );
  }
}
