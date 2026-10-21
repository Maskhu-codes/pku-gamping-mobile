import 'package:flutter/material.dart';
import 'home_constants.dart';

/// Banner Kontak Darurat (IGD 24 Jam) di bagian bawah beranda.
class HomeEmergencyContact extends StatelessWidget {
  const HomeEmergencyContact({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency_outlined,
                color: Color(0xFFDC2626),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IGD 24 Jam RS PKU',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF991B1B),
                      fontFamily: kHomeFontFamily,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '(0274) 6499118',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB91C1C),
                      fontFamily: kHomeFontFamily,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menghubungi IGD RS PKU Gamping: (0274) 6499706'),
                    backgroundColor: Color(0xFFDC2626),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Hubungi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: kHomeFontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
