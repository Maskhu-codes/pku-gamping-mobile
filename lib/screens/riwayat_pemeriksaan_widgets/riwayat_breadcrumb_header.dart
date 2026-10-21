import 'package:flutter/material.dart';

/// Breadcrumb navigasi dan judul halaman Riwayat Pemeriksaan
class RiwayatBreadcrumbHeader extends StatelessWidget {
  const RiwayatBreadcrumbHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => Navigator.maybePop(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text('Profil', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              child: Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
            ),
            const Text('Riwayat Pemeriksaan', style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Riwayat Pemeriksaan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5)),
        const SizedBox(height: 4),
        const Text('Pantau rekam jejak medis Anda.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
      ],
    );
  }
}
