import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Kartu Nilai Layanan SIGAP & Nilai Spiritual RS PKU Muhammadiyah Gamping
class QueueServiceValueCard extends StatelessWidget {
  const QueueServiceValueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0517233B),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE68A).withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_outlined,
              color: AppColors.goldText,
              size: 19,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NILAI LAYANAN SPIRITUAL RS PKU',
                  style: TextStyle(
                    color: AppColors.goldText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '"Dan apabila aku sakit, Dialah yang menyembuhkan aku." (QS. Asy-Syu\'ara: 80). Mohon tertib dan sabar selama proses pelayanan medis berlangsung.',
                  style: TextStyle(
                    color: Color(0xFF5A4400),
                    fontSize: 12,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
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
