import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/queue_screen.dart';

const _primaryBlue = Color(0xFF0D4FC1);
const _muted = Color(0xFF91A3BE);

/// Bottom Navigation Bar 5-Tab untuk halaman Profil
/// Profil (index 4) selalu aktif; tab lain akan navigasi kembali ke Beranda atau Antrean
class ProfileBottomNav extends StatelessWidget {
  const ProfileBottomNav({super.key});

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
                          const QueueScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
              // 3. Daftar (Center Action)
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -17),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: _primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 27),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -17),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(color: _muted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 4. Jadwal
              _NavItem(
                icon: Icons.calendar_month_outlined,
                label: 'Jadwal',
                isSelected: false,
                onTap: () => Navigator.maybePop(context),
              ),
              // 5. Profil (aktif)
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                isSelected: true,
                onTap: () {}, // sudah di halaman ini
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _primaryBlue : _muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
