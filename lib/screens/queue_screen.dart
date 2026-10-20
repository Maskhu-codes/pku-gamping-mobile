import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/queue_detail_screen.dart';

const _queueBlue = Color(0xFF0D4FC1);
const _queueInk = Color(0xFF202124);
const _queueMuted = Color(0xFF777F91);
const _queuePage = Color(0xFFF6F8FA);

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  bool _soundReminderEnabled = false;
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      child: Scaffold(
        backgroundColor: _queuePage,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _QueueBrandHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    children: [
                      const _DoctorSummaryCard(),
                      _ActiveQueueCard(
                        soundReminderEnabled: _soundReminderEnabled,
                        onSoundReminderChanged: (enabled) {
                          setState(() => _soundReminderEnabled = enabled);
                        },
                        onDetailsPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const QueueDetailScreen(),
                            ),
                          );
                        },
                      ),
                      const _RoomDirectionsCard(),
                      const _QueueServiceValueCard(),
                    ],
                  ),
                ),
              ),
              _BottomNavigation(
                selectedIndex: _selectedIndex,
                onSelected: (index) {
                  if (index == 0) {
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      _selectedIndex = index;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueBrandHeader extends StatelessWidget {
  const _QueueBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo_pkugamping.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
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
                    color: Color(0xFF263247),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Portal Pasien',
                  style: TextStyle(color: Color(0xFF91A3BE), fontSize: 12),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                tooltip: 'Notifikasi',
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF43516A),
                  size: 25,
                ),
              ),
              Positioned(
                right: 5,
                top: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2866E8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorSummaryCard extends StatelessWidget {
  const _DoctorSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D17233B),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EDF6),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF7890AC),
                  size: 42,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -3,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: Color(0xFF82A5FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFF063F99),
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    _DoctorBadge(
                      label: 'Ruang 204',
                      backgroundColor: Color(0xFFDCE4FF),
                      textColor: Color(0xFF092C68),
                    ),
                    _DoctorBadge(
                      label: 'Lantai 2',
                      backgroundColor: Color(0xFFE8E9EB),
                      textColor: Color(0xFF454B59),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'dr. Ahmad Ridwan, Sp.JP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _queueInk,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Poli Dalam',
                  style: TextStyle(color: _queueMuted, fontSize: 13),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF365FB6),
                      size: 16,
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Hari Ini, 24 Okt 2024',
                        style: TextStyle(color: _queueMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Sesi Pagi (08:30 - 12:00)',
                  style: TextStyle(
                    color: Color(0xFF063F99),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _DoctorBadge extends StatelessWidget {
  const _DoctorBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActiveQueueCard extends StatelessWidget {
  const _ActiveQueueCard({
    required this.soundReminderEnabled,
    required this.onSoundReminderChanged,
    required this.onDetailsPressed,
  });

  final bool soundReminderEnabled;
  final ValueChanged<bool> onSoundReminderChanged;
  final VoidCallback onDetailsPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            color: _queueBlue,
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFFFFD36A),
                  size: 23,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Panggilan Antrean Aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFFFFC32A), size: 10),
                      SizedBox(width: 5),
                      Text(
                        'Live Poli 204',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: _QueueNumberPanel(
                        label: 'NOMOR ANDA',
                        number: 'A-023',
                        caption: 'Pasien Terjadwal',
                        backgroundColor: Color(0xFFF0F2F5),
                        numberColor: Color(0xFF063F99),
                        labelColor: Color(0xFF777F91),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _QueueNumberPanel(
                        label: 'SEDANG DILAYANI',
                        number: 'A-019',
                        caption: 'Dalam Ruang 204',
                        backgroundColor: Color(0xFFFFF8EC),
                        numberColor: Color(0xFF795500),
                        labelColor: Color(0xFF795500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _QueueWaitStatus(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.volume_up_outlined,
                      color: Color(0xFF365FB6),
                      size: 23,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aktifkan Pengingat Suara',
                            style: TextStyle(
                              color: _queueInk,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Peringatan saat tersisa 2 antrean',
                            style: TextStyle(color: _queueMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: soundReminderEnabled,
                      onChanged: onSoundReminderChanged,
                      activeThumbColor: _queueBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: onDetailsPressed,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F2F5),
                      foregroundColor: _queueBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Detail Antrean',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 21),
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

class _QueueNumberPanel extends StatelessWidget {
  const _QueueNumberPanel({
    required this.label,
    required this.number,
    required this.caption,
    required this.backgroundColor,
    required this.numberColor,
    required this.labelColor,
  });

  final String label;
  final String number;
  final String caption;
  final Color backgroundColor;
  final Color numberColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              number,
              style: TextStyle(
                color: numberColor,
                fontSize: 34,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: numberColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueWaitStatus extends StatelessWidget {
  const _QueueWaitStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E7E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF063F99),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4 Pasien Lagi di Depan Anda',
                  style: TextStyle(
                    color: _queueInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Estimasi tunggu: ± 15 - 20 Menit',
                  style: TextStyle(color: _queueMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Segera Bersiap',
              style: TextStyle(
                color: Color(0xFF092C68),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomDirectionsCard extends StatelessWidget {
  const _RoomDirectionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF365FB6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.explore_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Petunjuk Menuju Ruang 204',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Lantai 2, Sayap Barat, Lift B',
                  style: TextStyle(color: Color(0xFFD9E3FA), fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _QueueServiceValueCard extends StatelessWidget {
  const _QueueServiceValueCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF82A5FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: Color(0xFF0D4FC1),
              size: 23,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NILAI LAYANAN SIGAP',
                  style: TextStyle(
                    color: Color(0xFF365FB6),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '"Dan apabila aku sakit, Dialah yang menyembuhkan aku." (QS. Asy-Syu\'ara: 80). Mohon tertib dan sabar selama menunggu giliran.',
                  style: TextStyle(
                    color: Color(0xFF454B59),
                    fontSize: 12,
                    height: 1.55,
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

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E6EE))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavigationItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isSelected: selectedIndex == 0,
                onTap: () => onSelected(0),
              ),
              _NavigationItem(
                icon: Icons.confirmation_number_outlined,
                label: 'Antrean',
                isSelected: selectedIndex == 1,
                onTap: () => onSelected(1),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(2),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -17),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: _queueBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -17),
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            color: selectedIndex == 2
                                ? _queueBlue
                                : const Color(0xFF91A3BE),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _NavigationItem(
                icon: Icons.calendar_month_outlined,
                label: 'Jadwal',
                isSelected: selectedIndex == 3,
                onTap: () => onSelected(3),
              ),
              _NavigationItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                isSelected: selectedIndex == 4,
                onTap: () => onSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _queueBlue : const Color(0xFF91A3BE);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
