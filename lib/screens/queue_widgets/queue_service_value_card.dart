import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Kartu Nilai Layanan SIGAP & Nilai Spiritual RS PKU
class QueueServiceValueCard extends StatelessWidget {
  const QueueServiceValueCard({super.key});

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
              color: AppColors.primary,
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
