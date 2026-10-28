import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/models/hasil_pemeriksaan_model.dart';
import 'package:pku_gamping_app/widgets/app_empty_state.dart';

/// Halaman Hasil Pemeriksaan Radiologi RS PKU Gamping
class HasilRadiologiScreen extends StatelessWidget {
  const HasilRadiologiScreen({super.key, this.results = const []});

  final List<RadiologyResult> results;

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
      child: SingleChildScrollView(
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
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results});

  final List<RadiologyResult> results;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      children: [
        const _ResultsIntro(
          title: 'Hasil Radiologi',
          description: 'Lihat detail hasil pemeriksaan radiologi Anda.',
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
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final RadiologyResult result;

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
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ResultIcon(),
              const SizedBox(width: 14),
              Expanded(child: _ResultInformation(result: result)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 12),
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEFF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.medical_services_outlined,
        color: AppColors.primary,
        size: 25,
      ),
    );
  }
}

class _ResultInformation extends StatelessWidget {
  const _ResultInformation({required this.result});

  final RadiologyResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AvailableBadge(),
        const SizedBox(height: 8),
        Text(
          result.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        _ResultMetadata(result: result),
      ],
    );
  }
}

class _AvailableBadge extends StatelessWidget {
  const _AvailableBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

class _ResultMetadata extends StatelessWidget {
  const _ResultMetadata({required this.result});

  final RadiologyResult result;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          color: AppColors.textMuted,
          size: 14,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            result.date,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(
          Icons.access_time_rounded,
          color: AppColors.textMuted,
          size: 15,
        ),
        const SizedBox(width: 5),
        Text(
          result.time,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
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
