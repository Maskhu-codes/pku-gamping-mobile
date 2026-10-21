import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'jadwal_constants.dart';

/// Horizontal scrollable date strip — menampilkan 7 hari ke depan.
///
/// Pengguna mengetuk tanggal tertentu untuk melihat jadwal dokter di hari itu.
class JadwalDateStrip extends StatelessWidget {
  const JadwalDateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  /// Menghasilkan daftar 7 hari mulai dari hari ini.
  List<DateTime> get _dates {
    final today = DateTime.now();
    return List.generate(7, (i) => DateTime(today.year, today.month, today.day + i));
  }

  @override
  Widget build(BuildContext context) {
    final dates = _dates;
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, selectedDate);
          return _DateChip(
            date: date,
            isSelected: isSelected,
            isToday: _isSameDay(date, DateTime.now()),
            onTap: () => onDateSelected(date),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Chip tunggal untuk satu tanggal di dalam date strip.
class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dayName = isToday
        ? 'Hari Ini'
        : DateFormat('EEEE', 'id_ID').format(date);
    final dateLabel = DateFormat('d MMM', 'id_ID').format(date);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? null : Border.all(color: kCardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white70 : kMuted,
                fontFamily: kFontFamily,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              dateLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : kInk,
                fontFamily: kFontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
