import 'package:flutter/material.dart';

/// ─── Token Warna Beranda RS PKU Gamping ───
const Color kHomePrimaryBlue = Color(0xFF0D4FC1);
const Color kHomeInk = Color(0xFF182238);
const Color kHomeMuted = Color(0xFF91A3BE);
const Color kHomePageBg = Color(0xFFF7F9FC);
const Color kHomeCardBorder = Color(0xFFE1E6EE);
const Color kHomeDivider = Color(0xFFF0F2F6);

const String kHomeFontFamily = 'Plus Jakarta Sans';

/// Model Item Berita Beranda
class HomeNewsItem {
  final String title;
  final DateTime publishedAt;
  final String category;
  final IconData icon;

  HomeNewsItem({
    required this.title,
    required this.publishedAt,
    required this.category,
    required this.icon,
  });

  String get date {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${publishedAt.day} ${months[publishedAt.month - 1]} ${publishedAt.year}';
  }
}

/// Data Berita Dummy
final List<HomeNewsItem> kHomeNewsList = List<HomeNewsItem>.unmodifiable([
  HomeNewsItem(
    title: 'Layanan Kateterisasi Jantung 24 Jam di RS PKU Gamping',
    publishedAt: DateTime(2026, 10, 24),
    category: 'Layanan Baru',
    icon: Icons.favorite_border_rounded,
  ),
  HomeNewsItem(
    title: 'Tips Menjaga Kesehatan Jantung di Usia Produktif',
    publishedAt: DateTime(2026, 10, 22),
    category: 'Edukasi',
    icon: Icons.health_and_safety_outlined,
  ),
  HomeNewsItem(
    title: 'Jadwal Poliklinik Rawat Jalan Selama Libur Nasional',
    publishedAt: DateTime(2026, 10, 18),
    category: 'Pengumuman',
    icon: Icons.campaign_outlined,
  ),
  HomeNewsItem(
    title: 'RS PKU Gamping Raih Akreditasi Paripurna',
    publishedAt: DateTime(2026, 10, 15),
    category: 'Prestasi',
    icon: Icons.verified_outlined,
  ),
  HomeNewsItem(
    title: 'Pendaftaran Vaksinasi Influenza Telah Dibuka',
    publishedAt: DateTime(2026, 10, 7),
    category: 'Pengumuman',
    icon: Icons.vaccines_outlined,
  ),
  HomeNewsItem(
    title: 'Mengenal Layanan Home Care RS PKU Gamping',
    publishedAt: DateTime(2026, 9, 30),
    category: 'Layanan',
    icon: Icons.home_outlined,
  ),
  HomeNewsItem(
    title: 'Kegiatan Donor Darah Bersama PMI Yogyakarta',
    publishedAt: DateTime(2026, 9, 24),
    category: 'Kegiatan',
    icon: Icons.bloodtype_outlined,
  ),
  HomeNewsItem(
    title: 'Pentingnya Pemeriksaan Kesehatan Berkala',
    publishedAt: DateTime(2026, 9, 16),
    category: 'Edukasi',
    icon: Icons.monitor_heart_outlined,
  ),
]);

final List<HomeNewsItem> kHomeSortedNews = List<HomeNewsItem>.unmodifiable(
  [...kHomeNewsList]
    ..sort((first, second) => second.publishedAt.compareTo(first.publishedAt)),
);

/// Empat berita terbaru yang ditampilkan pada Beranda.
final List<HomeNewsItem> kHomeLatestNews = kHomeSortedNews
    .take(4)
    .toList(growable: false);
