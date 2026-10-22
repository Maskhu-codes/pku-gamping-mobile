import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'jadwal_widgets/jadwal_constants.dart';
import 'jadwal_widgets/jadwal_header.dart';
import 'jadwal_widgets/jadwal_search_bar.dart';
import 'jadwal_widgets/jadwal_date_strip.dart';
import 'jadwal_widgets/jadwal_poli_filter.dart';
import 'jadwal_widgets/jadwal_dokter_list.dart';
import 'jadwal_widgets/jadwal_footer_note.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/widgets/app_bottom_nav.dart';
import 'package:pku_gamping_app/widgets/hospital_brand_header.dart';

import 'package:pku_gamping_app/services/simrs_service.dart';

/// Data jadwal dokter dan daftar poli terintegrasi dari SimrsService
final List<DokterJadwal> _dummyDokter = SimrsService.defaultJadwalDokter;
const _poliList = <String>[
  'Penyakit Dalam',
  'Anak',
  'Jantung',
  'Mata',
  'Bedah',
];

/// ─── Halaman Jadwal Dokter ───
///
/// Screen utama yang menggabungkan seluruh widget jadwal secara modular:
/// Header → Search → DateStrip → PoliFilter → DokterList → FooterNote
class JadwalScreen extends StatefulWidget {
  const JadwalScreen({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  late DateTime _selectedDate;
  String _selectedPoli = 'Semua';
  String _searchQuery = '';
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    if (mounted) {
      setState(() => _localeInitialized = true);
    }
  }

  /// Memfilter daftar dokter berdasarkan poli dan kata kunci pencarian.
  List<DokterJadwal> get _filteredDokter {
    return _dummyDokter.where((d) {
      // Filter poli
      if (_selectedPoli != 'Semua') {
        if (!d.poli.toLowerCase().contains(_selectedPoli.toLowerCase())) {
          return false;
        }
      }
      // Filter pencarian (nama atau poli)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchNama = d.nama.toLowerCase().contains(query);
        final matchPoli = d.poli.toLowerCase().contains(query);
        if (!matchNama && !matchPoli) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized) {
      return const Scaffold(
        backgroundColor: kPageBg,
        body: Center(child: CircularProgressIndicator(color: kPrimaryBlue)),
      );
    }

    final baseTheme = Theme.of(context);

    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: kFontFamily),
      ),
      child: Scaffold(
        backgroundColor: kPageBg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Brand Header ──
              const HospitalBrandHeader(useGradient: true),

              // ── Konten Scrollable ──
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Judul + Subtitle
                        const JadwalHeader(),
                        const SizedBox(height: 20),

                        // 2. Section "Jadwal Dokter" + Label
                        _buildSectionTitle(),
                        const SizedBox(height: 14),

                        // 3. Search Bar
                        JadwalSearchBar(
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                        const SizedBox(height: 16),

                        // 4. Date Strip
                        JadwalDateStrip(
                          selectedDate: _selectedDate,
                          onDateSelected: (date) {
                            setState(() => _selectedDate = date);
                          },
                        ),
                        const SizedBox(height: 14),

                        // 5. Poli Filter Chips
                        JadwalPoliFilter(
                          poliList: _poliList,
                          selectedPoli: _selectedPoli,
                          onPoliSelected: (poli) {
                            setState(() => _selectedPoli = poli);
                          },
                        ),
                        const SizedBox(height: 20),

                        // 6. Daftar Dokter
                        JadwalDokterList(dokterList: _filteredDokter),
                        const SizedBox(height: 20),

                        // 7. Footer Note
                        const JadwalFooterNote(),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom Navigation ──
              if (!widget.embedded)
                AppBottomNav(
                  selectedIndex: 3,
                  onItemSelected: (index) {
                    if (index == 3) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                      arguments: {'initialIndex': index},
                    );
                  },
                  onDaftarPressed: () {
                    Navigator.pushNamed(context, AppRoutes.pendaftaran);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }


  /// Sub-header section "Jadwal Dokter" dengan label keterangan.
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Jadwal Dokter',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kInk,
            ),
          ),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: kGreenStatus,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Data Terkini',
                style: TextStyle(
                  fontSize: 12,
                  color: kGreenStatus,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
