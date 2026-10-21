import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/home_screen.dart';
import 'package:pku_gamping_app/widgets/top_notification.dart';

const _primaryBlue = Color(0xFF0D4FC1);
const _deepBlue = Color(0xFF073F9F);
const _ink = Color(0xFF202124);
const _muted = Color(0xFF777F91);
const _page = Color(0xFFF6F8FA);

class QueueDetailScreen extends StatelessWidget {
  const QueueDetailScreen({super.key, this.onCancel, this.onContact});

  final VoidCallback? onCancel;
  final VoidCallback? onContact;

  Future<void> _showHelp(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(
            context,
          ).textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
        ),
        child: AlertDialog(
          title: const Text('Bantuan antrean'),
          content: const Text(
            'Siapkan berkas identitas dan kartu pasien. '
            'Untuk kendala antrean, hubungi petugas informasi RS PKU.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(
            context,
          ).textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
        ),
        child: AlertDialog(
          title: const Text('Batalkan antrean?'),
          content: const Text(
            'Apakah anda yakin ingin membatalkan antrean saat ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Kembali'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Batalkan'),
            ),
          ],
        ),
      ),
    );

    if (shouldCancel == true) {
  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const HomeScreen(
        notification: TopNotificationType.queueCancelled,
      ),
    ),
    (route) => false,
  );
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
        backgroundColor: _page,
        body: SafeArea(
          child: Column(
            children: [
              _DetailHeader(onHelpPressed: () => _showHelp(context)),
              Expanded(
                child: ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _QueueNumberCard(),
                      const SizedBox(height: 24),
                      const _VisitInformationCard(),
                      const SizedBox(height: 26),
                      SizedBox(
                        height: 52,
                        child: TextButton(
                          onPressed: () => _confirmCancel(context),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF0F2F5),
                            foregroundColor: const Color(0xFF454B59),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded, size: 21),
                              SizedBox(width: 5),
                              Text(
                                'Batalkan Antrean',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Kendala antrean atau perubahan data jadwal?',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                      TextButton.icon(
                        onPressed:
                            onContact ??
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Silakan hubungi petugas informasi RS PKU.',
                                  ),
                                ),
                              );
                            },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF315BB2),
                          padding: const EdgeInsets.symmetric(vertical: 2),
                        ),
                        icon: const Icon(Icons.support_agent, size: 18),
                        label: const Text(
                          'Hubungi Petugas Informasi RS PKU',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.onHelpPressed});

  final VoidCallback onHelpPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: _page,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back_rounded, color: _ink, size: 27),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RS PKU GAMPING',
                    style: TextStyle(
                      color: Color(0xFF263247),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Detail Antre',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 18,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onHelpPressed,
            tooltip: 'Bantuan',
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFF454B59),
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueNumberCard extends StatelessWidget {
  const _QueueNumberCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NOMOR ANTREAN ANDA',
            style: TextStyle(
              color: Color(0xFF454B59),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Poli Penyakit Dalam',
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 23),
          const Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'A-023',
                style: TextStyle(
                  color: _deepBlue,
                  fontSize: 58,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF795500),
                size: 17,
              ),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Siapkan berkas identitas & kartu pasien',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF454B59), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: _deepBlue, size: 19),
                SizedBox(width: 5),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: _primaryBlue,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: 'Silakan bersiap di ruang tunggu '),
                        TextSpan(
                          text: 'Poli Penyakit Dalam Lantai 2',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' saat antrean mencapai '),
                        TextSpan(
                          text: 'A-022.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitInformationCard extends StatelessWidget {
  const _VisitInformationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 25, 20, 23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Informasi Kunjungan',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF0F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'BPJS Kesehatan',
                  style: TextStyle(
                    color: Color(0xFF454B59),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          const _VisitInformationRow(
            icon: Icons.add_box_outlined,
            iconColor: _deepBlue,
            iconBackground: Color(0xFFDCE4FF),
            label: 'Poliklinik',
            value: 'Poli Penyakit Dalam',
          ),
          const SizedBox(height: 15),
          const _VisitInformationRow(
            icon: Icons.medical_services_outlined,
            iconColor: _primaryBlue,
            iconBackground: Color(0xFFDCE4FF),
            label: 'Dokter Pemeriksa',
            value: 'dr. Ahmad, Sp.PD',
          ),
          const SizedBox(height: 15),
          const _VisitInformationRow(
            icon: Icons.calendar_today_outlined,
            iconColor: Color(0xFF454B59),
            iconBackground: Color(0xFFE8E9EB),
            label: 'Waktu Periksa',
            value: 'Rabu, 07 Oktober 2026 • 10:30 WIB',
          ),
          const SizedBox(height: 15),
          const _VisitInformationRow(
            icon: Icons.location_on_outlined,
            iconColor: Color(0xFF795500),
            iconBackground: Color(0xFFFFDEA3),
            label: 'Lokasi Pelayanan',
            value: 'Ruang Poli 204 • Gedung Rawat Jalan Lt. 2',
          ),
        ],
      ),
    );
  }
}

class _VisitInformationRow extends StatelessWidget {
  const _VisitInformationRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 21),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
