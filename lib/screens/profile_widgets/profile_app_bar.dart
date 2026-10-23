import 'package:flutter/material.dart';
import 'package:pku_gamping_app/widgets/hospital_brand_header.dart';

/// AppBar Halaman Profil — Logo RS PKU Gamping + Notifikasi
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      child: HospitalBrandHeader(showBorder: false),
    );
  }
}
