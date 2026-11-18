import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';
import 'pendaftaran_constants.dart';
import 'pendaftaran_date_picker_sheet.dart';

/// Bagian pemilihan Jadwal Kunjungan dokter berbasis Date Picker (Opsi A).
///
/// Menampilkan:
/// 1. Field ringkas "Tanggal Kunjungan" yang membuka Bottom Sheet Kalender Bulanan 45 hari.
/// 2. Shortcut cepat 3 tanggal praktik terdekat yang tersedia + tombol "Kalender".
/// 3. Daftar ringkas sesi/jam praktik khusus pada tanggal terpilih.
class PendaftaranJadwalPicker extends StatelessWidget {
  const PendaftaranJadwalPicker({
    super.key,
    required this.selectedDokter,
    required this.selectedSlot,
    required this.onSlotSelected,
    this.isLoading = false,
  });

  final DokterPendaftaranModel? selectedDokter;
  final JadwalSlotModel? selectedSlot;
  final ValueChanged<JadwalSlotModel> onSlotSelected;
  final bool isLoading;

  static const _shortMonths = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String _formatShortChipLabel(JadwalSlotModel slot) {
    final parts = slot.tanggal.split('-');
    String datePart = slot.hariTanggal;
    if (parts.length == 3) {
      final month = int.tryParse(parts[1]) ?? 0;
      final day = int.tryParse(parts[2]) ?? 0;
      if (month >= 1 && month <= 12 && day > 0) {
        datePart = '$day ${_shortMonths[month]}';
      }
    }
    final shortDay = slot.namaHari.trim().length >= 3
        ? slot.namaHari.trim().substring(0, 3)
        : slot.namaHari.trim();
    return shortDay.isNotEmpty ? '$shortDay, $datePart' : datePart;
  }

  /// Mengambil maksimal 3 tanggal unik terdekat yang tersedia untuk shortcut cepat
  List<JadwalSlotModel> _getQuickAvailableDates(List<JadwalSlotModel> slots) {
    final seen = <String>{};
    final result = <JadwalSlotModel>[];
    for (final s in slots) {
      final key = s.tanggal.trim();
      if (key.isEmpty) continue;
      if (!s.canBook || s.isPenuh || s.isClosed) continue;
      if (seen.add(key)) {
        result.add(s);
        if (result.length >= 3) break;
      }
    }
    return result;
  }

