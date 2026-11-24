import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';
import '../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _fadeController.forward();
    _slideController.forward();
    // Tunggu animasi logo selesai
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Cek apakah ada sesi login aktif
    final token = SessionManager.token;
    final isLoggedIn = SessionManager.isLoggedIn;

    if (isLoggedIn && token != null && token.isNotEmpty) {
      try {
        final sessionData = await SimrsService.checkSession();
        if (!mounted) return;

        if (sessionData != null) {
          // Sesi masih valid di backend SIMRS -> langsung masuk ke Beranda
          Navigator.pushReplacementNamed(context, AppRoutes.home);
          return;
        }
      } catch (_) {
        // Jika offline atau error, tetap cek apakah sesi lokal masih ada
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
          return;
        }
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo Splash PKU Muhammadiyah Gamping
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Image.asset(
                    'assets/images/splashLogo.png',
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Institutional Subline Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'RS PKU Muhammadiyah Gamping',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Portal Pasien Resmi',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textHint,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
