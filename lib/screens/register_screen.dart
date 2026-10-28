import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_header_stepper.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_step1_nik.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_step2_pasien.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_step3_akun.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';

/// Screen Registrasi Akun Pasien Baru Terintegrasi SIMRS PKU Gamping.
///
/// Menggunakan arsitektur modular:
/// - [RegisterHeaderStepper]: App bar & progress indicator
/// - [RegisterStep1Nik]: Validasi NIK SIMRS (Langkah 1)
/// - [RegisterStep2Pasien]: Biodata, Wilayah, & Kontak Pasien (Langkah 2)
/// - [RegisterStep3Akun]: Pembuatan Akun & Kata Sandi (Langkah 3)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Step 1: Cek NIK
  final _nikController = TextEditingController();
  bool _isNikChecking = false;
  bool _isNikVerified = false;
  bool _isNikAlreadyRegistered = false;
  bool _nikHasBeenChecked = false;

  // Step 2: Data Pasien
  final _namaController = TextEditingController();
  String? _selectedTempatLahir;
  DateTime? _selectedTanggalLahir;
  String? _selectedJenisKelamin;
  String? _selectedGolDarah;
  String? _selectedAgama;
  String? _selectedWargaNegara = 'WNI';
  String? _selectedPekerjaan;
  String? _selectedPendidikan;
  String? _selectedStatusKawin;
  final _namaIbuController = TextEditingController();

  // Alamat
  String? _selectedProvinsi;
  String? _selectedKabupaten;
  String? _selectedKecamatan;
  String? _selectedKelurahan;
  final _alamatController = TextEditingController();

  // Kontak
  final _nomorHpController = TextEditingController();

  // Step 3: Buat Akun & Keamanan
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    _nikController.dispose();
    _namaController.dispose();
    _namaIbuController.dispose();
    _alamatController.dispose();
    _nomorHpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages) return;

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );

    setState(() => _currentPage = page);
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        _goToLogin();
      }
    }
  }

  void _cekNikAsync() async {
    final nik = _nikController.text.trim();

    if (nik.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor NIK harus terdiri dari 16 digit angka.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isNikChecking = true);

    // Cek apakah NIK sudah terdaftar
    final isAlreadyRegistered = await SimrsService.isNikAlreadyRegistered(nik);

    if (!mounted) return;

    setState(() {
      _isNikChecking = false;
      _nikHasBeenChecked = true;
      _isNikAlreadyRegistered = isAlreadyRegistered;
      _isNikVerified = !isAlreadyRegistered;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (isAlreadyRegistered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'NIK sudah terdaftar! Gunakan NIK yang belum terdaftar.',
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'NIK valid dan belum terdaftar. Silakan lanjutkan pendaftaran.',
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleStep1Submit() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final nik = _nikController.text.trim();

    if (nik.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nomor NIK KTP Anda.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (nik.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIK harus terdiri dari 16 digit angka.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_nikHasBeenChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan cek NIK terlebih dahulu sebelum melanjutkan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_isNikAlreadyRegistered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan NIK yang belum terdaftar di RS PKU Gamping.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_isNikVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'NIK belum terverifikasi. Silakan cek NIK terlebih dahulu.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _goToPage(1);
  }

  void _handleStep2Submit() {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama Lengkap wajib diisi sesuai KTP.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedTempatLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tempat Lahir wajib dipilih.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Default fallbacks untuk field opsional
    _selectedTanggalLahir ??= DateTime(1995, 1, 1);
    _selectedJenisKelamin ??= 'Laki-laki';
    _selectedGolDarah ??= 'O';
    _selectedAgama ??= 'Islam';
    _selectedPekerjaan ??= 'Karyawan Swasta';
    _selectedPendidikan ??= 'S1 / Sarjana';
    _selectedStatusKawin ??= 'Belum Kawin';
    if (_namaIbuController.text.trim().isEmpty) {
      _namaIbuController.text = 'Ibu Pasien';
    }
    if (_alamatController.text.trim().isEmpty) {
      _alamatController.text = 'Gamping, Sleman, D.I. Yogyakarta';
    }
    if (_nomorHpController.text.trim().isEmpty) {
      _nomorHpController.text = '81234567890';
    }

    _goToPage(2);
  }

  void _handleDaftar() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email untuk akun wajib diisi.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi minimal 8 karakter.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi harus mengandung angka.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak sama.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftaran berhasil! Silakan masuk ke akun Anda.'),
        backgroundColor: AppColors.success,
      ),
    );

    _goToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              RegisterHeaderStepper(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onBack: _prevPage,
                onStepTapped: _goToPage,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (idx) {
                    setState(() => _currentPage = idx);
                  },
                  children: [
                    RegisterStep1Nik(
                      nikController: _nikController,
                      isNikChecking: _isNikChecking,
                      isNikVerified: _isNikVerified,
                      isNikAlreadyRegistered: _isNikAlreadyRegistered,
                      nikHasBeenChecked: _nikHasBeenChecked,
                      onCekNik: _cekNikAsync,
                      onLanjut: _handleStep1Submit,
                      onLoginTap: _goToLogin,
                      onNikChanged: () {
                        // Reset status ketika NIK berubah
                        if (_nikHasBeenChecked) {
                          setState(() {
                            _nikHasBeenChecked = false;
                            _isNikVerified = false;
                            _isNikAlreadyRegistered = false;
                          });
                        }
                      },
                    ),
                    RegisterStep2Pasien(
                      namaController: _namaController,
                      selectedTempatLahir: _selectedTempatLahir,
                      selectedTanggalLahir: _selectedTanggalLahir,
                      selectedJenisKelamin: _selectedJenisKelamin,
                      selectedGolDarah: _selectedGolDarah,
                      selectedAgama: _selectedAgama,
                      selectedWargaNegara: _selectedWargaNegara,
                      selectedPekerjaan: _selectedPekerjaan,
                      selectedPendidikan: _selectedPendidikan,
                      selectedStatusKawin: _selectedStatusKawin,
                      namaIbuController: _namaIbuController,
                      selectedProvinsi: _selectedProvinsi,
                      selectedKabupaten: _selectedKabupaten,
                      selectedKecamatan: _selectedKecamatan,
                      selectedKelurahan: _selectedKelurahan,
                      alamatController: _alamatController,
                      nomorHpController: _nomorHpController,
                      onTempatLahirChanged: (v) =>
                          setState(() => _selectedTempatLahir = v),
                      onTanggalLahirChanged: (d) =>
                          setState(() => _selectedTanggalLahir = d),
                      onJenisKelaminChanged: (v) =>
                          setState(() => _selectedJenisKelamin = v),
                      onGolDarahChanged: (v) =>
                          setState(() => _selectedGolDarah = v),
                      onAgamaChanged: (v) => setState(() => _selectedAgama = v),
                      onWargaNegaraChanged: (v) =>
                          setState(() => _selectedWargaNegara = v),
                      onPekerjaanChanged: (v) =>
                          setState(() => _selectedPekerjaan = v),
                      onPendidikanChanged: (v) =>
                          setState(() => _selectedPendidikan = v),
                      onStatusKawinChanged: (v) =>
                          setState(() => _selectedStatusKawin = v),
                      onProvinsiChanged: (v) {
                        setState(() {
                          _selectedProvinsi = v;
                          _selectedKabupaten = null;
                          _selectedKecamatan = null;
                          _selectedKelurahan = null;
                        });
                      },
                      onKabupatenChanged: (v) {
                        setState(() {
                          _selectedKabupaten = v;
                          _selectedKecamatan = null;
                          _selectedKelurahan = null;
                        });
                      },
                      onKecamatanChanged: (v) {
                        setState(() {
                          _selectedKecamatan = v;
                          _selectedKelurahan = null;
                        });
                      },
                      onKelurahanChanged: (v) =>
                          setState(() => _selectedKelurahan = v),
                      onPrev: () => _goToPage(0),
                      onLanjut: _handleStep2Submit,
                    ),
                    RegisterStep3Akun(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      obscurePass: _obscurePass,
                      obscureConfirm: _obscureConfirm,
                      isLoading: _isLoading,
                      onTogglePass: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      onToggleConfirm: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      onPrev: () => _goToPage(1),
                      onSubmit: _handleDaftar,
                      onLoginTap: _goToLogin,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
