import 'package:flutter/material.dart';
import 'home_constants.dart';

/// Header Brand Bar RS PKU Gamping dengan gradient dan tombol notifikasi.
class HomeBrandHeader extends StatelessWidget {
  const HomeBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4F7FC), Color(0xFFD2DEF2)],
        ),
      ),
      child: Row(
        children: [
          // Logo RS PKU Gamping
          Image.asset(
            'assets/images/logo_pkugamping.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/logo.png',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F9D58),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'PKU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),

          // Teks Brand
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RS PKU Gamping',
                  style: TextStyle(
                    color: kHomeInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: kHomeFontFamily,
                  ),
                ),
                Text(
                  'Portal Pasien',
                  style: TextStyle(
                    color: kHomeMuted,
                    fontSize: 12,
                    fontFamily: kHomeFontFamily,
                  ),
                ),
              ],
            ),
          ),

          // Lonceng Notifikasi dengan Unread Dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tidak ada notifikasi baru.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Notifikasi',
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF43516A),
                  size: 25,
                ),
              ),
              Positioned(
                right: 5,
                top: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2866E8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
