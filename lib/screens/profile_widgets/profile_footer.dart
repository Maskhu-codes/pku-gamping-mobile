import 'package:flutter/material.dart';

/// Footer Identitas RS dan Versi Aplikasi
class ProfileFooter extends StatelessWidget {
  const ProfileFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital_outlined,
              color: Color(0xFF94A3B8),
              size: 15,
            ),
            SizedBox(width: 6),
            Text(
              'RS PKU Muhammadiyah Gamping',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'Versi Aplikasi 2.4.0 • SIGAP Mobile',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
