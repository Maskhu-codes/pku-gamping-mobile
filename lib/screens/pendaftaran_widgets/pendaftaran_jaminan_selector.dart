import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Bagian pemilihan Jaminan Pasien (Umum/Pribadi vs Relasi)
/// serta banner edukasi pasien BPJS via Mobile JKN.
class PendaftaranJaminanSelector extends StatelessWidget {
  const PendaftaranJaminanSelector({
    super.key,
    required this.selectedJaminan,
    required this.onJaminanChanged,
  });

  final JenisJaminan selectedJaminan;
  final ValueChanged<JenisJaminan> onJaminanChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label Section ──
        const Text(
          'Jaminan Pasien',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: kPendaftaranInk,
            fontFamily: kPendaftaranFontFamily,
          ),
        ),
        const SizedBox(height: 10),

        // ── Radio Opsi Row ──
        Row(
          children: [
            Expanded(
              child: _buildRadioOption(
                label: 'Umum / Pribadi',
                value: JenisJaminan.umumPribadi,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRadioOption(
                label: 'Relasi',
                value: JenisJaminan.relasi,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Banner Info Pasien BPJS ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: kPendaftaranBannerBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPendaftaranBannerBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFB45309),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: kPendaftaranBannerText,
                      fontFamily: kPendaftaranFontFamily,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: 'Pasien BPJS melakukan pendaftaran melalui aplikasi ',
                      ),
                      TextSpan(
                        text: 'Mobile JKN',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF78350F),
                        ),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String label,
    required JenisJaminan value,
  }) {
    final isSelected = selectedJaminan == value;

    return InkWell(
      onTap: () => onJaminanChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPendaftaranPrimary : kPendaftaranCardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0C0D4FC1),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio Icon
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? kPendaftaranPrimary : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 8),

            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? kPendaftaranInk : const Color(0xFF475569),
                  fontFamily: kPendaftaranFontFamily,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
