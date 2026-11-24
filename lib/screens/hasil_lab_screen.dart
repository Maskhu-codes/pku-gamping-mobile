import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/services/pemeriksaan_penunjang_service.dart';
import 'package:pku_gamping_app/widgets/app_empty_state.dart';

/// Halaman Hasil Pemeriksaan Laboratorium RS PKU Gamping.
///
/// Terhubung langsung ke SIMRS via `GET /penunjang/laboratorium` untuk daftar hasil
/// dan `GET /penunjang/laboratorium_detail` untuk rincian parameter pemeriksaan.
class HasilLabScreen extends StatefulWidget {
  const HasilLabScreen({super.key, this.results = const []});

  final List<LabResult> results;

  @override
  State<HasilLabScreen> createState() => _HasilLabScreenState();
}

class _HasilLabScreenState extends State<HasilLabScreen> {
  final List<LabResult> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.results.isNotEmpty) {
      _items.addAll(widget.results);
    } else {
      _fetchLabResults();
    }
  }

  Future<void> _fetchLabResults() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final data = await PemeriksaanPenunjangService.getHasilLab(page: 1);
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
              const _LaboratoryHeader(),
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
    if (_isLoading && _items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Memuat hasil laboratorium...',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _items.isEmpty) {
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
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchLabResults,
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
        onRefresh: _fetchLabResults,
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
      onRefresh: _fetchLabResults,
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
              title: 'Hasil Laboratorium',
              description: 'Lihat detail hasil pemeriksaan laboratorium Anda.',
            );
          }

          if (index == _items.length + 1) {
            return const _SynchronizationNotice();
          }

          final itemIndex = index - 1;
          final result = _items[itemIndex];
          return _ResultCard(
            key: Key('lab_card_$itemIndex'),
            result: result,
            onTap: () => LabDetailModal.show(context, result),
          );
        },
      ),
    );
  }
}

class _LaboratoryHeader extends StatelessWidget {
  const _LaboratoryHeader();

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
            'Laboratorium',
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
        icon: Icons.science_outlined,
        title: 'Belum Ada Hasil Laboratorium',
        message: 'Hasil pemeriksaan laboratorium Anda belum tersedia.',
        circleSize: 76,
        iconSize: 36,
        circleBackgroundColor: Color(0xFFEFF6FF),
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
  const _ResultCard({super.key, required this.result, this.onTap});

  final LabResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: const Color(0x16000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ResultIcon(),
              const SizedBox(width: 14),
              Expanded(child: _ResultInformation(result: result)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
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
        Icons.science_outlined,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}

class _ResultInformation extends StatelessWidget {
  const _ResultInformation({required this.result});

  final LabResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        _ResultMetadata(result: result),
      ],
    );
  }
}

class _ResultMetadata extends StatelessWidget {
  const _ResultMetadata({required this.result});

  final LabResult result;

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
              'Sinkronisasi otomatis dengan SIMRS PKU Gamping',
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

/// Modal Bottom Sheet Rincian Parameter Laboratorium (`GET /penunjang/laboratorium_detail`).
class LabDetailModal extends StatefulWidget {
  const LabDetailModal({super.key, required this.result});

  final LabResult result;

  static void show(BuildContext context, LabResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LabDetailModal(result: result),
    );
  }

  @override
  State<LabDetailModal> createState() => _LabDetailModalState();
}

class _LabDetailModalState extends State<LabDetailModal> {
  bool _isLoading = true;
  String? _errorMessage;
  List<LabParameterDetail> _details = [];

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await PemeriksaanPenunjangService.getLaboratoriumDetail(
        widget.result.kdTrs,
      );
      if (mounted) {
        setState(() {
          _details = data;
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
    return Container(
      key: const Key('lab_detail_modal'),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Modal
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.biotech_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Hasil Laboratorium',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.result.kdTrs.isNotEmpty ? "ID: ${widget.result.kdTrs} • " : ""}${widget.result.date}',
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
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Body Modal: Parameter Details
          Expanded(
            child: _buildModalBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildModalBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Memuat rincian parameter laboratorium...',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
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
                size: 40,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _fetchDetail,
                icon: const Icon(Icons.refresh, size: 16),
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

    if (_details.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Belum ada rincian parameter untuk pemeriksaan ini.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _details.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final param = _details[index];
        return _buildParameterCard(param, index);
      },
    );
  }

  Widget _buildParameterCard(LabParameterDetail param, int index) {
    Color flagBg;
    Color flagTextColor;
    String flagLabel;

    if (param.isHigh) {
      flagBg = const Color(0xFFFEE2E2);
      flagTextColor = const Color(0xFFDC2626);
      flagLabel = 'Tinggi';
    } else if (param.isLow) {
      flagBg = const Color(0xFFDBEAFE);
      flagTextColor = const Color(0xFF2563EB);
      flagLabel = 'Rendah';
    } else {
      flagBg = const Color(0xFFDCFCE7);
      flagTextColor = const Color(0xFF16A34A);
      flagLabel = 'Normal';
    }

    return Container(
      key: Key('param_card_$index'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Parameter & Flag Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  param.pemeriksaan,
                  key: Key('param_pemeriksaan_$index'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Badge Flag Status (H/L/N)
              Container(
                key: Key('param_flag_$index'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: flagBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      param.flag,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: flagTextColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($flagLabel)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: flagTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Hasil, Satuan, dan Nilai Rujukan
          Row(
            children: [
              // Kolom Hasil & Satuan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HASIL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          param.hasil,
                          key: Key('param_hasil_$index'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: param.isHigh
                                ? const Color(0xFFDC2626)
                                : (param.isLow
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF0F172A)),
                          ),
                        ),
                        if (param.satuan.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            param.satuan,
                            key: Key('param_satuan_$index'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Kolom Nilai Rujukan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NILAI RUJUKAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      param.nilaiRujukan.isNotEmpty ? param.nilaiRujukan : '-',
                      key: Key('param_rujukan_$index'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
