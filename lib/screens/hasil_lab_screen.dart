import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/models/hasil_pemeriksaan_model.dart';
import 'package:pku_gamping_app/widgets/app_empty_state.dart';

/// Halaman Hasil Pemeriksaan Laboratorium RS PKU Gamping
class HasilLabScreen extends StatelessWidget {
  const HasilLabScreen({super.key, this.results = const []});

  final List<LabResult> results;

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
                child: results.isEmpty
                    ? const _EmptyResults()
                    : _ResultsList(results: results),
              ),
            ],
          ),
        ),
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
      child: SingleChildScrollView(
        child: AppEmptyState(
          icon: Icons.science_outlined,
          title: 'Belum Ada Hasil Laboratorium',
          message: 'Hasil pemeriksaan laboratorium Anda belum tersedia.',
          circleSize: 100,
          iconSize: 48,
          circleBackgroundColor: Color(0xFFDCE4FF),
          action: Padding(
            padding: EdgeInsets.only(top: 24),
            child: _SynchronizationNotice(),
          ),
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results});

  final List<LabResult> results;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      children: [
        const Text(
          'Hasil Laboratorium',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Lihat detail hasil pemeriksaan laboratorium Anda.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        for (final result in results) ...[
          _ResultCard(result: result),
          const SizedBox(height: 18),
        ],
        const SizedBox(height: 2),
        const _SynchronizationNotice(),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final LabResult result;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 1,
      shadowColor: const Color(0x16000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Membuka hasil ${result.title}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(23, 22, 20, 21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${result.date} | ${result.time}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SynchronizationNotice extends StatelessWidget {
  const _SynchronizationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEDEF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: AppColors.primary, size: 12),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Sinkronisasi otomatis dengan rekam medis',
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
