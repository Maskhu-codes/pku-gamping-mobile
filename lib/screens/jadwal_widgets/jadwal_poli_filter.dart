import 'package:flutter/material.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';
import 'jadwal_constants.dart';

/// Horizontal scrollable filter chips untuk memilih poli/spesialisasi.
///
/// Chip pertama selalu "Semua" (menampilkan semua dokter).
class JadwalPoliFilter extends StatelessWidget {
  const JadwalPoliFilter({
    super.key,
    required this.poliList,
    required this.selectedPoli,
    required this.onPoliSelected,
    this.includeAllOption = true,
  });

  final List<String> poliList;
  final String selectedPoli;
  final ValueChanged<String> onPoliSelected;
  final bool includeAllOption;

  @override
  Widget build(BuildContext context) {
    final items = includeAllOption ? ['Semua', ...poliList] : poliList;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final poli = items[index];
          final isSelected = poli == selectedPoli;

          return PressableScale(
            onTap: () => onPoliSelected(poli),
            pressedScale: 0.96,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kInk : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: kCardBorder),
              ),
              child: Text(
                poli,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : kInk,
                  fontFamily: kFontFamily,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
