import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_header_stepper.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_step1_nik.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_step2_pasien.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_step3_akun.dart';
import 'package:pku_gamping_app/services/master_service.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';
import 'package:pku_gamping_app/services/wilayah_service.dart';

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

  // Master Data dari SIMRS
  List<Map<String, dynamic>> _masterAgama = [];
  List<Map<String, dynamic>> _masterPekerjaan = [];
  List<Map<String, dynamic>> _masterPendidikan = [];
  List<Map<String, dynamic>> _masterStatusKawin = [];

  // Wilayah Data dari SIMRS (Cascading)
  List<Map<String, dynamic>> _provinsiList = [];
  List<Map<String, dynamic>> _kabupatenList = [];
  List<Map<String, dynamic>> _kecamatanList = [];
  List<Map<String, dynamic>> _kelurahanList = [];
  bool _isLoadingKabupaten = false;
  bool _isLoadingKecamatan = false;
  bool _isLoadingKelurahan = false;

  String? _verifiedFsMr;
  bool _isPasienLama = false;

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

  bool _isLoading = false;

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
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    try {
      final results = await Future.wait([
        MasterService.getAgama(),
        MasterService.getPekerjaan(),
        MasterService.getPendidikan(),
        MasterService.getStatusKawin(),
        WilayahService.getProvinsi(),
      ]);
      if (!mounted) return;
      setState(() {
        _masterAgama = results[0];
        _masterPekerjaan = results[1];
        _masterPendidikan = results[2];
        _masterStatusKawin = results[3];
        _provinsiList = results[4];
      });
    } catch (e) {
      debugPrint('[RegisterScreen] Gagal memuat data master/wilayah: $e');
    }
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

    try {
      final res = await SimrsService.cekNik(nik);
      if (!mounted) return;

      final isAlreadyRegistered = res['isAlreadyRegistered'] == true;
      final foundInSimrs = res['found'] == true;

      setState(() {
        _isNikChecking = false;
        _nikHasBeenChecked = true;
        _isNikAlreadyRegistered = isAlreadyRegistered;
        _isNikVerified = !isAlreadyRegistered;

        if (foundInSimrs) {
          _isPasienLama = true;
          _verifiedFsMr = res['fs_mr'] as String?;
          final nama = res['fs_nm_pasien'] as String?;
          if (nama != null && nama.isNotEmpty) {
            _namaController.text = nama;
          }
          final tglStr = res['fd_tgl_lahir'] as String?;
          if (tglStr != null && tglStr.isNotEmpty) {
            try {
              _selectedTanggalLahir = DateTime.parse(tglStr);
            } catch (_) {}
          }
        } else {
          _isPasienLama = false;
          _verifiedFsMr = null;
        }
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (isAlreadyRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ??
                  'NIK sudah terdaftar! Gunakan NIK yang belum terdaftar.',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (foundInSimrs) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data pasien ditemukan di SIMRS: ${_namaController.text}. Data otomatis terisi.',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'NIK valid (pasien baru). Silakan lanjutkan pendaftaran.',
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isNikChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
          ),
          backgroundColor: AppColors.error,
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

  Future<void> _handleProvinsiChanged(String? kdPropinsi) async {
    setState(() {
      _selectedProvinsi = kdPropinsi;
      _selectedKabupaten = null;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _kabupatenList = [];
      _kecamatanList = [];
      _kelurahanList = [];
    });

    if (kdPropinsi == null || kdPropinsi.isEmpty) return;

    setState(() => _isLoadingKabupaten = true);
    try {
      final list = await WilayahService.getKabupaten(kdPropinsi);
      if (!mounted) return;
      setState(() {
        _kabupatenList = list;
        _isLoadingKabupaten = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingKabupaten = false);
      debugPrint('[RegisterScreen] Gagal memuat kabupaten: $e');
    }
  }

  Future<void> _handleKabupatenChanged(String? kdKabupaten) async {
    setState(() {
      _selectedKabupaten = kdKabupaten;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _kecamatanList = [];
      _kelurahanList = [];
    });

    if (kdKabupaten == null || kdKabupaten.isEmpty) return;

    setState(() => _isLoadingKecamatan = true);
    try {
      final list = await WilayahService.getKecamatan(kdKabupaten);
      if (!mounted) return;
      setState(() {
        _kecamatanList = list;
        _isLoadingKecamatan = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingKecamatan = false);
      debugPrint('[RegisterScreen] Gagal memuat kecamatan: $e');
    }
  }

  Future<void> _handleKecamatanChanged(String? kdKecamatan) async {
    setState(() {
      _selectedKecamatan = kdKecamatan;
      _selectedKelurahan = null;
      _kelurahanList = [];
    });

    if (kdKecamatan == null || kdKecamatan.isEmpty) return;

    setState(() => _isLoadingKelurahan = true);
    try {
      final list = await WilayahService.getKelurahan(kdKecamatan);
      if (!mounted) return;
      setState(() {
        _kelurahanList = list;
        _isLoadingKelurahan = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingKelurahan = false);
      debugPrint('[RegisterScreen] Gagal memuat kelurahan: $e');
    }
  }

  void _handleKelurahanChanged(String? kdKelurahan) {
    setState(() => _selectedKelurahan = kdKelurahan);
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

  String? _findMasterCode(
    List<Map<String, dynamic>> list,
    String nameKey,
    String codeKey,
    String? selectedName,
  ) {
    if (selectedName == null || selectedName.isEmpty) return null;
    final item = list.firstWhere(
      (e) =>
          (e[nameKey] ?? '').toString().toUpperCase() ==
              selectedName.toUpperCase() ||
          (e[codeKey] ?? '').toString() == selectedName,
      orElse: () => {},
    );
    return item[codeKey]?.toString();
  }

  void _handleDaftar() async {
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

    setState(() => _isLoading = true);

    try {
      final payload = <String, dynamic>{
        'fs_email': email,
        'fs_password': password,
        'fs_nik': _nikController.text.trim(),
        if (_isPasienLama && _verifiedFsMr != null) 'fs_mr': _verifiedFsMr,
        'fs_nm_pasien': _namaController.text.trim(),
        'fs_no_hp': _nomorHpController.text.trim(),
        'fs_temp_lahir': _selectedTempatLahir ?? '',
        'fd_tgl_lahir': _selectedTanggalLahir != null
            ? '${_selectedTanggalLahir!.year}-${_selectedTanggalLahir!.month.toString().padLeft(2, '0')}-${_selectedTanggalLahir!.day.toString().padLeft(2, '0')}'
            : '',
        'fs_jenis_kelamin': _selectedJenisKelamin == 'Perempuan' ? '2' : '1',
        'fs_gol_darah': _selectedGolDarah ?? 'O',
        'fs_alamat': _alamatController.text.trim(),
        'fs_kd_agama': _findMasterCode(
              _masterAgama,
              'FS_NM_AGAMA',
              'FS_KD_AGAMA',
              _selectedAgama,
            ) ??
            '1',
        'fs_kd_pekerjaan': _findMasterCode(
              _masterPekerjaan,
              'FS_NM_PEKERJAAN_DK',
              'FS_KD_PEKERJAAN_DK',
              _selectedPekerjaan,
            ) ??
            '01',
        'fs_kd_pendidikan': _findMasterCode(
              _masterPendidikan,
              'FS_NM_PENDIDIKAN_DK',
              'FS_KD_PENDIDIKAN_DK',
              _selectedPendidikan,
            ) ??
            '01',
        'fs_status_kawin': _findMasterCode(
              _masterStatusKawin,
              'FS_NM_STATUS_KAWIN_DK',
              'FS_KD_STATUS_KAWIN_DK',
              _selectedStatusKawin,
            ) ??
            '1',
        'fs_kd_suku': '004',
        'fs_nm_ibu_kandung': _namaIbuController.text.trim(),
        'fs_warga_negara': _selectedWargaNegara ?? 'WNI',
        if (_selectedKelurahan != null) 'fs_kd_kelurahan': _selectedKelurahan,
      };

      final response = await SimrsService.registerPasien(payload);
      if (!mounted) return;

      setState(() => _isLoading = false);

      final msg = response['message']?.toString() ??
          'Pendaftaran berhasil! Akun Anda siap digunakan.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.success,
        ),
      );

      // Setelah registrasi berhasil dan token tersimpan, langsung masuk ke beranda
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
                      agamaItems: _masterAgama
                          .map((e) => (e['FS_NM_AGAMA'] ?? '').toString())
                          .where((s) => s.isNotEmpty)
                          .toList(),
                      pekerjaanItems: _masterPekerjaan
                          .map((e) =>
                              (e['FS_NM_PEKERJAAN_DK'] ?? '').toString())
                          .where((s) => s.isNotEmpty)
                          .toList(),
                      pendidikanItems: _masterPendidikan
                          .map((e) =>
                              (e['FS_NM_PENDIDIKAN_DK'] ?? '').toString())
                          .where((s) => s.isNotEmpty)
                          .toList(),
                      statusKawinItems: _masterStatusKawin
                          .map((e) =>
                              (e['FS_NM_STATUS_KAWIN_DK'] ?? '').toString())
                          .where((s) => s.isNotEmpty)
                          .toList(),
                      provinsiItems: _provinsiList,
                      kabupatenItems: _kabupatenList,
                      kecamatanItems: _kecamatanList,
                      kelurahanItems: _kelurahanList,
                      isLoadingKabupaten: _isLoadingKabupaten,
                      isLoadingKecamatan: _isLoadingKecamatan,
                      isLoadingKelurahan: _isLoadingKelurahan,
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
                      onProvinsiChanged: _handleProvinsiChanged,
                      onKabupatenChanged: _handleKabupatenChanged,
                      onKecamatanChanged: _handleKecamatanChanged,
                      onKelurahanChanged: _handleKelurahanChanged,
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
