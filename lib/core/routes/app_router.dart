import 'package:flutter/material.dart';
import 'package:pku_gamping_app/models/dokter_jadwal_model.dart';
import 'package:pku_gamping_app/models/hasil_pemeriksaan_model.dart';
import 'package:pku_gamping_app/models/riwayat_pemeriksaan_model.dart';
import 'package:pku_gamping_app/screens/edit_profile_screen.dart';
import 'package:pku_gamping_app/screens/forgot_password_screen.dart';
import 'package:pku_gamping_app/screens/hasil_lab_screen.dart';
import 'package:pku_gamping_app/screens/hasil_radiologi_screen.dart';
import 'package:pku_gamping_app/screens/home_screen.dart';
import 'package:pku_gamping_app/screens/login_screen.dart';
import 'package:pku_gamping_app/screens/news_screen.dart';
import 'package:pku_gamping_app/screens/otp_screen.dart';
import 'package:pku_gamping_app/screens/pemeriksaan_penunjang_screen.dart';
import 'package:pku_gamping_app/screens/pendaftaran_screen.dart';
import 'package:pku_gamping_app/screens/queue_detail_screen.dart';
import 'package:pku_gamping_app/screens/register_screen.dart';
import 'package:pku_gamping_app/screens/reset_password_screen.dart';
import 'package:pku_gamping_app/screens/riwayat_pemeriksaan_screen.dart';
import 'package:pku_gamping_app/screens/riwayat_resep_screen.dart';
import 'package:pku_gamping_app/screens/splash_screen.dart';
import 'package:pku_gamping_app/widgets/top_notification.dart';

/// Daftar nama rute aplikasi terpusat
class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const news = '/news';
  static const pendaftaran = '/pendaftaran';
  static const queueDetail = '/queue-detail';
  static const pemeriksaanPenunjang = '/pemeriksaan-penunjang';
  static const hasilLab = '/hasil-lab';
  static const hasilRadiologi = '/hasil-radiologi';
  static const riwayatPemeriksaan = '/riwayat-pemeriksaan';
  static const riwayatResep = '/riwayat-resep';
  static const editProfile = '/edit-profile';
}

/// Router terpusat menggunakan transisi seragam yang tenang & medis
class AppRouter {
  static PageRoute<T> _buildRoute<T>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (context, animation, _, child) {
        final reduceMotion =
            MediaQuery.maybeDisableAnimationsOf(context) ?? false;
        if (reduceMotion) return child;

        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen(), settings: settings);

      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings: settings);

      case AppRoutes.register:
        return _buildRoute(const RegisterScreen(), settings: settings);

      case AppRoutes.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings: settings);

      case AppRoutes.otp:
        return _buildRoute(const OtpScreen(), settings: settings);

      case AppRoutes.resetPassword:
        return _buildRoute(const ResetPasswordScreen(), settings: settings);

      case AppRoutes.home:
        final args = settings.arguments;
        TopNotificationType? notif;
        int initialIndex = 0;
        if (args is Map<String, dynamic>) {
          notif = args['notification'] as TopNotificationType?;
          initialIndex = args['initialIndex'] as int? ?? 0;
        } else if (args is TopNotificationType) {
          notif = args;
        }
        return _buildRoute(
          HomeScreen(
            notification: notif,
            initialIndex: initialIndex,
          ),
          settings: settings,
        );

      case AppRoutes.news:
        return _buildRoute(const NewsScreen(), settings: settings);

      case AppRoutes.pendaftaran:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          PendaftaranScreen(
            initialDokter: args?['initialDokter'] as DokterJadwal?,
            initialPoliNama: args?['initialPoliNama'] as String?,
          ),
          settings: settings,
        );

      case AppRoutes.queueDetail:
        return _buildRoute(const QueueDetailScreen(), settings: settings);

      case AppRoutes.pemeriksaanPenunjang:
        return _buildRoute(
          const PemeriksaanPenunjangScreen(),
          settings: settings,
        );

      case AppRoutes.hasilLab:
        final args = settings.arguments as List<LabResult>?;
        return _buildRoute(
          HasilLabScreen(results: args ?? const []),
          settings: settings,
        );

      case AppRoutes.hasilRadiologi:
        final args = settings.arguments as List<RadiologyResult>?;
        return _buildRoute(
          HasilRadiologiScreen(results: args ?? const []),
          settings: settings,
        );

      case AppRoutes.riwayatPemeriksaan:
        final args = settings.arguments as List<RiwayatPemeriksaan>?;
        return _buildRoute(
          RiwayatPemeriksaanScreen(riwayat: args ?? const []),
          settings: settings,
        );

      case AppRoutes.riwayatResep:
        return _buildRoute(const RiwayatResepScreen(), settings: settings);

      case AppRoutes.editProfile:
        return _buildRoute(const EditProfileScreen(), settings: settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Halaman tidak ditemukan: ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
