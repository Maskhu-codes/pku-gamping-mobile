import 'package:flutter/material.dart';
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
  });

  final List<String> poliList;
  final String selectedPoli;
  final ValueChanged<String> onPoliSelected;

  @override
  Widget build(BuildContext context) {
    final items = ['Semua', ...poliList];

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

          return GestureDetector(
            onTap: () => onPoliSelected(poli),
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
