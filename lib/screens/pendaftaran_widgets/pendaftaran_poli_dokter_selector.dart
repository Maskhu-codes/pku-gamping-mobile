import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Kartu pemilihan berjenjang untuk Poli & Dokter.
/// Sesuai dengan desain: terdapat label "Poli & Dokter", "Poli Tujuan",
/// dropdown "PILIH POLI", dan dropdown "PILIH DOKTER".
class PendaftaranPoliDokterSelector extends StatelessWidget {
  const PendaftaranPoliDokterSelector({
    super.key,
    required this.selectedPoli,
    required this.selectedDokter,
    required this.onTapPoli,
    required this.onTapDokter,
    this.isLoadingInitial = false,
  });

  final PoliModel? selectedPoli;
  final DokterPendaftaranModel? selectedDokter;
  final VoidCallback onTapPoli;
  final VoidCallback onTapDokter;
  final bool isLoadingInitial;

  @override
  Widget build(BuildContext context) {
    final isDokterEnabled = selectedPoli != null && !isLoadingInitial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Section ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Poli & Dokter',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kPendaftaranInk,
                fontFamily: kPendaftaranFontFamily,
              ),
            ),
            if (isLoadingInitial)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kPendaftaranPrimary,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Memuat dari SIMRS...',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kPendaftaranPrimary,
                      fontFamily: kPendaftaranFontFamily,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Sub-label Poli Tujuan ──
        const Text(
          'Poli Tujuan',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
            fontFamily: kPendaftaranFontFamily,
          ),
        ),
        const SizedBox(height: 6),

        // ── Selector Poli ──
        _buildSelectorButton(
          onTap: isLoadingInitial ? null : onTapPoli,
          icon: Icons.favorite_border_rounded,
          text: isLoadingInitial && selectedPoli == null
              ? 'Memuat poliklinik...'
              : (selectedPoli?.nama ?? 'PILIH POLI'),
          isSelected: selectedPoli != null,
          isEnabled: !isLoadingInitial,
        ),
        const SizedBox(height: 14),

        // ── Sub-label Dokter Tujuan ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dokter Tujuan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
                fontFamily: kPendaftaranFontFamily,
              ),
            ),
            if (!isDokterEnabled && !isLoadingInitial)
              const Text(
                'Pilih poli terlebih dahulu',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: kPendaftaranMuted,
                  fontFamily: kPendaftaranFontFamily,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // ── Selector Dokter ──
        _buildSelectorButton(
          onTap: isLoadingInitial
              ? null
              : (isDokterEnabled ? onTapDokter : onTapPoli),
          icon: Icons.person_search_rounded,
          text: isLoadingInitial && selectedDokter == null
              ? 'Memuat dokter...'
              : (selectedDokter?.nama ?? 'PILIH DOKTER'),
          isSelected: selectedDokter != null,
          isEnabled: isDokterEnabled,
        ),
      ],
    );
  }

  Widget _buildSelectorButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String text,
    required bool isSelected,
    required bool isEnabled,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? kPendaftaranPrimary
                : (isEnabled ? kPendaftaranCardBorder : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: isEnabled
              ? const [
                  BoxShadow(
                    color: Color(0x05172340),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon Biru Outline
            Icon(
              icon,
              color: isEnabled
                  ? (isSelected ? kPendaftaranPrimary : const Color(0xFF2563EB))
                  : kPendaftaranMuted,
              size: 22,
            ),
            const SizedBox(width: 14),

            // Teks Pilihan
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w700,
                  color: isEnabled
                      ? (isSelected ? kPendaftaranInk : const Color(0xFF1E293B))
                      : kPendaftaranMuted,
                  fontFamily: kPendaftaranFontFamily,
                  letterSpacing: isSelected ? 0 : 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Chevron Down
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isEnabled ? const Color(0xFF64748B) : Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
