import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/shared_widgets/logout_confirmation_dialog.dart';

/// Tombol Keluar dari Akun (digunakan di ProfileScreen)
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => LogoutConfirmationDialog.show(context),
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