  int _countDistinctDates(List<JadwalSlotModel> slots) {
    return slots
        .map((s) => s.tanggal.trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .length;
  }

  void _selectDateIso(List<JadwalSlotModel> slots, String isoDate) {
    final daySlots =
        slots.where((s) => s.tanggal.trim() == isoDate).toList();
    if (daySlots.isEmpty) return;

    final available = daySlots.where(
      (s) => s.canBook && !s.isPenuh && !s.isClosed,
    );
    onSlotSelected(available.isNotEmpty ? available.first : daySlots.first);
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDokter == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPendaftaranCardBorder),
        ),
        child: Row(
          children: const [
            Icon(
              Icons.info_outline_rounded,
              color: kPendaftaranMuted,
              size: 22,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pilih dokter terlebih dahulu untuk melihat jadwal praktik yang tersedia.',
                style: TextStyle(
                  fontSize: 12,
                  color: kPendaftaranMuted,
                  fontFamily: kPendaftaranFontFamily,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final slots = selectedDokter!.jadwalSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Baris: "Jadwal Kunjungan" ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jadwal Kunjungan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kPendaftaranInk,
                fontFamily: kPendaftaranFontFamily,
              ),
            ),
            if (!isLoading && slots.isNotEmpty)
              Text(
                '${_countDistinctDates(slots)} hari praktik',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kPendaftaranMuted,
                  fontFamily: kPendaftaranFontFamily,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Konten Date Picker + Sesi Praktik ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: isLoading
              ? const SlotPickerSkeleton(key: ValueKey('slot_loading'))
              : slots.isEmpty
                  ? Container(
                      key: const ValueKey('slot_empty'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kPendaftaranCardBorder),
                      ),
                      child: const Text(
                        'Belum ada jadwal praktik tersedia untuk dokter ini.',
                        style: TextStyle(
                          fontSize: 12,
                          color: kPendaftaranMuted,
                          fontFamily: kPendaftaranFontFamily,
                        ),
                      ),
                    )
                  : _buildDatePickerContent(context, slots),
        ),
      ],
    );
  }

  Widget _buildDatePickerContent(
    BuildContext context,
    List<JadwalSlotModel> slots,
  ) {
    final activeDateIso = (selectedSlot != null &&
            selectedSlot!.tanggal.trim().isNotEmpty &&
            slots.any((s) => s.tanggal.trim() == selectedSlot!.tanggal.trim()))
        ? selectedSlot!.tanggal.trim()
        : () {
            final firstAvail = slots.where(
              (s) => s.canBook && !s.isPenuh && !s.isClosed,
            );
            return firstAvail.isNotEmpty
                ? firstAvail.first.tanggal.trim()
                : slots.first.tanggal.trim();
          }();

    final daySlots =
        slots.where((s) => s.tanggal.trim() == activeDateIso).toList();
    final displayDateText = selectedSlot?.hariTanggal.trim().isNotEmpty == true
        ? selectedSlot!.hariTanggal
        : (daySlots.isNotEmpty
            ? daySlots.first.hariTanggal
            : JadwalSlotModel.formatTanggalIndo(activeDateIso));

    final quickDates = _getQuickAvailableDates(slots);
    final totalDistinctDates = _countDistinctDates(slots);

    void openCalendarSheet() {
      PendaftaranDatePickerSheet.show(
        context: context,
        slots: slots,
        selectedDateIso: activeDateIso,
        onDateSelected: (iso) => _selectDateIso(slots, iso),
      );
    }

    return Column(
      key: ValueKey('slot_picker_${selectedDokter!.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Field Tanggal Kunjungan (Ringkas & Senada dengan Poli/Dokter)
        PressableScale(
          onTap: openCalendarSheet,
          pressedScale: 0.985,
          child: Container(
            key: const Key('pendaftaran_date_picker_field'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedSlot != null
                    ? kPendaftaranPrimary
                    : kPendaftaranCardBorder,
                width: selectedSlot != null ? 1.4 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06172340),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryTintBorder),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggal Kunjungan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: kPendaftaranMuted,
                          fontFamily: kPendaftaranFontFamily,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayDateText.isNotEmpty
                            ? displayDateText
                            : 'Pilih Tanggal',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kPendaftaranInk,
                          fontFamily: kPendaftaranFontFamily,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ubah',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: kPendaftaranFontFamily,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Shortcut Cepat 3 Tanggal Terdekat Tersedia + Pill Kalender
        if (quickDates.isNotEmpty) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Row(
              children: [
                ...quickDates.map((quickSlot) {
                  final isActiveDate =
                      quickSlot.tanggal.trim() == activeDateIso;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PressableScale(
                      onTap: () =>
                          _selectDateIso(slots, quickSlot.tanggal.trim()),
                      pressedScale: 0.96,
                      child: AnimatedContainer(
                        key: Key('quick_date_${quickSlot.tanggal.trim()}'),
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isActiveDate
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActiveDate
                                ? AppColors.goldBorder
                                : kPendaftaranCardBorder,
                            width: isActiveDate ? 1.4 : 1,
                          ),
                        ),
                        child: Text(
                          _formatShortChipLabel(quickSlot),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActiveDate
                                ? Colors.white
                                : kPendaftaranInk,
                            fontFamily: kPendaftaranFontFamily,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (totalDistinctDates > quickDates.length)
                  PressableScale(
                    onTap: openCalendarSheet,
                    pressedScale: 0.96,
                    child: Container(
                      key: const Key('quick_date_open_calendar'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryTintBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Kalender',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontFamily: kPendaftaranFontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],

        // 3. Sesi / Jam Praktik Khusus Tanggal Terpilih
        const SizedBox(height: 14),
        const Text(
          'Sesi & Jam Praktik',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
            fontFamily: kPendaftaranFontFamily,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daySlots.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final slot = daySlots[index];
            final isSelected = slot.id == selectedSlot?.id;
            final isUnavailable = slot.isPenuh || slot.isClosed || !slot.canBook;

            return _buildSessionCard(
              context: context,
              slot: slot,
              isSelected: isSelected,
              isUnavailable: isUnavailable,
              onTap: () {
                if (isUnavailable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        slot.isClosed
                            ? 'Poli tutup pada sesi ini. Silakan pilih tanggal lain.'
                            : 'Kuota sesi ini sudah penuh. Silakan pilih tanggal lain.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                onSlotSelected(slot);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSessionCard({
    required BuildContext context,
    required JadwalSlotModel slot,
    required bool isSelected,
    required bool isUnavailable,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.985,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySoft
              : (isUnavailable ? const Color(0xFFFAFAFA) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? kPendaftaranPrimary
                : (isUnavailable
                    ? const Color(0xFFF1F5F9)
                    : kPendaftaranCardBorder),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Opacity(
          opacity: isUnavailable ? 0.65 : 1.0,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          slot.shift,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isUnavailable
                                ? const Color(0xFF64748B)
                                : kPendaftaranInk,
                            fontFamily: kPendaftaranFontFamily,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldSoft,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.goldBorder),
                            ),
                            child: const Text(
                              'Terpilih',
                              style: TextStyle(
                                color: AppColors.goldText,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: kPendaftaranFontFamily,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slot.jam,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kPendaftaranMuted,
                        fontFamily: kPendaftaranFontFamily,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isUnavailable
                      ? kPendaftaranSlotFullBg
                      : (isSelected
                          ? Colors.white
                          : kPendaftaranSlotAvailableBg),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected && !isUnavailable
                      ? Border.all(color: AppColors.primaryTintBorder)
                      : null,
                ),
                child: Text(
                  slot.kuotaLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUnavailable
                        ? kPendaftaranSlotFullText
                        : kPendaftaranSlotAvailableText,
                    fontFamily: kPendaftaranFontFamily,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
