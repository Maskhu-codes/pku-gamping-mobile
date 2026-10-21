import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_footer.dart';
import 'package:pku_gamping_app/screens/riwayat_pemeriksaan_widgets/riwayat_breadcrumb_header.dart';
import 'package:pku_gamping_app/screens/riwayat_pemeriksaan_widgets/riwayat_empty_state.dart';
import 'package:pku_gamping_app/screens/riwayat_pemeriksaan_widgets/riwayat_pemeriksaan_app_bar.dart';

/// Halaman Riwayat Pemeriksaan Pasien
class RiwayatPemeriksaanScreen extends StatelessWidget {
  const RiwayatPemeriksaanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const RiwayatPemeriksaanAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600, minHeight: constraints.maxHeight),
                  child: const IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RiwayatBreadcrumbHeader(),
                          Spacer(),
                          Center(child: RiwayatEmptyState()),
                          Spacer(),
                          SizedBox(height: 24),
                          ProfileFooter(),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
