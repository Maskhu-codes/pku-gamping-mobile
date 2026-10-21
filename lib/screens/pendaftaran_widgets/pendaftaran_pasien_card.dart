import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Kartu Informasi Pasien yang sedang mendaftar.
/// Menampilkan Avatar inisial, Nama, Status Terhubung, Checklist,
/// No. Rekam Medis, serta tombol "Ganti Pasien >".
class PendaftaranPasienCard extends StatelessWidget {
  const PendaftaranPasienCard({
    super.key,
    required this.pasien,
    required this.onGantiPasien,
  });

  final PasienModel pasien;
  final VoidCallback onGantiPasien;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Baris: "Pasien" dan "Ganti Pasien >" ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pasien',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kPendaftaranInk,
                fontFamily: kPendaftaranFontFamily,
              ),
            ),
            InkWell(
              onTap: onGantiPasien,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Ganti Pasien',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kPendaftaranPrimary,
                        fontFamily: kPendaftaranFontFamily,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: kPendaftaranPrimary,
                    ),
                  ],
                ),
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
                    // Baris Nama + Badge Terhubung + Icon Checklist
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
                        const SizedBox(width: 8),
                        if (pasien.isTerhubung)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  '• ',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Terhubung',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: kPendaftaranFontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF475569),
                          size: 18,
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
