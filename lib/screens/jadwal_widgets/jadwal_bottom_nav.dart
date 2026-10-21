import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/profile_screen.dart';
import 'package:pku_gamping_app/screens/queue_blank.dart';
import 'package:pku_gamping_app/screens/pendaftaran_screen.dart';
import 'jadwal_constants.dart';

/// Bottom Navigation Bar khusus halaman Jadwal.
///
/// 5 tab: Beranda | Antrean | Daftar (FAB) | Jadwal (aktif) | Profil
class JadwalBottomNav extends StatelessWidget {
  const JadwalBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kDivider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // 1. Beranda
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isSelected: false,
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              // 2. Antrean
              _NavItem(
                icon: Icons.confirmation_number_outlined,
                label: 'Antrean',
                isSelected: false,
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const QueueBlank(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
              // 3. Daftar (FAB tengah)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const PendaftaranScreen(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -17),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: kPrimaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -17),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            color: kMuted,
                            fontSize: 11,
                            fontFamily: kFontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 4. Jadwal (aktif)
              _NavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Jadwal',
                isSelected: true,
                onTap: () {}, // Sudah di halaman ini
              ),
              // 5. Profil
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                isSelected: false,
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ProfileScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item navigasi tunggal.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? kPrimaryBlue : kMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontFamily: kFontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
