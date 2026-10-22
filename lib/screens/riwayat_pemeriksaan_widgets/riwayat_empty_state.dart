import 'package:flutter/material.dart';
import 'package:pku_gamping_app/widgets/app_empty_state.dart';

/// Empty state halaman Riwayat Pemeriksaan menggunakan AppEmptyState
class RiwayatEmptyState extends StatelessWidget {
  const RiwayatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      icon: Icons.assignment_outlined,
      title: 'Tidak Ada Riwayat',
      message: 'Anda belum memiliki riwayat pemeriksaan.',
    );
  }
}
