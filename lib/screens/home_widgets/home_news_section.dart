import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';

import 'home_constants.dart';

/// Bagian Informasi & Berita rumah sakit pada beranda.
class HomeNewsSection extends StatelessWidget {
  const HomeNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris Judul
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informasi & Berita',
                style: TextStyle(
                  color: kHomeInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: kHomeFontFamily,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.news);
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: kHomePrimaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: kHomeFontFamily,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Carousel Horizontal Berita
        SizedBox(
          height: 195,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: kHomeLatestNews.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final news = kHomeLatestNews[index];
              return Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0617233B),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Kartu: Kategori & Ikon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFDBEAFE),
                              ),
                            ),
                            child: Text(
                              news.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: kHomePrimaryBlue,
                                fontFamily: kHomeFontFamily,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              news.icon,
                              color: kHomePrimaryBlue,
                              size: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Judul Berita
                      Expanded(
                        child: Text(
                          news.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kHomeInk,
                            fontFamily: kHomeFontFamily,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tanggal Berita
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: kHomeMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            news.date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kHomeMuted,
                              fontFamily: kHomeFontFamily,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
