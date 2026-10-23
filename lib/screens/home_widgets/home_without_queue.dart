import 'package:flutter/material.dart';

import 'home_patient_header.dart';
import 'home_queue_empty_card.dart';

class HomeWithoutQueue extends StatelessWidget {
  const HomeWithoutQueue({
    super.key,
    required this.namaPasien,
    required this.noRm,
    required this.onDaftarPressed,
  });

  final String namaPasien;
  final String noRm;
  final VoidCallback onDaftarPressed;

  @override
  Widget build(BuildContext context) {
    return HomePatientHeader(
      queueCard: HomeQueueEmptyCard(onDaftarPressed: onDaftarPressed),
      namaPasien: namaPasien,
      noRm: noRm,
    );
  }
}
