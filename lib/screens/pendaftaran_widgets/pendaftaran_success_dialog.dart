import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'pendaftaran_constants.dart';

/// Modal Bottom Sheet Sukses Pendaftaran (Opsi 1).
/// Menampilkan nomor antrean, QR/barcode tiket, detail poli, dan tombol aksi
/// menuju layar antrean aktif (`QueueScreen`).
class PendaftaranSuccessDialog extends StatelessWidget {
  const PendaftaranSuccessDialog({
    super.key,
    required this.nomorAntrean,
    required this.pasien,
    required this.poli,
    required this.dokter,
    required this.slot,
    required this.jaminan,
  });

  final String nomorAntrean;
  final PasienModel pasien;
  final PoliModel poli;
  final DokterPendaftaranModel dokter;
  final JadwalSlotModel slot;
  final JenisJaminan jaminan;

  static Future<void> show({
    required BuildContext context,
    required String nomorAntrean,
    required PasienModel pasien,
    required PoliModel poli,
    required DokterPendaftaranModel dokter,
    required JadwalSlotModel slot,
    required JenisJaminan jaminan,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PendaftaranSuccessDialog(
        nomorAntrean: nomorAntrean,
        pasien: pasien,
        poli: poli,
        dokter: dokter,
        slot: slot,
        jaminan: jaminan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle Bar ──
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // ── Icon Sukses Hijau ──
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF16A34A),
                  size: 38,
                ),
              ),
              const SizedBox(height: 14),

              // ── Judul Sukses ──
              const Text(
                'Pendaftaran Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kPendaftaranInk,
                  fontFamily: kPendaftaranFontFamily,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tiket antrean rawat jalan Anda telah diterbitkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: kPendaftaranMuted,
                  fontFamily: kPendaftaranFontFamily,
                ),
              ),
              const SizedBox(height: 20),

              // ── Kartu Tiket Antrean ──
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kPendaftaranCardBorder),
                ),
                child: Column(
                  children: [
                    // Header Tiket
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A3A8A),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(17)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'RS PKU GAMPING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              fontFamily: kPendaftaranFontFamily,
                            ),
                          ),
                          Text(
                            'RAWAT JALAN',
                            style: TextStyle(
                              color: Color(0xFF93C5FD),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              fontFamily: kPendaftaranFontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Konten Nomor Antrean
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Text(
                            'NOMOR ANTREAN ANDA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kPendaftaranMuted,
                              letterSpacing: 0.8,
                              fontFamily: kPendaftaranFontFamily,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            nomorAntrean,
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: kPendaftaranPrimary,
                              letterSpacing: 2,
                              fontFamily: kPendaftaranFontFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Estimasi ${slot.jam}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: kPendaftaranPrimary,
                                fontFamily: kPendaftaranFontFamily,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Garis Tiket Putus-putus
                          Row(
                            children: List.generate(
                              24,
                              (index) => Expanded(
                                child: Container(
                                  height: 1.5,
                                  color: index.isEven
                                      ? Colors.grey.shade300
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Detail Info Pasien & Poli
                          _buildTicketRow('Nama Pasien', pasien.nama),
                          const SizedBox(height: 8),
                          _buildTicketRow('No. Rekam Medis', pasien.noRm),
                          const SizedBox(height: 8),
                          _buildTicketRow('Poli Tujuan', poli.nama),
                          const SizedBox(height: 8),
                          _buildTicketRow('Dokter', dokter.nama),
                          const SizedBox(height: 8),
                          _buildTicketRow('Tanggal', slot.hariTanggal),
                          const SizedBox(height: 8),
                          _buildTicketRow('Jaminan', jaminan.label),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Catatan Kiosk
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFFB45309),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Harap hadir 15 menit sebelum jam periksa dan lakukan check-in di kiosk rumah sakit.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF78350F),
                          fontFamily: kPendaftaranFontFamily,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Tombol Utama: "Lihat Antrean" (Navigasi ke QueueScreen) ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.home,
                      arguments: {'initialIndex': 1},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPendaftaranPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.confirmation_number_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Lihat Antrean Aktif',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: kPendaftaranFontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Tombol Sekunder: "Kembali ke Beranda" ──
              SizedBox(
                width: double.infinity,
                height: 46,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kPendaftaranInk,
                      fontFamily: kPendaftaranFontFamily,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: kPendaftaranMuted,
            fontFamily: kPendaftaranFontFamily,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kPendaftaranInk,
              fontFamily: kPendaftaranFontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
