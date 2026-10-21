import 'package:flutter/material.dart';

/// Empty state halaman Riwayat Resep
class RiwayatResepEmptyState extends StatelessWidget {
  const RiwayatResepEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
          child: const Center(
            child: Icon(Icons.receipt_long_outlined, size: 40, color: Color(0xFFD97706)),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Tidak Ada Riwayat Resep', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.2), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Anda belum memiliki riwayat resep obat\natau catatan pengambilan farmasi.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4), textAlign: TextAlign.center),
      ],
    );
  }
}
