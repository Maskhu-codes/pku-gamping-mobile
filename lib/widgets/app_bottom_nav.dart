import 'package:flutter/material.dart';

const Color _navPrimaryBlue = Color(0xFF0D4FC1);
const Color _navMuted = Color(0xFF91A3BE);
const Color _navBorder = Color(0xFFE1E6EE);

/// Unified Bottom Navigation Bar untuk RS PKU Muhammadiyah Gamping.
///
/// Menyediakan 5 slot interaksi:
/// 1. Beranda (index 0)
/// 2. Antrean (index 1)
/// 3. (+) Daftar (Tombol Action tengah)
/// 4. Jadwal (index 3)
/// 5. Profil (index 4)
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onDaftarPressed,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onDaftarPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _navBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // 1. Beranda
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Beranda',
                isSelected: selectedIndex == 0,
                onTap: () => onItemSelected(0),
              ),

              // 2. Antrean
              _buildNavItem(
                index: 1,
                icon: Icons.confirmation_number_outlined,
                label: 'Antrean',
                isSelected: selectedIndex == 1,
                onTap: () => onItemSelected(1),
              ),

              // 3. Tombol Tengah (+) "Daftar"
              Expanded(
                child: GestureDetector(
                  onTap: onDaftarPressed,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -17),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: _navPrimaryBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x330D4FC1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
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
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _navPrimaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Jadwal
              _buildNavItem(
                index: 3,
                icon: Icons.calendar_month_outlined,
                label: 'Jadwal',
                isSelected: selectedIndex == 3,
                onTap: () => onItemSelected(3),
              ),

              // 5. Profil
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                isSelected: selectedIndex == 4,
                onTap: () => onItemSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? _navPrimaryBlue : _navMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: _navPrimaryBlue.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
