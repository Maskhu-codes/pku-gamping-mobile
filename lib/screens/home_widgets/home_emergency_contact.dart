import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_constants.dart';

/// Banner Kontak Darurat (IGD 24 Jam) di bagian bawah beranda.
class HomeEmergencyContact extends StatelessWidget {
  const HomeEmergencyContact({super.key});

  @override
  Widget build(BuildContext context) {
    const igdPhoneNumber = '(0274) 6499118';
    const igdPhoneUri = 'tel:+62276499118';

    Future<void> hubungiIGD() async {
      final uri = Uri.parse(igdPhoneUri);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aplikasi telepon tidak tersedia pada perangkat ini'),
            backgroundColor: Color(0xFF991B1B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0617233B),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency_outlined,
                color: Color(0xFFDC2626),
                size: 22,
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
                    igdPhoneNumber,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB91C1C),
                      fontFamily: kHomeFontFamily,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: hubungiIGD,
              icon: const Icon(Icons.call_rounded, size: 14),
              label: const Text(
                'Hubungi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: kHomeFontFamily,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
