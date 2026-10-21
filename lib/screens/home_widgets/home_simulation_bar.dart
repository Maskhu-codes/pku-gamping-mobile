import 'package:flutter/material.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'home_constants.dart';

/// Bar pembantu pengujian/simulasi untuk mendemokan perpindahan status
/// antara kondisi "Belum Ada Antrean" dan "Ada Antrean Aktif" secara instan.
class HomeSimulationBar extends StatelessWidget {
  const HomeSimulationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AntreanAktifModel?>(
      valueListenable: AntreanService.antreanAktif,
      builder: (context, antrean, _) {
        final adaAntrean = antrean != null;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    size: 16,
                    color: Color(0xFF475569),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Panel Simulasi Testing Antrean',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                      fontFamily: kHomeFontFamily,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: adaAntrean
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      adaAntrean ? 'Status: ADA ANTREAN' : 'Status: KOSONG',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: adaAntrean
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        fontFamily: kHomeFontFamily,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Tombol Kosongkan
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AntreanService.kosongkanAntrean();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Simulasi: Antrean dikosongkan.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            !adaAntrean ? Colors.white : Colors.transparent,
                        side: BorderSide(
                          color: !adaAntrean
                              ? kHomePrimaryBlue
                              : const Color(0xFF94A3B8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text(
                        'Kosongkan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: kHomeFontFamily,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Tombol Pasang Dummy
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AntreanService.setAntreanDummy();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Simulasi: Antrean A-014 berhasil dipasang.',
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            adaAntrean ? kHomePrimaryBlue : const Color(0xFF64748B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.confirmation_number_outlined,
                        size: 16,
                      ),
                      label: const Text(
                        'Pasang A-014',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: kHomeFontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
