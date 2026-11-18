import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';
import 'pendaftaran_constants.dart';

enum _DayScheduleStatus {
  available,
  full,
  closed,
}

class _DayScheduleInfo {
  const _DayScheduleInfo({
    required this.isoDate,
    required this.status,
    required this.hariTanggal,
  });

  final String isoDate;
  final _DayScheduleStatus status;
  final String hariTanggal;
}

/// Bottom Sheet Kalender Bulanan custom yang bersih, tenang, dan medis
/// untuk memilih tanggal kunjungan dokter dari rentang jadwal 45 hari SIMRS.
class PendaftaranDatePickerSheet extends StatefulWidget {
  const PendaftaranDatePickerSheet({
    super.key,
    required this.slots,
    required this.selectedDateIso,
    required this.onDateSelected,
  });

  final List<JadwalSlotModel> slots;
  final String? selectedDateIso;
  final ValueChanged<String> onDateSelected;

  static Future<void> show({
    required BuildContext context,
    required List<JadwalSlotModel> slots,
    required String? selectedDateIso,
    required ValueChanged<String> onDateSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PendaftaranDatePickerSheet(
        slots: slots,
        selectedDateIso: selectedDateIso,
        onDateSelected: onDateSelected,
      ),
    );
  }

  @override
  State<PendaftaranDatePickerSheet> createState() =>
      _PendaftaranDatePickerSheetState();
}

