import 'package:flutter/material.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';

import 'home_patient_header.dart';
import 'home_queue_active_card.dart';

class HomeWithQueue extends StatelessWidget {
  const HomeWithQueue({
    super.key,
    required this.antrean,
    required this.onPantauPressed,
  });

  final AntreanAktifModel antrean;
  final VoidCallback onPantauPressed;

  @override
  Widget build(BuildContext context) {
    return HomePatientHeader(
      queueCard: HomeQueueActiveCard(
        antrean: antrean,
        onPantauPressed: onPantauPressed,
      ),
      namaPasien: antrean.namaPasien,
      noRm: antrean.noRm,
    );
  }
}
