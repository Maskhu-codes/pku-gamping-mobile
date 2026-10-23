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
  static const pendaftaran = '/pendaftaran';
  static const queueDetail = '/queue-detail';
  static const pemeriksaanPenunjang = '/pemeriksaan-penunjang';
  static const hasilLab = '/hasil-lab';
  static const hasilRadiologi = '/hasil-radiologi';
  static const riwayatPemeriksaan = '/riwayat-pemeriksaan';
  static const riwayatResep = '/riwayat-resep';
  static const editProfile = '/edit-profile';
}

/// Router terpusat menggunakan onGenerateRoute bawaan Flutter
class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case AppRoutes.otp:
        return MaterialPageRoute(
          builder: (_) => const OtpScreen(),
          settings: settings,
        );

      case AppRoutes.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

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
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            notification: notif,
            initialIndex: initialIndex,
          ),
        );

      case AppRoutes.pendaftaran:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PendaftaranScreen(
            initialDokter: args?['initialDokter'] as DokterJadwal?,
            initialPoliNama: args?['initialPoliNama'] as String?,
          ),
        );

      case AppRoutes.queueDetail:
        return MaterialPageRoute(builder: (_) => const QueueDetailScreen());

      case AppRoutes.pemeriksaanPenunjang:
        return MaterialPageRoute(builder: (_) => const PemeriksaanPenunjangScreen());

      case AppRoutes.hasilLab:
        final args = settings.arguments as List<LabResult>?;
        return MaterialPageRoute(
          builder: (_) => HasilLabScreen(results: args ?? const []),
        );

      case AppRoutes.hasilRadiologi:
        final args = settings.arguments as List<RadiologyResult>?;
        return MaterialPageRoute(
          builder: (_) => HasilRadiologiScreen(results: args ?? const []),
        );

      case AppRoutes.riwayatPemeriksaan:
        final args = settings.arguments as List<RiwayatPemeriksaan>?;
        return MaterialPageRoute(
          builder: (_) => RiwayatPemeriksaanScreen(riwayat: args ?? const []),
        );

      case AppRoutes.riwayatResep:
        return MaterialPageRoute(
          builder: (_) => const RiwayatResepScreen(),
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan: ${settings.name}')),
          ),
        );
    }
  }
}
