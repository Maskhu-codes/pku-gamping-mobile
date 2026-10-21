import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/jadwal_screen.dart';
import 'package:pku_gamping_app/screens/pendaftaran_screen.dart';
import 'package:pku_gamping_app/screens/profile_screen.dart';
import 'package:pku_gamping_app/screens/queue_blank.dart';
import 'package:pku_gamping_app/screens/queue_screen.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'home_constants.dart';

/// Bottom Navigation Bar beranda dengan 5 tab:
/// Beranda (aktif) | Antrean (dinamis Blank/Aktif) | (+) Daftar | Jadwal | Profil
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    this.selectedIndex = 0,
  });

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E6EE))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // 1. Beranda
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.home_rounded,
                label: 'Beranda',
                isSelected: selectedIndex == 0,
                onTap: () {},
              ),

              // 2. Antrean (Dinamis: Jika ada antrean buka QueueScreen, jika kosong buka QueueBlank)
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.confirmation_number_outlined,
                label: 'Antrean',
                isSelected: selectedIndex == 1,
                onTap: () {
                  final targetScreen = AntreanService.adaAntrean
                      ? const QueueScreen()
                      : const QueueBlank();

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          targetScreen,
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),

              // 3. Tombol Tengah (+) "Daftar"
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
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
                            color: kHomePrimaryBlue,
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
                            color: kHomeMuted,
                            fontSize: 11,
                            fontFamily: kHomeFontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Jadwal
              _buildNavItem(
                context: context,
                index: 3,
                icon: Icons.calendar_month_outlined,
                label: 'Jadwal',
                isSelected: selectedIndex == 3,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const JadwalScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),

              // 5. Profil
              _buildNavItem(
                context: context,
                index: 4,
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                isSelected: selectedIndex == 4,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ProfileScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? kHomePrimaryBlue : kHomeMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
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
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: kHomeFontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
