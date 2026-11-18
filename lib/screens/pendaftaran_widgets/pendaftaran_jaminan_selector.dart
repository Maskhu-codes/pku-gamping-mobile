import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Bagian pemilihan Jaminan Pasien (Umum/Pribadi, BPJS Kesehatan, Relasi)
/// serta form input Nomor Kartu, Nomor Rujukan, dan Nomor HP saat BPJS dipilih.
class PendaftaranJaminanSelector extends StatelessWidget {
  const PendaftaranJaminanSelector({
    super.key,
    required this.selectedJaminan,
    required this.onJaminanChanged,
    this.noKartuBpjsController,
    this.noRujukanBpjsController,
    this.noHpBpjsController,
    this.onBpjsFieldChanged,
  });

  final JenisJaminan selectedJaminan;
  final ValueChanged<JenisJaminan> onJaminanChanged;
  final TextEditingController? noKartuBpjsController;
  final TextEditingController? noRujukanBpjsController;
  final TextEditingController? noHpBpjsController;
  final ValueChanged<String>? onBpjsFieldChanged;

  @override
  Widget build(BuildContext context) {
    final isBpjs = selectedJaminan == JenisJaminan.bpjs;

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

        // ── Radio Opsi Row 1: Umum / Pribadi & BPJS Kesehatan ──
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
                label: 'BPJS Kesehatan',
                value: JenisJaminan.bpjs,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Radio Opsi Row 2: Relasi ──
        _buildRadioOption(
          label: 'Relasi',
          value: JenisJaminan.relasi,
        ),
        const SizedBox(height: 12),

        // ── Form Input Khusus BPJS Kesehatan ──
        if (isBpjs) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kPendaftaranPrimary.withValues(alpha: 0.35)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A0D4FC1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Kepesertaan BPJS Kesehatan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPendaftaranInk,
                    fontFamily: kPendaftaranFontFamily,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBpjsInputField(
                  fieldKey: const Key('bpjs_no_kartu_field'),
                  controller: noKartuBpjsController,
                  label: 'Nomor Kartu BPJS',
                  hint: 'Masukkan 13 digit nomor kartu BPJS',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildBpjsInputField(
                  fieldKey: const Key('bpjs_no_rujukan_field'),
                  controller: noRujukanBpjsController,
                  label: 'Nomor Rujukan',
                  hint: 'Masukkan nomor rujukan FKTP / RS',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 12),
                _buildBpjsInputField(
                  fieldKey: const Key('bpjs_no_hp_field'),
                  controller: noHpBpjsController,
                  label: 'Nomor HP Aktif',
                  hint: 'Contoh: 081234567890',
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Banner Info Pasien BPJS / Umum ──
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
                child: Text(
                  isBpjs
                      ? 'Pastikan nomor kartu BPJS, nomor rujukan aktif, dan nomor HP sudah benar sebelum konfirmasi pendaftaran.'
                      : 'Pilih BPJS Kesehatan apabila Anda mendaftar menggunakan jaminan BPJS dengan surat rujukan aktif.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kPendaftaranBannerText,
                    fontFamily: kPendaftaranFontFamily,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBpjsInputField({
    required Key fieldKey,
    required TextEditingController? controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kPendaftaranInk,
            fontFamily: kPendaftaranFontFamily,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onBpjsFieldChanged,
          style: const TextStyle(
            fontSize: 13,
            color: kPendaftaranInk,
            fontFamily: kPendaftaranFontFamily,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: kPendaftaranMuted,
              fontFamily: kPendaftaranFontFamily,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kPendaftaranCardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kPendaftaranCardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: kPendaftaranPrimary,
                width: 1.4,
              ),
            ),
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
