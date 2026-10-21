import 'package:flutter/material.dart';
import 'jadwal_constants.dart';

/// Header halaman Jadwal — Judul besar + subtitle deskriptif.
class JadwalHeader extends StatelessWidget {
  const JadwalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jadwal',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: kInk,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Lihat jadwal kunjungan dan dokter.',
            style: TextStyle(
              fontSize: 14,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }
}
