import 'package:flutter/material.dart';

const _primaryBlue = Color(0xFF0D4FC1);
const _ink = Color(0xFF202124);
const _muted = Color(0xFF777F91);
const _page = Color(0xFFF6F8FA);

class TestLabResults extends StatelessWidget {
  const TestLabResults({super.key, this.results = const []});

  final List<LabResult> results;

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      child: Scaffold(
        backgroundColor: _page,
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

class LabResult {
  const LabResult({required this.title, required this.date, required this.time});

  final String title;
  final String date;
  final String time;
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
            icon: const Icon(Icons.chevron_left_rounded, color: _ink, size: 30),
          ),
          const SizedBox(width: 4),
          const Text(
            'Laboratorium',
            style: TextStyle(
              color: _ink,
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
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: SizedBox(
          height: constraints.maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCE4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.science_outlined,
                  color: _primaryBlue,
                  size: 48,
                ),
              ),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Belum Ada Hasil Laboratorium',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 29,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Hasil pemeriksaan laboratorium Anda belum tersedia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 18, height: 1.5),
                ),
              ),
              const SizedBox(height: 82),
              const _SynchronizationNotice(),
            ],
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
            color: _ink,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Lihat detail hasil pemeriksaan laboratorium Anda.',
          style: TextStyle(color: _muted, fontSize: 16, height: 1.4),
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
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${result.date} | ${result.time}',
                style: const TextStyle(color: _muted, fontSize: 16),
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
          Icon(Icons.circle, color: _primaryBlue, size: 12),
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