class _PendaftaranDatePickerSheetState
    extends State<PendaftaranDatePickerSheet> {
  static const _monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const _weekdayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  late final Map<String, _DayScheduleInfo> _dayMap;
  late final DateTime _minMonth;
  late final DateTime _maxMonth;
  late DateTime _visibleMonth;
  String? _unavailableNotice;

  @override
  void initState() {
    super.initState();
    _dayMap = _buildDayMap(widget.slots);

    final parsedDates = _dayMap.keys
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .toList()
      ..sort();

    final now = DateTime.now();
    final fallbackMonth = DateTime(now.year, now.month);
    _minMonth = parsedDates.isNotEmpty
        ? DateTime(parsedDates.first.year, parsedDates.first.month)
        : fallbackMonth;
    _maxMonth = parsedDates.isNotEmpty
        ? DateTime(parsedDates.last.year, parsedDates.last.month)
        : fallbackMonth;

    final initialDate = widget.selectedDateIso != null
        ? DateTime.tryParse(widget.selectedDateIso!)
        : null;
    if (initialDate != null) {
      _visibleMonth = DateTime(initialDate.year, initialDate.month);
    } else {
      _visibleMonth = _minMonth;
    }
  }

  Map<String, _DayScheduleInfo> _buildDayMap(List<JadwalSlotModel> slots) {
    final grouped = <String, List<JadwalSlotModel>>{};
    for (final slot in slots) {
      final key = slot.tanggal.trim();
      if (key.isEmpty) continue;
      grouped.putIfAbsent(key, () => []).add(slot);
    }

    final result = <String, _DayScheduleInfo>{};
    grouped.forEach((iso, daySlots) {
      final hasAvailable = daySlots.any(
        (s) => s.canBook && !s.isPenuh && !s.isClosed,
      );
      final allClosed = daySlots.every((s) => s.isClosed);

      final status = hasAvailable
          ? _DayScheduleStatus.available
          : (allClosed ? _DayScheduleStatus.closed : _DayScheduleStatus.full);

      final label = daySlots.first.hariTanggal.trim().isNotEmpty
          ? daySlots.first.hariTanggal.trim()
          : JadwalSlotModel.formatTanggalIndo(iso);

      result[iso] = _DayScheduleInfo(
        isoDate: iso,
        status: status,
        hariTanggal: label,
      );
    });
    return result;
  }

  String _toIso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  bool get _canGoPrev => _visibleMonth.isAfter(_minMonth);
  bool get _canGoNext => _visibleMonth.isBefore(_maxMonth);

  void _changeMonth(int delta) {
    final target = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    if (target.isBefore(_minMonth) || target.isAfter(_maxMonth)) return;
    setState(() {
      _visibleMonth = target;
      _unavailableNotice = null;
    });
  }

  int get _availableDatesCount => _dayMap.values
      .where((info) => info.status == _DayScheduleStatus.available)
      .length;

  void _handleDayTap(_DayScheduleInfo info) {
    if (info.status == _DayScheduleStatus.available) {
      widget.onDateSelected(info.isoDate);
      Navigator.pop(context);
      return;
    }

    setState(() {
      if (info.status == _DayScheduleStatus.closed) {
        _unavailableNotice =
            'Poli tutup pada ${info.hariTanggal}. Silakan pilih tanggal lain yang tersedia.';
      } else {
        _unavailableNotice =
            'Kuota pendaftaran penuh pada ${info.hariTanggal}. Silakan pilih tanggal lain yang tersedia.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmpty = firstOfMonth.weekday - 1; // Monday = 0 .. Sunday = 6
    final totalCells = ((leadingEmpty + daysInMonth + 6) ~/ 7) * 7;
    final rowCount = totalCells ~/ 7;

    final now = DateTime.now();
    final todayIso = _toIso(DateTime(now.year, now.month, now.day));

    return SafeArea(
      top: false,
      child: Container(
        key: const Key('pendaftaran_date_picker_sheet'),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header Sheet
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Tanggal Kunjungan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kPendaftaranInk,
                        fontFamily: kPendaftaranFontFamily,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_availableDatesCount tanggal praktik tersedia (45 hari ke depan)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kPendaftaranMuted,
                        fontFamily: kPendaftaranFontFamily,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: kPendaftaranMuted,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Navigasi Bulan (< November 2026 >)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryTintBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MonthNavButton(
                    icon: Icons.chevron_left_rounded,
                    enabled: _canGoPrev,
                    onTap: () => _changeMonth(-1),
                  ),
                  Text(
                    '${_monthNames[_visibleMonth.month]} ${_visibleMonth.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                      fontFamily: kPendaftaranFontFamily,
                    ),
                  ),
                  _MonthNavButton(
                    icon: Icons.chevron_right_rounded,
                    enabled: _canGoNext,
                    onTap: () => _changeMonth(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Header Hari (Sen - Min)
            Row(
              children: _weekdayLabels.map((label) {
                final isSunday = label == 'Min';
                return Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSunday
                            ? const Color(0xFFDC2626).withValues(alpha: 0.75)
                            : kPendaftaranMuted,
                        fontFamily: kPendaftaranFontFamily,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Grid Kalender Bulanan
            Column(
              children: List.generate(rowCount, (row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: List.generate(7, (col) {
                      final cellIndex = row * 7 + col;
                      final dayNum = cellIndex - leadingEmpty + 1;
                      if (dayNum < 1 || dayNum > daysInMonth) {
                        return const Expanded(child: SizedBox(height: 44));
                      }

                      final date = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month,
                        dayNum,
                      );
                      final iso = _toIso(date);
                      final info = _dayMap[iso];
                      final isSelected = iso == widget.selectedDateIso;
                      final isToday = iso == todayIso;

                      return Expanded(
                        child: _buildDayCell(
                          dayNum: dayNum,
                          iso: iso,
                          info: info,
                          isSelected: isSelected,
                          isToday: isToday,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),

            // Info Inline saat tanggal Penuh / Tutup ditap
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _unavailableNotice != null
                  ? Container(
                      key: ValueKey(_unavailableNotice),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.goldBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColors.goldText,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _unavailableNotice!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.goldText,
                                height: 1.35,
                                fontFamily: kPendaftaranFontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Legenda Minimalis
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _LegendDot(
                    color: AppColors.primary,
                    label: 'Tersedia',
                  ),
                  SizedBox(width: 18),
                  _LegendDot(
                    color: Color(0xFFEF4444),
                    label: 'Penuh / Tutup',
                  ),
                  SizedBox(width: 18),
                  _LegendDot(
                    color: Color(0xFFCBD5E1),
                    label: 'Tidak Praktik',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell({
    required int dayNum,
    required String iso,
    required _DayScheduleInfo? info,
    required bool isSelected,
    required bool isToday,
  }) {
    final hasSchedule = info != null;
    final isAvailable = info?.status == _DayScheduleStatus.available;
    final isUnavailable = hasSchedule && !isAvailable;

    Color textColor;
    if (isSelected) {
      textColor = Colors.white;
    } else if (isAvailable) {
      textColor = kPendaftaranInk;
    } else if (isUnavailable) {
      textColor = const Color(0xFF94A3B8);
    } else {
      textColor = const Color(0xFFCBD5E1);
    }

    Color bgColor = Colors.transparent;
    BoxBorder? border;
    if (isSelected) {
      bgColor = AppColors.primary;
      border = Border.all(color: AppColors.goldBorder, width: 1.6);
    } else if (isAvailable && isToday) {
      bgColor = AppColors.primarySoft;
      border = Border.all(color: AppColors.primaryTintBorder, width: 1);
    } else if (isUnavailable) {
      bgColor = const Color(0xFFFEF2F2);
    }

    final cell = Container(
      key: Key('calendar_day_$iso'),
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$dayNum',
            style: TextStyle(
              fontSize: 13,
              fontWeight: (isSelected || isAvailable)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: textColor,
              fontFamily: kPendaftaranFontFamily,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 3),
          if (hasSchedule)
            Container(
              width: 4.5,
              height: 4.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.goldBorder
                    : (isAvailable
                        ? AppColors.primary
                        : const Color(0xFFEF4444)),
              ),
            )
          else
            const SizedBox(height: 4.5),
        ],
      ),
    );

    if (!hasSchedule) return cell;

    return PressableScale(
      onTap: () => _handleDayTap(info),
      pressedScale: 0.94,
      child: cell,
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: enabled ? onTap : null,
      enabled: enabled,
      pressedScale: 0.92,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: enabled
              ? Border.all(color: AppColors.primaryTintBorder)
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primary : const Color(0xFFB6C2D4),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: kPendaftaranMuted,
            fontWeight: FontWeight.w500,
            fontFamily: kPendaftaranFontFamily,
          ),
        ),
      ],
    );
  }
}

