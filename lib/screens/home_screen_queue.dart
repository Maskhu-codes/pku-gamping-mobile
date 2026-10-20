import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/queue_detail_screen.dart';
import 'package:pku_gamping_app/screens/queue_screen.dart';
import 'package:pku_gamping_app/screens/riwayat_screen.dart';
import 'package:pku_gamping_app/screens/test_results.dart';
import 'package:pku_gamping_app/widgets/top_notification.dart';

const _primaryBlue = Color(0xFF0D4FC1);
const _ink = Color(0xFF182238);
const _muted = Color(0xFF91A3BE);
const _page = Color(0xFFF7F9FC);
const bool tampilkanRiwayat = true; // Ubah menjadi false untuk menyembunyikan menu Riwayat

class HomeScreenQueue extends StatefulWidget {
  final TopNotificationType? notification;

  const HomeScreenQueue({
    super.key,
    this.notification,
  });

  @override
  State<HomeScreenQueue> createState() =>
      _HomeScreenQueueState();
}

class _HomeScreenQueueState extends State<HomeScreenQueue> {
  int _selectedIndex = 0;

  @override

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.notification == null) return;

      TopNotification.show(
        context,
        type: widget.notification!,
      );
    });
  }
  
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      child: Scaffold(
        backgroundColor: _page,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _BrandHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _WelcomeAndQueue(),
                      _QuickLinks(),
                      _NewsSection(),
                      _EmergencyContact(),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              _BottomNavigation(
        selectedIndex: _selectedIndex,
        onSelected: (index) {
          if (index == 1) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const QueueScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  },
)
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () =>
                    _showMessage(context, 'Tidak ada notifikasi baru.'),
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

class _WelcomeAndQueue extends StatelessWidget {
  const _WelcomeAndQueue();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 292,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(60)),
            ),
          ),
          Positioned(
            top: 11,
            left: 34,
            right: 28,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB7B7B7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat pagi,',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        'Dahlan Muda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'No. RM: 01-88-24-90  •',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 90,
            left: 25,
            right: 25,
            child: _ActiveQueueCard(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const QueueDetailScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveQueueCard extends StatelessWidget {
  const _ActiveQueueCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD5DBE5), width: 1.3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D17233B),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _QueueTag(
                label: 'Poli Jantung',
                foreground: _primaryBlue,
                background: const Color(0xFFF0F5FF),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Gedung A • Lt. 2',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ),
              const SizedBox(width: 6),
              const _QueueTag(
                label: 'Antrean Berjalan',
                foreground: Color(0xFFE57B00),
                background: Color(0xFFFFFAEE),
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'NOMOR ANTREAN ANDA',
              style: TextStyle(color: _muted, fontSize: 12, letterSpacing: 0.3),
            ),
          ),
          const Divider(height: 6, color: Color(0xFFF0F2F6)),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'A-023',
              style: TextStyle(
                color: _primaryBlue,
                fontSize: 54,
                height: 1.05,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              children: [
                Icon(Icons.medical_services_outlined, color: _muted, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'dr. Ahmad Ridwan, Sp.JP',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF35445D),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '09:30 WIB',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pantau Antrean Langsung',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 21),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueTag extends StatelessWidget {
  const _QueueTag({
    required this.label,
    required this.foreground,
    required this.background,
    this.showDot = false,
  });

  final String label;
  final Color foreground;
  final Color background;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: showDot ? 8 : 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 54),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _QuickLink(
            icon: Icons.biotech_outlined,
            label: 'Hasil Lab',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TestResults(),
                ),
              );
            },
          ),

          const SizedBox(width: 42),

          _QuickLink(
            icon: Icons.description_outlined,
            label: 'Riwayat',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RiwayatScreen(
                    riwayat: tampilkanRiwayat
                        ? const [
                            RiwayatPemeriksaan(
                              tanggal: '20 Oktober 2026',
                              namaPemeriksaan: 'Pemeriksaan Umum',
                              poli: 'Poli Umum',
                              dokter: 'dr. Ahmad Ridwan',
                            ),
                            RiwayatPemeriksaan(
                              tanggal: '15 Oktober 2026',
                              namaPemeriksaan: 'Pemeriksaan Jantung',
                              poli: 'Poli Jantung',
                              dokter: 'dr. Budi Santoso',
                            ),
                          ]
                        : const [],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
Widget build(BuildContext context) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(17),
    child: Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE2E7EE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0817233B),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: _primaryBlue, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF35445D), fontSize: 14),
        ),
      ],
    ),
  );
  }
}

class _NewsSection extends StatelessWidget {
  const _NewsSection();

  static const _news = [
    (
      title: 'Layanan Kateterisasi Jantung 24 Jam di RS PKU Gamping',
      date: '24 Okt 2024',
    ),
    (title: 'Tips Menjaga Kesehatan untuk Lansia', date: '22 Okt 2024'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Informasi & Berita',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    _showMessage(context, 'Berita lainnya segera hadir.'),
                style: TextButton.styleFrom(
                  foregroundColor: _primaryBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 222,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: _news.length,
            separatorBuilder: (context, index) => const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final news = _news[index];
              return _NewsCard(title: news.title, date: news.date, imageUrl: 'https://picsum.photos/id/${index + 100}/400/300');
            },
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.title,
    required this.date,
    required this.imageUrl,
  });

  final String title;
  final String date;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE1E6EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 128,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE8F0F8),
                child: const Center(
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: _primaryBlue,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 13, 0),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 9, 13, 0),
            child: Text(
              date,
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContact extends StatelessWidget {
  const _EmergencyContact();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F8),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFFFDDE3)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFE91749),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emergency, color: Colors.white, size: 25),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IGD 24 Jam RS PKU',
                  style: TextStyle(
                    color: Color(0xFF5A1024),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '(0274) 6499118',
                  style: TextStyle(color: Color(0xFFE91749), fontSize: 11),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () =>
                _showMessage(context, 'Hubungi IGD RS PKU: (0274) 6499118'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE91749),
              side: const BorderSide(color: Color(0xFFFFBFCB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Hubungi', style: TextStyle(fontSize: 12)),
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
                            color: _primaryBlue,
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
                            color: selectedIndex == 2 ? _primaryBlue : _muted,
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
    final color = isSelected ? _primaryBlue : _muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
