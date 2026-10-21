import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_footer.dart';
import 'package:pku_gamping_app/screens/riwayat_resep_widgets/riwayat_resep_app_bar.dart';
import 'package:pku_gamping_app/screens/riwayat_resep_widgets/riwayat_resep_breadcrumb_header.dart';
import 'package:pku_gamping_app/screens/riwayat_resep_widgets/riwayat_resep_empty_state.dart';

/// Halaman Riwayat Resep Obat Pasien
class RiwayatResepScreen extends StatelessWidget {
  const RiwayatResepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const RiwayatResepAppBar(),
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
                          RiwayatResepBreadcrumbHeader(),
                          Spacer(),
                          Center(child: RiwayatResepEmptyState()),
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
