import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/models/pendaftaran_model.dart';
import 'package:pku_gamping_app/services/pendaftaran_service.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';
import 'package:pku_gamping_app/widgets/app_bottom_nav.dart';
import 'package:pku_gamping_app/widgets/guest/guest_guard.dart';
import 'package:pku_gamping_app/widgets/hospital_brand_header.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';
import 'jadwal_widgets/jadwal_constants.dart';
import 'jadwal_widgets/jadwal_date_strip.dart';
import 'jadwal_widgets/jadwal_dokter_list.dart';
import 'jadwal_widgets/jadwal_footer_note.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'jadwal_widgets/jadwal_header.dart';
import 'jadwal_widgets/jadwal_poli_filter.dart';
import 'jadwal_widgets/jadwal_search_bar.dart';

/// Cache jadwal dokter (beserta slot 45 hari) untuk satu poliklinik.
class _DokterWithSlots {
  const _DokterWithSlots({
    required this.dokter,
    required this.slots,
  });

  final DokterPendaftaranModel dokter;
  final List<JadwalSlotModel> slots;
}

/// ─── Halaman Jadwal Dokter ───
///
/// Screen utama yang terintegrasi penuh dengan API SIMRS RS PKU Gamping:
/// - `GET /layanan/list` untuk daftar poliklinik
/// - `GET /dokter/list?fs_kd_layanan=...` untuk daftar dokter pada poli terpilih
/// - `GET /jadwal/list?fs_kd_layanan=...&fs_kd_petugas_medis=...` untuk jadwal 45 hari
class JadwalScreen extends StatefulWidget {
  const JadwalScreen({
    super.key,
    this.embedded = false,
    this.isGuestMode = false,
  });

  final bool embedded;
  final bool isGuestMode;

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  late DateTime _selectedDate;
  String _searchQuery = '';
  bool _localeInitialized = false;

  // State data SIMRS
  List<PoliModel> _listPoli = [];
  PoliModel? _selectedPoli;
  bool _isLoadingPoli = true;
  bool _isLoadingJadwal = false;
  String? _errorMessage;

