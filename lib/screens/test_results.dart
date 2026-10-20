import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/test_lab_results.dart';
import 'package:pku_gamping_app/screens/test_radiology_results.dart';

const _primaryBlue = Color(0xFF0D4FC1);
const _ink = Color(0xFF202124);
const _muted = Color(0xFF4C5261);
const _page = Color(0xFFF6F8FA);
const bool tampilkanHasilLab = true;
const bool tampilkanHasilRadiologi = false;

class TestResults extends StatelessWidget {
  const TestResults({super.key, this.onRadiologyTap});

  final VoidCallback? onRadiologyTap;

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);

    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      child: Scaffold(
        backgroundColor: _page,
        appBar: AppBar(
          backgroundColor: _page,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back, color: _ink, size: 24),
          ),
          title: const Text(
            'Pemeriksaan Penunjang',
            style: TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          titleSpacing: 4,
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Pilih jenis hasil pemeriksaan yang ingin Anda lihat.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              _TestResultCard(
                icon: Icons.science_outlined,
                title: 'Laboratorium',
                description: 'Hasil pemeriksaan darah, urine, dan lainnya.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TestLabResults(
                        results: tampilkanHasilLab
                            ? const [
                                LabResult(
                                  title: 'Pemeriksaan Hemoglobin',
                                  date: '19 Oktober 2026',
                                  time: '09:30 WIB',
                                ),
                                LabResult(
                                  title: 'Pemeriksaan Leukosit',
                                  date: '19 Oktober 2026',
                                  time: '10:00 WIB',
                                ),
                              ]
                            : const [],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _TestResultCard(
                icon: Icons.medical_services_outlined,
                title: 'Radiologi',
                description: 'Hasil rontgen, USG, dan citra medis.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TestRadiologyResults(
                        results: tampilkanHasilRadiologi
                            ? const [
                                RadiologyResult(
                                  title: 'Pemeriksaan Rontgen Thorax',
                                  date: '18 Oktober 2026',
                                  time: '11:00 WIB',
                                ),
                                RadiologyResult(
                                  title: 'Pemeriksaan USG Abdomen',
                                  date: '17 Oktober 2026',
                                  time: '08:30 WIB',
                                ),
                              ]
                            : const [],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestResultCard extends StatelessWidget {
  const _TestResultCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE8EBF0)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A202124),
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primaryBlue, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF777F91),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
