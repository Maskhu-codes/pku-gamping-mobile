import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Kartu Ringkasan Pendaftaran yang menampilkan preview dinamis
/// data pendaftaran sebelum dikonfirmasi oleh pasien.
class PendaftaranRingkasanCard extends StatelessWidget {
  const PendaftaranRingkasanCard({
    super.key,
    required this.pasien,
    required this.poli,
    required this.dokter,
    required this.slot,
    required this.jaminan,
  });

  final PasienModel pasien;
  final PoliModel? poli;
  final DokterPendaftaranModel? dokter;
  final JadwalSlotModel? slot;
  final JenisJaminan jaminan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Label ──
        const Text(
          'Ringkasan Pendaftaran',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: kPendaftaranInk,
            fontFamily: kPendaftaranFontFamily,
          ),
        ),
        const SizedBox(height: 10),

        // ── Container Ringkasan ──
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPendaftaranCardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06172340),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                label: 'Pasien',
                value: pasien.nama,
                isBold: true,
              ),
              const SizedBox(height: 10),
              _buildSummaryRow(
                label: 'Poli',
                value: poli?.nama ?? 'Belum dipilih',
                isPlaceholder: poli == null,
              ),
              const SizedBox(height: 10),
              _buildSummaryRow(
                label: 'Dokter',
                value: dokter?.nama ?? 'Belum dipilih',
                isPlaceholder: dokter == null,
              ),
              const SizedBox(height: 10),
              _buildSummaryRow(
                label: 'Tanggal',
                value: slot?.hariTanggal ?? 'Belum dipilih',
                isPlaceholder: slot == null,
              ),
              const SizedBox(height: 10),
              _buildSummaryRow(
                label: 'Jam',
                value: slot?.jam ?? '-',
                isPlaceholder: slot == null,
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: kPendaftaranDivider),
              const SizedBox(height: 14),

              // Baris Jenis Pasien / Jaminan (Warna Biru Kuat)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jenis Pasien',
                    style: TextStyle(
                      fontSize: 13,
                      color: kPendaftaranMuted,
                      fontFamily: kPendaftaranFontFamily,
                    ),
                  ),
                  Text(
                    jaminan.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kPendaftaranPrimary,
                      fontFamily: kPendaftaranFontFamily,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isBold = false,
    bool isPlaceholder = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: kPendaftaranMuted,
              fontFamily: kPendaftaranFontFamily,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold || !isPlaceholder
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: isPlaceholder ? kPendaftaranMuted : kPendaftaranInk,
              fontFamily: kPendaftaranFontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
