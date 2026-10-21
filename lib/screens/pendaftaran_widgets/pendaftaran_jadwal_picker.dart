import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Bagian pemilihan Jadwal Kunjungan dokter.
/// Menampilkan daftar slot tanggal, jam praktik, dan status kuota (Sisa/Penuh).
class PendaftaranJadwalPicker extends StatelessWidget {
  const PendaftaranJadwalPicker({
    super.key,
    required this.selectedDokter,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  final DokterPendaftaranModel? selectedDokter;
  final JadwalSlotModel? selectedSlot;
  final ValueChanged<JadwalSlotModel> onSlotSelected;

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
        // ── Header Baris: "Jadwal Kunjungan" & "Praktik Pagi" ──
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
            if (slots.isNotEmpty)
              Text(
                slots.first.shift,
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

        // ── Daftar Kartu Slot ──
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final slot = slots[index];
            final isSelected = slot.id == selectedSlot?.id;
            final isPenuh = slot.isPenuh;

            return _buildSlotCard(
              context: context,
              slot: slot,
              isSelected: isSelected,
              isPenuh: isPenuh,
              onTap: () {
                if (isPenuh) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Jadwal ini sudah penuh. Silakan pilih tanggal lain.',
                      ),
                      duration: Duration(seconds: 2),
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

  Widget _buildSlotCard({
    required BuildContext context,
    required JadwalSlotModel slot,
    required bool isSelected,
    required bool isPenuh,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : (isPenuh ? const Color(0xFFFAFAFA) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? kPendaftaranPrimary
                : (isPenuh ? const Color(0xFFF1F5F9) : kPendaftaranCardBorder),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x100D4FC1),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x04172340),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Opacity(
          opacity: isPenuh ? 0.65 : 1.0,
          child: Row(
            children: [
              // Icon Kotak Kalender
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? kPendaftaranPrimary
                      : (isPenuh
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: isSelected
                      ? Colors.white
                      : (isPenuh ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Info Tanggal & Jam
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Tanggal + Badge "Terpilih"
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            slot.hariTanggal,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isPenuh
                                  ? const Color(0xFF64748B)
                                  : kPendaftaranInk,
                              fontFamily: kPendaftaranFontFamily,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                              color: kPendaftaranSelectedBadge,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Terpilih',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: kPendaftaranFontFamily,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Jam Praktik
                    Text(
                      slot.jam,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kPendaftaranMuted,
                        fontFamily: kPendaftaranFontFamily,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge Kuota Sisa / Penuh di Kanan
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPenuh
                      ? kPendaftaranSlotFullBg
                      : kPendaftaranSlotAvailableBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slot.kuotaLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPenuh
                        ? kPendaftaranSlotFullText
                        : kPendaftaranSlotAvailableText,
                    fontFamily: kPendaftaranFontFamily,
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
