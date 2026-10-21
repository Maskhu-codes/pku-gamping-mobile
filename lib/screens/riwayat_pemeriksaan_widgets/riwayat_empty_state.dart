import 'package:flutter/material.dart';

/// Empty state halaman Riwayat Pemeriksaan
class RiwayatEmptyState extends StatelessWidget {
  const RiwayatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
          child: Center(
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.assignment_outlined, size: 38, color: Color(0xFF2563EB)),
                  Positioned(
                    right: 2, bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                      child: const Icon(Icons.add_circle, size: 16, color: Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Tidak Ada Riwayat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.2), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Anda belum memiliki riwayat\npemeriksaan.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4), textAlign: TextAlign.center),
      ],
    );
  }
}