  // Cache dokter & slot 45 hari per fs_kd_layanan agar ganti tanggal/poli cepat
  final Map<String, List<_DokterWithSlots>> _poliJadwalCache = {};
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _initializeLocale();
    _muatDaftarPoli();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    if (mounted) {
      setState(() => _localeInitialized = true);
    }
  }

  /// Memuat daftar poliklinik asli dari SIMRS (`GET /layanan/list`)
  /// lalu otomatis memuat jadwal dokter untuk poli pertama yang tersedia.
  Future<void> _muatDaftarPoli({bool forceRefresh = false}) async {
    setState(() {
      _isLoadingPoli = true;
      _errorMessage = null;
    });

    try {
      final listPoli = await PendaftaranService.getListPoli();
      if (!mounted) return;

      PoliModel? nextPoli = _selectedPoli;
      if (nextPoli == null ||
          !listPoli.any((p) => p.id == nextPoli!.id)) {
        nextPoli = listPoli.isNotEmpty ? listPoli.first : null;
      }

      setState(() {
        _listPoli = listPoli;
        _selectedPoli = nextPoli;
        _isLoadingPoli = false;
      });

      if (nextPoli != null) {
        await _muatJadwalPoli(nextPoli, forceRefresh: forceRefresh);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPoli = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  /// Memuat daftar dokter dan slot jadwal 45 hari untuk satu poli terpilih.
  Future<void> _muatJadwalPoli(
    PoliModel poli, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _poliJadwalCache.containsKey(poli.id)) {
      setState(() {
        _selectedPoli = poli;
        _isLoadingJadwal = false;
        _errorMessage = null;
      });
      return;
    }

    final requestId = ++_loadRequestId;
    setState(() {
      _selectedPoli = poli;
      _isLoadingJadwal = true;
      _errorMessage = null;
    });

    try {
      final doctors = await PendaftaranService.getListDokter(poliId: poli.id);
      if (!mounted || requestId != _loadRequestId) return;

      final dokterWithSlots = await Future.wait(
        doctors.map((dokter) async {
          try {
            final slots = await SimrsService.getJadwalDokter(
              fsKdLayanan: poli.id,
              fsKdPetugasMedis: dokter.id,
            );
            return _DokterWithSlots(dokter: dokter, slots: slots);
          } catch (e) {
            debugPrint(
              '[JadwalScreen] Gagal memuat jadwal dokter ${dokter.id}: $e',
            );
            return _DokterWithSlots(dokter: dokter, slots: const []);
          }
        }),
      );

      if (!mounted || requestId != _loadRequestId) return;

      setState(() {
        _poliJadwalCache[poli.id] = dokterWithSlots;
        _isLoadingJadwal = false;
      });
    } catch (e) {
      if (!mounted || requestId != _loadRequestId) return;
      setState(() {
        _isLoadingJadwal = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _handleRefresh() async {
    _poliJadwalCache.clear();
    if (_listPoli.isEmpty || _selectedPoli == null) {
      await _muatDaftarPoli(forceRefresh: true);
    } else {
      await _muatJadwalPoli(_selectedPoli!, forceRefresh: true);
    }
  }

  StatusDokter _mapSlotStatus(JadwalSlotModel slot) {
    if (slot.isClosed) return StatusDokter.tutup;
    if (slot.isPenuh) return StatusDokter.penuh;
    if (slot.canBook) return StatusDokter.tersedia;
    return StatusDokter.selesai;
  }

  ({String mulai, String selesai}) _extractJamRange(JadwalSlotModel slot) {
    final cleanedJam = slot.jam.replaceAll('WIB', '').trim();
    if (cleanedJam.contains('-')) {
      final parts = cleanedJam.split('-');
      final mulai = parts.first.trim();
      final selesai = parts.length > 1 ? parts[1].trim() : '';
      if (mulai.isNotEmpty) {
        return (mulai: mulai, selesai: selesai);
      }
    }
    final fallbackMulai =
        slot.jamMulai.trim().isNotEmpty ? slot.jamMulai.trim() : cleanedJam;
    return (mulai: fallbackMulai, selesai: '');
  }

  /// Memfilter jadwal dokter SIMRS berdasarkan poli aktif, tanggal terpilih, dan pencarian.
  List<DokterJadwal> get _filteredDokter {
    final poli = _selectedPoli;
    if (poli == null) return const [];

    final cached = _poliJadwalCache[poli.id];
    if (cached == null || cached.isEmpty) return const [];

    final targetDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final query = _searchQuery.trim().toLowerCase();
    final results = <DokterJadwal>[];

    for (final entry in cached) {
      final dokter = entry.dokter;
      if (query.isNotEmpty) {
        final matchNama = dokter.nama.toLowerCase().contains(query);
        final matchPoli = poli.nama.toLowerCase().contains(query);
        if (!matchNama && !matchPoli) continue;
      }

      final matchingSlots = entry.slots.where(
        (slot) => slot.tanggal.trim() == targetDateStr,
      );

      for (final slot in matchingSlots) {
        final jamRange = _extractJamRange(slot);
        results.add(
          DokterJadwal(
            nama: dokter.nama,
            poli: poli.nama,
            jamMulai: jamRange.mulai,
            jamSelesai: jamRange.selesai,
            fotoUrl: dokter.fotoUrl,
            status: _mapSlotStatus(slot),
            fsKdLayanan: poli.id,
            fsKdPetugasMedis: dokter.id,
          ),
        );
      }
    }

    return results;
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
    final poliNames = _listPoli.map((p) => p.nama).toList();

    final isGuest = widget.isGuestMode || (SessionManager.isGuest && !widget.embedded);

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
              HospitalBrandHeader(
                useGradient: true,
                leadingWidget: isGuest
                    ? IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                        color: kInk,
                        onPressed: () {
                          SessionManager.setGuestMode(false);
                          Navigator.of(context).pop();
                        },
                      )
                    : null,
                trailingWidget: isGuest
                    ? TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        icon: const Icon(Icons.login_rounded, size: 16),
                        label: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: kPrimaryBlue,
                          backgroundColor: const Color(0xFFEFF6FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    : null,
              ),

              // ── Banner Mode Tamu ──
              if (isGuest)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFDBEAFE), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Color(0xFF0D4FC1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Mode Tamu: Anda dapat melihat jadwal & poli. Masuk untuk mendaftar antrean.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E40AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Konten Scrollable ──
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: kPrimaryBlue,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(overscroll: false),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
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

                          // 5. Poli Filter Chips (Real SIMRS /layanan/list)
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: _isLoadingPoli
                                ? const PoliChipsSkeleton(
                                    key: ValueKey('poli_chips_skeleton'),
                                  )
                                : poliNames.isNotEmpty
                                    ? JadwalPoliFilter(
                                        key: const ValueKey('poli_chips_data'),
                                        poliList: poliNames,
                                        selectedPoli: _selectedPoli?.nama ?? '',
                                        includeAllOption: false,
                                        onPoliSelected: (poliNama) {
                                          final target = _listPoli.firstWhere(
                                            (p) => p.nama == poliNama,
                                            orElse: () => _listPoli.first,
                                          );
                                          _muatJadwalPoli(target);
                                        },
                                      )
                                    : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 20),

                          // 6. Daftar Dokter / Loading / Error State
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: _buildJadwalContent(),
                          ),
                          const SizedBox(height: 20),

                          // 7. Footer Note
                          const JadwalFooterNote(),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom Navigation atau Sticky Action untuk Tamu ──
              if (!widget.embedded && !isGuest)
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
                    if (!GuestGuard.check(
                      context,
                      featureName: 'pendaftaran layanan',
                      message:
                          'Untuk melakukan booking jadwal dokter dan pendaftaran layanan, Anda harus masuk ke akun pasien terlebih dahulu.',
                    )) {
                      return;
                    }
                    Navigator.pushNamed(context, AppRoutes.pendaftaran);
                  },
                )
              else if (isGuest)
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        icon: const Icon(Icons.login_rounded, size: 20),
                        label: const Text(
                          'Masuk untuk Mendaftar Antrean',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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

  Widget _buildJadwalContent() {
    if (_isLoadingPoli || _isLoadingJadwal) {
      return const JadwalDokterListSkeleton(
        key: ValueKey('jadwal_content_loading'),
      );
    }

    if (_errorMessage != null) {
      return Container(
        key: const ValueKey('jadwal_content_error'),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kCardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal Memuat Jadwal',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kInk,
                fontFamily: kFontFamily,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: kMuted,
                height: 1.4,
                fontFamily: kFontFamily,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_listPoli.isEmpty || _selectedPoli == null) {
                  _muatDaftarPoli(forceRefresh: true);
                } else {
                  _muatJadwalPoli(_selectedPoli!, forceRefresh: true);
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return JadwalDokterList(dokterList: _filteredDokter);
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
