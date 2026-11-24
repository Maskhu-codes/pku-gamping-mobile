import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Kartu Ringkasan Pendaftaran yang menampilkan preview dinamis
/// data pendaftaran sebelum dikonfirmasi oleh pasien mandiri.
class PendaftaranRingkasanCard extends StatelessWidget {
  const PendaftaranRingkasanCard({
    super.key,
    required this.pasien,
    required this.poli,
    required this.dokter,
    required this.slot,
    this.jaminan,
    this.noKartuBpjs,
    this.noRujukanBpjs,
  });

  final PasienModel pasien;
  final PoliModel? poli;
  final DokterPendaftaranModel? dokter;
  final JadwalSlotModel? slot;
  final JenisJaminan? jaminan;
  final String? noKartuBpjs;
  final String? noRujukanBpjs;

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

        // ── Container Ringkasan (Pre-Admission Slip) ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kPendaftaranCardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06172340),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Data Pasien & Jaminan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PASIEN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: kPendaftaranMuted,
                            letterSpacing: 0.6,
                            fontFamily: kPendaftaranFontFamily,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pasien.nama,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kPendaftaranInk,
                            fontFamily: kPendaftaranFontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (jaminan != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: jaminan == JenisJaminan.bpjs
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: jaminan == JenisJaminan.bpjs
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Text(
                        jaminan == JenisJaminan.bpjs ? 'BPJS' : 'Umum',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: jaminan == JenisJaminan.bpjs
                              ? const Color(0xFF15803D)
                              : const Color(0xFF1D4ED8),
                          fontFamily: kPendaftaranFontFamily,
                        ),
                      ),
                    ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),

              // 2. Poli & Dokter
              _buildSummaryRow(
                label: 'Poli',
                value: poli?.nama ?? 'Belum dipilih',
                isPlaceholder: poli == null,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                label: 'Dokter',
                value: dokter?.nama ?? 'Belum dipilih',
                isPlaceholder: dokter == null,
              ),
              const SizedBox(height: 8),

              // 3. Tanggal & Jam Praktik
              _buildSummaryRow(
                label: 'Tanggal',
                value: slot?.hariTanggal ?? 'Belum dipilih',
                isPlaceholder: slot == null,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                label: 'Jam Praktik',
                value: slot?.jam ?? '-',
                isPlaceholder: slot == null,
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
