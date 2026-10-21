import 'package:flutter/material.dart';

/// AppBar untuk halaman Riwayat Resep
class RiwayatResepAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RiwayatResepAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E3A8A), size: 24),
        tooltip: 'Kembali ke Profil',
        onPressed: () => Navigator.maybePop(context),
      ),
      titleSpacing: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('RS PKU GAMPING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB), letterSpacing: 0.6)),
          SizedBox(height: 2),
          Text('Riwayat Resep', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.3)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B), size: 24),
                onPressed: () {},
              ),
              Positioned(
                top: 10, right: 10,
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: const Color(0xFF2563EB), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
