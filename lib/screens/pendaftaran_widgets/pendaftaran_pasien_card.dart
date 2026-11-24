import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Kartu Informasi Pasien Resmi yang sedang mendaftar.
/// Menampilkan Avatar inisial, Nama, Status Akun Resmi Terdaftar SIMRS,
/// dan No. Rekam Medis (1 Akun = 1 Pasien).
class PendaftaranPasienCard extends StatelessWidget {
  const PendaftaranPasienCard({
    super.key,
    required this.pasien,
    this.onGantiPasien,
  });

  final PasienModel pasien;
  final VoidCallback? onGantiPasien;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Baris: "Identitas Pasien" dan Badge Resmi ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Identitas Pasien',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kPendaftaranInk,
                fontFamily: kPendaftaranFontFamily,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA7F3D0), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.verified_rounded,
                    size: 13,
                    color: Color(0xFF059669),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Akun Resmi Terdaftar',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                      fontFamily: kPendaftaranFontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Kartu Pasien ──
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              // Avatar Lingkaran Inisial
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Center(
                  child: Text(
                    pasien.inisial,
                    style: const TextStyle(
                      color: Color(0xFF1E40AF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: kPendaftaranFontFamily,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info Pasien
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Nama + Checklist
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            pasien.nama,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kPendaftaranInk,
                              fontFamily: kPendaftaranFontFamily,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 17,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // No. RM
                    Row(
                      children: [
                        const Text(
                          'No. RM ',
                          style: TextStyle(
                            fontSize: 12,
                            color: kPendaftaranMuted,
                            fontFamily: kPendaftaranFontFamily,
                          ),
                        ),
                        Text(
                          pasien.noRm,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kPendaftaranInk,
                            fontFamily: kPendaftaranFontFamily,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
