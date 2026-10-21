import 'package:flutter/material.dart';
import 'jadwal_constants.dart';

/// Catatan informasi di bagian bawah daftar jadwal.
///
/// Menampilkan peringatan pendaftaran poli yang ditutup
/// 30 menit sebelum jadwal selesai.
class JadwalFooterNote extends StatelessWidget {
  const JadwalFooterNote({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: kMuted,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Pendaftaran poli ditutup 30 menit sebelum jadwal selesai.',
              style: TextStyle(
                fontSize: 12,
                color: kMuted,
                fontFamily: kFontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
