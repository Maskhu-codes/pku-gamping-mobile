import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
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

  // Step 2: Data Pasien
  final _namaController = TextEditingController();
  final _tempatLahirController = TextEditingController();
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
  String? _selectedProvinsi = 'D.I. Yogyakarta';
  String? _selectedKabupaten = 'Kab. Sleman';
  String? _selectedKecamatan = 'Gamping';
  String? _selectedKelurahan;
  final _alamatController = TextEditingController();

  // Kontak
  final _nomorHpController = TextEditingController();
  final _emailKontakController = TextEditingController();

  // Step 3: Buat Akun & Keamanan
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();

    _emailKontakController.addListener(_syncEmailKontak);
  }

  void _syncEmailKontak() {
    if (_emailController.text.isEmpty && _currentPage < 2) {
      _emailController.text = _emailKontakController.text;
    }
  }

  @override
  void dispose() {
    _emailKontakController.removeListener(_syncEmailKontak);
    _animController.dispose();
    _pageController.dispose();
    _nikController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _namaIbuController.dispose();
    _alamatController.dispose();
    _nomorHpController.dispose();
    _emailKontakController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
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

    final isValid = await SimrsService.cekNik(nik);

    if (!mounted) return;

    setState(() {
      _isNikChecking = false;
      _isNikVerified = isValid;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('NIK valid dan terhubung dengan SIMRS PKU Gamping.'),
        backgroundColor: AppColors.success,
        duration: Duration(milliseconds: 600),
      ),
    );
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

    _isNikVerified = true;
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

    if (_tempatLahirController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tempat Lahir wajib diisi.'),
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

    if (_emailController.text.isEmpty) {
      _emailController.text = _emailKontakController.text;
    }

    if (_usernameController.text.isEmpty) {
      final cleanName = _namaController.text
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
      final lastNik = _nikController.text.length >= 4
          ? _nikController.text.substring(_nikController.text.length - 4)
          : '0001';
      _usernameController.text = '${cleanName}_$lastNik';
    }

    _goToPage(2);
  }

  void _handleDaftar() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
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

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username wajib diisi.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (username.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username minimal 4 karakter.'),
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

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak sama.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await SimrsService.registerPasien({
      'email': email,
      'username': username,
      'password': password,
      'nik': _nikController.text.trim(),
      'nama': _namaController.text.trim(),
    });

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftaran berhasil! Silakan masuk ke akun Anda.'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
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
                      onCekNik: _cekNikAsync,
                      onLanjut: _handleStep1Submit,
                      onLoginTap: _goToLogin,
                    ),
                    RegisterStep2Pasien(
                      namaController: _namaController,
                      tempatLahirController: _tempatLahirController,
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
                      emailKontakController: _emailKontakController,
                      onTanggalLahirChanged: (d) =>
                          setState(() => _selectedTanggalLahir = d),
                      onJenisKelaminChanged: (v) =>
                          setState(() => _selectedJenisKelamin = v),
                      onGolDarahChanged: (v) =>
                          setState(() => _selectedGolDarah = v),
                      onAgamaChanged: (v) =>
                          setState(() => _selectedAgama = v),
                      onWargaNegaraChanged: (v) =>
                          setState(() => _selectedWargaNegara = v),
                      onPekerjaanChanged: (v) =>
                          setState(() => _selectedPekerjaan = v),
                      onPendidikanChanged: (v) =>
                          setState(() => _selectedPendidikan = v),
                      onStatusKawinChanged: (v) =>
                          setState(() => _selectedStatusKawin = v),
                      onProvinsiChanged: (v) =>
                          setState(() => _selectedProvinsi = v),
                      onKabupatenChanged: (v) =>
                          setState(() => _selectedKabupaten = v),
                      onKecamatanChanged: (v) =>
                          setState(() => _selectedKecamatan = v),
                      onKelurahanChanged: (v) =>
                          setState(() => _selectedKelurahan = v),
                      onPrev: () => _goToPage(0),
                      onLanjut: _handleStep2Submit,
                    ),
                    RegisterStep3Akun(
                      emailController: _emailController,
                      usernameController: _usernameController,
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
