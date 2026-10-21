import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'jadwal_widgets/jadwal_constants.dart';
import 'jadwal_widgets/jadwal_header.dart';
import 'jadwal_widgets/jadwal_search_bar.dart';
import 'jadwal_widgets/jadwal_date_strip.dart';
import 'jadwal_widgets/jadwal_poli_filter.dart';
import 'jadwal_widgets/jadwal_dokter_list.dart';
import 'jadwal_widgets/jadwal_footer_note.dart';
import 'jadwal_widgets/jadwal_bottom_nav.dart';

/// ─── Data Dummy Jadwal Dokter ───
/// Data statis sebagai placeholder sebelum disambungkan ke API.
const _dummyDokter = <DokterJadwal>[
  DokterJadwal(
    nama: 'dr. H. Ahmad Farhan, Sp.PD',
    poli: 'Poli Penyakit Dalam',
    jamMulai: '09.00',
    jamSelesai: '12.00',
    status: StatusDokter.tersedia,
  ),
  DokterJadwal(
    nama: 'dr. Siti Nurhaliza, Sp.JP',
    poli: 'Poli Jantung',
    jamMulai: '10.00',
    jamSelesai: '13.00',
    status: StatusDokter.tersedia,
  ),
  DokterJadwal(
    nama: 'dr. Budi Santoso, Sp.A',
    poli: 'Poli Anak',
    jamMulai: '08.00',
    jamSelesai: '11.00',
    status: StatusDokter.selesai,
  ),
  DokterJadwal(
    nama: 'dr. Rina Kusuma, Sp.M',
    poli: 'Poli Mata',
    jamMulai: '13.00',
    jamSelesai: '16.00',
    status: StatusDokter.tersedia,
  ),
  DokterJadwal(
    nama: 'dr. Dewi Anggraini, Sp.PD',
    poli: 'Poli Penyakit Dalam',
    jamMulai: '14.00',
    jamSelesai: '17.00',
    status: StatusDokter.tersedia,
  ),
  DokterJadwal(
    nama: 'dr. Hendra Wijaya, Sp.B',
    poli: 'Poli Bedah',
    jamMulai: '08.00',
    jamSelesai: '12.00',
    status: StatusDokter.cuti,
  ),
];

/// Daftar poli unik dari data dokter.
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
  const JadwalScreen({super.key});

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
              // ── Brand Header (reuse dari pola home) ──
              _buildBrandHeader(),

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
              const JadwalBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  /// Brand header RS PKU Gamping — konsisten dengan halaman lain.
  Widget _buildBrandHeader() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4F7FC), Color(0xFFD2DEF2)],
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo_pkugamping.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RS PKU Gamping',
                  style: TextStyle(
                    color: kInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Portal Pasien',
                  style: TextStyle(color: kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: kInk,
                  size: 22,
                ),
                onPressed: () {
                  // TODO: Buka notifikasi
                },
              ),
              Positioned(
                top: 11,
                right: 11,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: kPrimaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ],
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
