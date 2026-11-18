import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/services/pemeriksaan_penunjang_service.dart';
import 'package:pku_gamping_app/widgets/app_empty_state.dart';

/// Halaman Hasil Pemeriksaan Radiologi RS PKU Gamping.
///
/// Terhubung langsung ke SIMRS via `GET /penunjang/radiologi?fs_mr=<dari_session>`.
/// Menampilkan: tanggal, nama tindakan, keterangan hasil ekspertise, dan link foto PACS.
class HasilRadiologiScreen extends StatefulWidget {
  const HasilRadiologiScreen({super.key, this.results = const []});

  final List<RadiologyResult> results;

  @override
  State<HasilRadiologiScreen> createState() => _HasilRadiologiScreenState();
}

class _HasilRadiologiScreenState extends State<HasilRadiologiScreen> {
  final List<RadiologyResult> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.results.isNotEmpty) {
      _items.addAll(widget.results);
    } else {
      _fetchRadiologi();
    }
  }

  Future<void> _fetchRadiologi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await PemeriksaanPenunjangService.getHasilRadiologi();
      if (mounted) {
        setState(() {
          _items
            ..clear()
            ..addAll(data);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _RadiologyHeader(),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memuat hasil pemeriksaan radiologi...',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchRadiologi,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchRadiologi,
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: _EmptyResults(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRadiologi,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        itemCount: _items.length + 2, // header + items + notice
        separatorBuilder: (context, index) {
          if (index == 0 || index == _items.length) {
            return const SizedBox(height: 16);
          }
          return const SizedBox(height: 14);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _ResultsIntro(
              title: 'Hasil Radiologi',
              description: 'Lihat detail hasil pemeriksaan radiologi Anda.',
            );
          }

          if (index == _items.length + 1) {
            return const _SynchronizationNotice();
          }

          final itemIndex = index - 1;
          final result = _items[itemIndex];
          return _ResultCard(
            key: Key('radiologi_card_$itemIndex'),
            result: result,
            index: itemIndex,
          );
        },
      ),
    );
  }
}

class _RadiologyHeader extends StatelessWidget {
  const _RadiologyHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Kembali',
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textPrimary,
              size: 30,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Radiologi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppEmptyState(
        icon: Icons.medical_services_outlined,
        title: 'Belum Ada Hasil Radiologi',
        message: 'Hasil pemeriksaan radiologi Anda belum tersedia.',
        circleSize: 100,
        iconSize: 48,
        circleBackgroundColor: Color(0xFFDCE4FF),
        action: Padding(
          padding: EdgeInsets.only(top: 24),
          child: _SynchronizationNotice(),
        ),
      ),
    );
  }
}

class _ResultsIntro extends StatelessWidget {
  const _ResultsIntro({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    super.key,
    required this.result,
    required this.index,
  });

  final RadiologyResult result;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: const Color(0x16000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showDetailModal(context, result),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card: Icon, Judul Tindakan, & Panah
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ResultIcon(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.title,
                          key: Key('radiologi_title_$index'),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _ResultMetadata(result: result, index: index),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ],
              ),

              // Keterangan Hasil Ekspertise Dokter
              if (result.keterangan.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KETERANGAN / EKSPERTISE:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.keterangan,
                        key: Key('radiologi_keterangan_$index'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Link Foto Hasil PACS
              if (result.urlFoto.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        result.urlFoto,
                        key: Key('radiologi_link_foto_$index'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailModal(BuildContext context, RadiologyResult item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          key: const Key('radiologi_detail_modal'),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          item.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Hasil Pemeriksaan / Ekspertise Dokter:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.keterangan.isNotEmpty
                    ? item.keterangan
                    : 'Tidak ada catatan tambahan untuk pemeriksaan ini.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF334155),
                  height: 1.5,
                ),
              ),
              if (item.urlFoto.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Tautan Citra Medis (PACS):',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  item.urlFoto,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ResultIcon extends StatelessWidget {
  const _ResultIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.medical_services_outlined,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}

class _ResultMetadata extends StatelessWidget {
  const _ResultMetadata({required this.result, required this.index});

  final RadiologyResult result;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          color: AppColors.textMuted,
          size: 13,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            result.date,
            key: Key('radiologi_date_$index'),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        if (result.time.isNotEmpty) ...[
          const SizedBox(width: 10),
          const Icon(
            Icons.access_time_rounded,
            color: AppColors.textMuted,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            result.time,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class _SynchronizationNotice extends StatelessWidget {
  const _SynchronizationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEDEF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: AppColors.primary, size: 10),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Sinkronisasi otomatis dengan rekam medis SIMRS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF454B59),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
