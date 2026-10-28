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
  final String date;
  final String category;
  final IconData icon;

  const HomeNewsItem({
    required this.title,
    required this.date,
    required this.category,
    required this.icon,
  });
}

/// Data Berita Dummy
const List<HomeNewsItem> kHomeNewsList = [
  HomeNewsItem(
    title: 'Layanan Kateterisasi Jantung 24 Jam di RS PKU Gamping',
    date: '24 Okt 2026',
    category: 'Layanan Baru',
    icon: Icons.favorite_border_rounded,
  ),
  HomeNewsItem(
    title: 'Tips Menjaga Kesehatan Jantung di Usia Produktif',
    date: '22 Okt 2026',
    category: 'Edukasi',
    icon: Icons.health_and_safety_outlined,
  ),
  HomeNewsItem(
    title: 'Jadwal Poliklinik Rawat Jalan Selama Libur Nasional',
    date: '18 Okt 2026',
    category: 'Pengumuman',
    icon: Icons.campaign_outlined,
  ),
  HomeNewsItem(
    title: 'RS PKU Gamping Raih Akreditasi Paripurna',
    date: '15 Okt 2026',
    category: 'Prestasi',
    icon: Icons.verified_outlined,
  ),
  HomeNewsItem(
    title: 'Pendaftaran Vaksinasi Influenza Telah Dibuka',
    date: '7 Okt 2026',
    category: 'Pengumuman',
    icon: Icons.vaccines_outlined,
  ),
  HomeNewsItem(
    title: 'Mengenal Layanan Home Care RS PKU Gamping',
    date: '30 Sep 2026',
    category: 'Layanan',
    icon: Icons.home_outlined,
  ),
  HomeNewsItem(
    title: 'Kegiatan Donor Darah Bersama PMI Yogyakarta',
    date: '24 Sep 2026',
    category: 'Kegiatan',
    icon: Icons.bloodtype_outlined,
  ),
  HomeNewsItem(
    title: 'Pentingnya Pemeriksaan Kesehatan Berkala',
    date: '16 Sep 2026',
    category: 'Edukasi',
    icon: Icons.monitor_heart_outlined,
  ),
];

/// Empat berita terbaru yang ditampilkan pada Beranda.
final List<HomeNewsItem> kHomeLatestNews = kHomeNewsList
    .take(4)
    .toList(growable: false);
