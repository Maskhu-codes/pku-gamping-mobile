import 'package:flutter/material.dart';
import 'package:pku_gamping_app/widgets/hospital_brand_header.dart';

export 'package:pku_gamping_app/widgets/hospital_brand_header.dart';

/// Adapter kompatibilitas untuk HomeBrandHeader mengarah ke HospitalBrandHeader terpadu
class HomeBrandHeader extends StatelessWidget {
  const HomeBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const HospitalBrandHeader(useGradient: true);
  }
}
