import 'package:flutter/material.dart';

const _primaryBlue = Color(0xFF0D4FC1);
const _ink = Color(0xFF182238);
const _muted = Color(0xFF68758D);
const _page = Color(0xFFF6F8FA);

class RiwayatPemeriksaan {
  const RiwayatPemeriksaan({
    required this.tanggal,
    required this.namaPemeriksaan,
    required this.poli,
    required this.dokter,
  });

  final String tanggal;
  final String namaPemeriksaan;
  final String poli;
  final String dokter;
}

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key, this.riwayat = const [], this.onRiwayatTap});

  final List<RiwayatPemeriksaan> riwayat;
  final ValueChanged<RiwayatPemeriksaan>? onRiwayatTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      child: Scaffold(
        backgroundColor: _page,
        appBar: AppBar(
          backgroundColor: _page,
          foregroundColor: _ink,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Riwayat Pemeriksaan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFEFF1F4)),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Pemeriksaan',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pantau rekam jejak medis Anda.',
                    style: TextStyle(color: _muted, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: riwayat.isEmpty
                  ? const _EmptyHistory()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                      itemCount: riwayat.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = riwayat[index];
                        return _HistoryCard(
                          item: item,
                          onTap: onRiwayatTap == null
                              ? null
                              : () => onRiwayatTap!(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF29466F).withValues(alpha: 0.09),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.assignment_add,
                color: _primaryBlue,
                size: 38,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tidak Ada Riwayat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Anda belum memiliki riwayat\npemeriksaan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 16, height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, this.onTap});

  final RiwayatPemeriksaan item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: const Color(0x16000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 14, 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: _primaryBlue,
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.tanggal,
                            style: const TextStyle(
                              color: _primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.namaPemeriksaan,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _HistoryDetail(
                      icon: Icons.local_hospital_outlined,
                      label: item.poli,
                    ),
                    const SizedBox(height: 5),
                    _HistoryDetail(
                      icon: Icons.person_outline,
                      label: item.dokter,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F3F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: _muted,
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

class _HistoryDetail extends StatelessWidget {
  const _HistoryDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _muted, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _muted, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
