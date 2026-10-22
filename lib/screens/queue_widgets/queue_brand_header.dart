import 'package:flutter/material.dart';
import 'package:pku_gamping_app/widgets/hospital_brand_header.dart';

export 'package:pku_gamping_app/widgets/hospital_brand_header.dart';

/// Adapter kompatibilitas untuk QueueBrandHeader mengarah ke HospitalBrandHeader terpadu
class QueueBrandHeader extends StatelessWidget {
  const QueueBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const HospitalBrandHeader();
  }
}
