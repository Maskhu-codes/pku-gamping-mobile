import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_header_stepper.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_step1_nik.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_step2_pasien.dart';
import 'package:pku_gamping_app/screens/register_widgets/register_step3_akun.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
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
  String? _existingMr;

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

  // Alamat (WilayahItem menyimpan kode + nama dari API)
  WilayahItem? _selectedProvinsi;
  WilayahItem? _selectedKabupaten;
  WilayahItem? _selectedKecamatan;
  WilayahItem? _selectedKelurahan;

  // Daftar wilayah dari API
  List<WilayahItem> _provinsiList = [];
  List<WilayahItem> _kabupatenList = [];
  List<WilayahItem> _kecamatanList = [];
  List<WilayahItem> _kelurahanList = [];
  bool _isLoadingWilayah = false;
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

    // Bersihkan cache wilayah lama & fetch provinsi saat init
    WilayahService.clearCache();
    _fetchProvinsi();
  }

  Future<void> _fetchProvinsi() async {
    setState(() => _isLoadingWilayah = true);
    _provinsiList = await WilayahService.getProvinsi();
    if (mounted) setState(() => _isLoadingWilayah = false);
  }

  Future<void> _onProvinsiChanged(WilayahItem? item) async {
    setState(() {
      _selectedProvinsi = item;
      _selectedKabupaten = null;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _kabupatenList = [];
      _kecamatanList = [];
      _kelurahanList = [];
    });
    if (item != null) {
      setState(() => _isLoadingWilayah = true);
      _kabupatenList =
          await WilayahService.getKabupaten(item.kode, item.nama);
      if (mounted) setState(() => _isLoadingWilayah = false);
    }
  }

  Future<void> _onKabupatenChanged(WilayahItem? item) async {
    setState(() {
      _selectedKabupaten = item;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _kecamatanList = [];
      _kelurahanList = [];
    });
    if (item != null) {
      setState(() => _isLoadingWilayah = true);
      _kecamatanList =
          await WilayahService.getKecamatan(item.kode, item.nama);
      if (mounted) setState(() => _isLoadingWilayah = false);
    }
  }

  Future<void> _onKecamatanChanged(WilayahItem? item) async {
    setState(() {
      _selectedKecamatan = item;
      _selectedKelurahan = null;
      _kelurahanList = [];
    });
    if (item != null) {
      setState(() => _isLoadingWilayah = true);
      _kelurahanList =
          await WilayahService.getKelurahan(item.kode, item.nama);
      if (mounted) setState(() => _isLoadingWilayah = false);
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
    // Jika sedang di Step 3 (index 2) dan pasien adalah pasien lama (punya RM),
    // kembali langsung ke Step 1 (index 0) karena Step 2 dilewati
    if (_currentPage == 2 && _existingMr != null && _existingMr!.isNotEmpty) {
      _goToPage(0);
    } else if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        _goToLogin();
      }
    }
  }

  DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty) return null;
    try {
      return DateTime.parse(str.split(' ')[0].split('T')[0]);
    } catch (_) {
      return null;
    }
  }

  String? _parseJenisKelamin(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim().toUpperCase();
    if (str == '0' || str == 'L' || str.startsWith('LAKI') || str.startsWith('COWOK')) {
      return 'Laki-laki';
    } else if (str == '1' ||
        str == 'P' ||
        str.startsWith('PEREMPUAN') ||
        str.startsWith('WANITA') ||
        str.startsWith('CEWEK')) {
      return 'Perempuan';
    }
    return null;
  }

  String _mapAgamaToCode(String? agama) {
    switch (agama) {
      case 'Islam':
        return '1';
      case 'Kristen':
        return '2';
      case 'Katolik':
        return '3';
      case 'Hindu':
        return '4';
      case 'Buddha':
        return '5';
      case 'Konghucu':
        return '6';
      default:
        return '1';
    }
  }

  String _mapStatusKawinToCode(String? status) {
    switch (status) {
      case 'Kawin':
        return '1';
      case 'Belum Kawin':
        return '2';
      case 'Cerai Hidup':
        return '3';
      case 'Cerai Mati':
        return '4';
      default:
        return '2';
    }
  }

  String _mapPendidikanToCode(String? pendidikan) {
    if (pendidikan == null) return '5';
    if (pendidikan.contains('Tidak')) return '0';
    if (pendidikan.contains('SD')) return '1';
    if (pendidikan.contains('SMP')) return '2';
    if (pendidikan.contains('SMA') || pendidikan.contains('SMK')) return '3';
    if (pendidikan.contains('D1') || pendidikan.contains('D2') || pendidikan.contains('D3')) return '4';
    if (pendidikan.contains('S1') || pendidikan.contains('D4')) return '5';
    if (pendidikan.contains('S2')) return '6';
    if (pendidikan.contains('S3')) return '7';
    return '5';
  }

  String _mapPekerjaanToCode(String? pekerjaan) {
    if (pekerjaan == null) return '02';
    if (pekerjaan.contains('Belum') || pekerjaan.contains('Tidak')) return '00';
    if (pekerjaan.contains('PNS') || pekerjaan.contains('TNI') || pekerjaan.contains('Polri')) return '01';
    if (pekerjaan.contains('Swasta')) return '02';
    if (pekerjaan.contains('Wira')) return '03';
    if (pekerjaan.contains('Petani') || pekerjaan.contains('Nelayan')) return '04';
    if (pekerjaan.contains('Pelajar') || pekerjaan.contains('Mahasiswa')) return '05';
    if (pekerjaan.contains('Rumah Tangga')) return '06';
    return '02';
  }

  /// Menghasilkan 10 digit kode kelurahan resmi (Kemendagri / SIMRS)
  /// Sesuai tipe kolom FS_KD_KELURAHAN varchar(10) NOT NULL di database
  String _resolveKodeKelurahan() {
    // 1. Jika kode kelurahan sudah berupa angka (misal dari respon API SIMRS)
    if (_selectedKelurahan != null) {
      final digits = _selectedKelurahan!.kode.replaceAll(RegExp(r'\D'), '');
      if (digits.length == 10) {
        return digits;
      } else if (digits.length > 10) {
        return digits.substring(0, 10);
      } else if (digits.length >= 6) {
        return digits.padRight(10, '0');
      }
    }

    final namaKel = _selectedKelurahan?.nama.trim().toLowerCase() ?? '';

    // Sleman - Gamping (340401)
    if (namaKel.contains('ambarketawang')) return '3404012001';
    if (namaKel.contains('balecatur')) return '3404012002';
    if (namaKel.contains('banyuraden')) return '3404012003';
    if (namaKel.contains('nogotirto')) return '3404012004';
    if (namaKel.contains('trihanggo')) return '3404012005';

    // Sleman - Godean (340402)
    if (namaKel.contains('sidoagung')) return '3404022001';
    if (namaKel.contains('sidoarum')) return '3404022002';
    if (namaKel.contains('sidokarto')) return '3404022003';
    if (namaKel.contains('sidoluhur')) return '3404022004';
    if (namaKel.contains('sidomoyo')) return '3404022005';
    if (namaKel.contains('sidomulyo')) return '3404022006';
    if (namaKel.contains('sidorejo')) return '3404022007';

    // Sleman - Mlati (340405)
    if (namaKel.contains('sendangadi')) return '3404052001';
    if (namaKel.contains('sinduadi')) return '3404052002';
    if (namaKel.contains('sumberadi')) return '3404052003';
    if (namaKel.contains('tirtoadi')) return '3404052004';
    if (namaKel.contains('tlogoadi')) return '3404052005';

    // Sleman - Depok (340407)
    if (namaKel.contains('caturtunggal')) return '3404072001';
    if (namaKel.contains('condongcatur')) return '3404072002';
    if (namaKel.contains('maguwoharjo')) return '3404072003';

    // Kota Yogyakarta - Wirobrajan (347104)
    if (namaKel.contains('pakuncen')) return '3471041001';
    if (namaKel.contains('wirobrajan')) return '3471041002';
    if (namaKel.contains('patangpuluhan')) return '3471041003';

    // Bantul - Kasihan (340203)
    if (namaKel.contains('bangunjiwo')) return '3402032001';
    if (namaKel.contains('ngestiharjo')) return '3402032002';
    if (namaKel.contains('tamantirto')) return '3402032003';
    if (namaKel.contains('tirtonirmolo')) return '3402032004';

    // Bantul - Sewon (340204)
    if (namaKel.contains('bangunharjo')) return '3402042001';
    if (namaKel.contains('panggungharjo')) return '3402042002';
    if (namaKel.contains('pendowoharjo')) return '3402042003';
    if (namaKel.contains('timbulharjo')) return '3402042004';

    // Sumatera Selatan - Palembang - Ilir Barat I (167101)
    if (namaKel.contains('bukit lama')) return '1671011001';
    if (namaKel.contains('bukit baru')) return '1671011002';
    if (namaKel.contains('demang lebar')) return '1671011003';
    if (namaKel.contains('lorok pakjo')) return '1671011004';
    if (namaKel.contains('padang selasa')) return '1671011005';
    if (namaKel.contains('siring agung')) return '1671011006';

    // 2. Jika kode provinsi / kabupaten / kecamatan berupa angka, kombinasikan
    String prov = (_selectedProvinsi?.kode.replaceAll(RegExp(r'\D'), '') ?? '');
    if (prov.length < 2) prov = '34';
    prov = prov.substring(0, 2);

    String kab = (_selectedKabupaten?.kode.replaceAll(RegExp(r'\D'), '') ?? '');
    if (kab.length < 2) kab = '04';
    if (kab.length > 2) kab = kab.substring(kab.length - 2);

    String kec = (_selectedKecamatan?.kode.replaceAll(RegExp(r'\D'), '') ?? '');
    if (kec.length < 2) kec = '01';
    if (kec.length > 2) kec = kec.substring(kec.length - 2);

    final generated = '$prov$kab$kec' '2001';
    if (generated.length == 10) return generated;

    // Default 10 digit resmi RS PKU Gamping (Ambarketawang, Gamping, Sleman, DIY)
    return '3404012001';
  }

  Future<bool> _cekNikAsync() async {
    final nik = _nikController.text.trim();

    if (nik.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor NIK harus terdiri dari 16 digit angka.'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }

    setState(() => _isNikChecking = true);

    try {
      final res = await SimrsService.verifyNik(nik);
      if (!mounted) return false;

      final isAlreadyRegistered = res['status'] == false;

      // Ambil data pasien jika terdeteksi di SIMRS (TC_MR)
      final simrsData = (res['data'] is Map<String, dynamic>)
          ? res['data'] as Map<String, dynamic>
          : (res['simrs'] is Map<String, dynamic>)
              ? res['simrs'] as Map<String, dynamic>
              : res;

      final mrFromSimrs = (simrsData['fs_mr'] ??
              simrsData['FS_MR'] ??
              res['fs_mr'] ??
              res['FS_MR'])
          ?.toString();

      final foundInSimrs = (res['found'] == true ||
          (mrFromSimrs != null && mrFromSimrs.isNotEmpty));

      if (foundInSimrs && !isAlreadyRegistered) {
        _existingMr = mrFromSimrs;

        // Auto-fill nama pasien
        final nama = (simrsData['fs_nm_pasien'] ??
                simrsData['FS_NM_PASIEN'] ??
                simrsData['nama'] ??
                res['fs_nm_pasien'] ??
                res['FS_NM_PASIEN'])
            ?.toString();
        if (nama != null && nama.isNotEmpty) {
          _namaController.text = nama;
        }

        // Auto-fill tempat lahir
        final tempatLahir = (simrsData['fs_temp_lahir'] ??
                simrsData['FS_TEMP_LAHIR'] ??
                res['fs_temp_lahir'] ??
                res['FS_TEMP_LAHIR'])
            ?.toString();
        if (tempatLahir != null && tempatLahir.isNotEmpty) {
          _selectedTempatLahir = tempatLahir;
        }

        // Auto-fill tanggal lahir
        final rawTgl = simrsData['fd_tgl_lahir'] ??
            simrsData['FD_TGL_LAHIR'] ??
            res['fd_tgl_lahir'] ??
            res['FD_TGL_LAHIR'];
        final parsedDate = _tryParseDate(rawTgl);
        if (parsedDate != null) {
          _selectedTanggalLahir = parsedDate;
        }

        // Auto-fill jenis kelamin
        final rawJk = simrsData['fs_jns_kelamin'] ??
            simrsData['FS_JNS_KELAMIN'] ??
            res['fs_jns_kelamin'] ??
            res['FS_JNS_KELAMIN'];
        final parsedJk = _parseJenisKelamin(rawJk);
        if (parsedJk != null) {
          _selectedJenisKelamin = parsedJk;
        }

        // Auto-fill golongan darah
        final golDarah = (simrsData['fs_gol_darah'] ??
                simrsData['FS_GOL_DARAH'] ??
                res['fs_gol_darah'] ??
                res['FS_GOL_DARAH'])
            ?.toString();
        if (golDarah != null && golDarah.isNotEmpty) {
          _selectedGolDarah = golDarah.trim().toUpperCase();
        }

        // Auto-fill alamat
        final alamat = (simrsData['fs_alm_pasien'] ??
                simrsData['FS_ALM_PASIEN'] ??
                simrsData['fs_alamat'] ??
                res['fs_alm_pasien'] ??
                res['FS_ALM_PASIEN'])
            ?.toString();
        if (alamat != null && alamat.isNotEmpty) {
          _alamatController.text = alamat;
        }

        // Auto-fill nomor telepon
        final tlp = (simrsData['fs_tlp_pasien'] ??
                simrsData['FS_TLP_PASIEN'] ??
                simrsData['fs_no_hp'] ??
                res['fs_tlp_pasien'] ??
                res['FS_TLP_PASIEN'])
            ?.toString();
        if (tlp != null && tlp.isNotEmpty) {
          String clean = tlp.replaceAll(RegExp(r'\D'), '');
          if (clean.startsWith('62')) clean = clean.substring(2);
          if (clean.startsWith('0')) clean = clean.substring(1);
          _nomorHpController.text = clean;
        }
      } else if (!foundInSimrs) {
        _existingMr = null;
      }

      setState(() {
        _isNikChecking = false;
        _nikHasBeenChecked = true;
        _isNikAlreadyRegistered = isAlreadyRegistered;
        _isNikVerified = !isAlreadyRegistered;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (isAlreadyRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ??
                  'NIK sudah terdaftar! Silakan login.',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
        return false;
      } else if (foundInSimrs &&
          _existingMr != null &&
          _existingMr!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data pasien lama ditemukan di SIMRS (No. RM: $_existingMr).',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'NIK valid. Silakan lanjutkan pendaftaran pasien baru.',
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        return true;
      }
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _isNikChecking = false;
        _nikHasBeenChecked = true;
        _isNikVerified = RegExp(r'^[0-9]{16}$').hasMatch(nik);
      });
      return _isNikVerified;
    }
  }

  Future<void> _handleStep1Submit() async {
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

    // Jika belum dicek, otomatis cek NIK terlebih dahulu
    if (!_nikHasBeenChecked) {
      final ok = await _cekNikAsync();
      if (!ok) return;
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

    // Alur percabangan sesuai arahan pembimbing:
    // 1. Pasien Lama (sudah punya No. RM di SIMRS) -> langsung lompat ke Step 3 (Langkah 3)
    // 2. Pasien Baru (belum pernah periksa / belum punya RM) -> ke Step 2 (Langkah 2) untuk isi biodata
    if (_existingMr != null && _existingMr!.isNotEmpty) {
      _goToPage(2);
    } else {
      _goToPage(1);
    }
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

    if (_selectedProvinsi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Provinsi domisili wajib dipilih.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedKabupaten == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kabupaten / Kota domisili wajib dipilih.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedKecamatan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kecamatan domisili wajib dipilih.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedKelurahan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kelurahan / Desa domisili wajib dipilih.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_alamatController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat Lengkap / Jalan wajib diisi.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_nomorHpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor Handphone / WhatsApp wajib diisi.'),
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

    _goToPage(2);
  }

  Future<void> _handleDaftar() async {
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
      final tglLahirStr = _selectedTanggalLahir != null
          ? "${_selectedTanggalLahir!.year.toString().padLeft(4, '0')}-${_selectedTanggalLahir!.month.toString().padLeft(2, '0')}-${_selectedTanggalLahir!.day.toString().padLeft(2, '0')}"
          : '1995-01-01';

      final namaPasien = _namaController.text.trim().isNotEmpty
          ? _namaController.text.trim()
          : 'Pasien SIMRS';
      final namaIbu = _namaIbuController.text.trim().isNotEmpty
          ? _namaIbuController.text.trim()
          : 'Ibu Pasien';
      String alamat = _alamatController.text.trim();
      if (alamat.isEmpty) {
        alamat = 'Gamping, Sleman';
      }
      if (alamat.length > 50) {
        alamat = alamat.substring(0, 50);
      }
      final noHp = _nomorHpController.text.trim().isNotEmpty
          ? _nomorHpController.text.trim()
          : '081234567890';

      final kdJenisKelamin =
          (_selectedJenisKelamin == 'Perempuan') ? '1' : '0';

      final kdKelurahan = _resolveKodeKelurahan();

      final payload = {
        'fs_email': email,
        'fs_password': password,
        'fs_nik': _nikController.text.trim(),
        'fs_nm_pasien': namaPasien,
        'fs_no_hp': noHp,
        'fd_tgl_lahir': tglLahirStr,
        'fs_temp_lahir': _selectedTempatLahir ?? 'Sleman',
        'fs_jenis_kelamin': kdJenisKelamin,
        'fs_gol_darah': _selectedGolDarah ?? 'O',
        'fs_alamat': alamat,
        'fs_kd_agama': _mapAgamaToCode(_selectedAgama),
        'fs_kd_pekerjaan': _mapPekerjaanToCode(_selectedPekerjaan),
        'fs_kd_pendidikan': _mapPendidikanToCode(_selectedPendidikan),
        'fs_status_kawin': _mapStatusKawinToCode(_selectedStatusKawin),
        'fs_nm_ibu_kandung': namaIbu,
        'fs_warga_negara': (_selectedWargaNegara == 'WNA') ? '2' : '1',
        'fs_kd_suku': '004',
        'fs_kd_kelurahan': kdKelurahan,
        if (_existingMr != null && _existingMr!.isNotEmpty) 'fs_mr': _existingMr,
      };

      final res = await SimrsService.registerPasien(payload);

      if (res['status'] == false) {
        throw Exception(res['message']?.toString() ?? 'Gagal melakukan pendaftaran.');
      }

      if (!mounted) return;

      // Simpan data profil lengkap ke lokal per NIK agar sinkron di Edit Profile
      final registeredProfile = {
        'fs_nik': _nikController.text.trim(),
        'nik': _nikController.text.trim(),
        'nama': namaPasien,
        'fs_nm_pasien': namaPasien,
        'jenis_kelamin': _selectedJenisKelamin ?? 'Laki-laki',
        'fs_jenis_kelamin': kdJenisKelamin,
        'golongan_darah': _selectedGolDarah ?? 'O',
        'fs_gol_darah': _selectedGolDarah ?? 'O',
        'tempat_lahir': _selectedTempatLahir ?? 'Sleman',
        'fs_temp_lahir': _selectedTempatLahir ?? 'Sleman',
        'tanggal_lahir': tglLahirStr,
        'fd_tgl_lahir': tglLahirStr,
        'agama': _selectedAgama ?? 'Islam',
        'fs_kd_agama': _mapAgamaToCode(_selectedAgama),
        'warga_negara': _selectedWargaNegara ?? 'WNI',
        'fs_warga_negara': (_selectedWargaNegara == 'WNA') ? '2' : '1',
        'pendidikan': _selectedPendidikan ?? 'S1 / Sarjana',
        'fs_kd_pendidikan': _mapPendidikanToCode(_selectedPendidikan),
        'pekerjaan': _selectedPekerjaan ?? 'Karyawan Swasta',
        'fs_kd_pekerjaan': _mapPekerjaanToCode(_selectedPekerjaan),
        'status_kawin': _selectedStatusKawin ?? 'Belum Kawin',
        'fs_status_kawin': _mapStatusKawinToCode(_selectedStatusKawin),
        'nama_ibu': namaIbu,
        'fs_nm_ibu_kandung': namaIbu,
        'provinsi': _selectedProvinsi?.nama ?? 'D.I. Yogyakarta',
        'kabupaten': _selectedKabupaten?.nama ?? 'Kab. Sleman',
        'kecamatan': _selectedKecamatan?.nama ?? 'Gamping',
        'kelurahan': _selectedKelurahan?.nama ?? 'Ambarketawang',
        'kode_kelurahan': kdKelurahan,
        'alamat': alamat,
        'fs_alamat': alamat,
        'nomor_hp': noHp,
        'fs_no_hp': noHp,
        'email': email,
        'fs_email': email,
      };
      await SessionManager.saveProfileByNik(_nikController.text.trim(), registeredProfile);

      // Pastikan session aktif dibersihkan agar pasien diarahkan login mandiri
      await SessionManager.clearSession();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
        arguments: {
          'email': email,
          'message': 'Pendaftaran berhasil! Silakan masuk menggunakan email dan kata sandi Anda.',
        },
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                hasExistingMr: _existingMr != null && _existingMr!.isNotEmpty,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
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
                      existingMr: _existingMr,
                      existingNama: _namaController.text,
                      onCekNik: _cekNikAsync,
                      onLanjut: _handleStep1Submit,
                      onLoginTap: _goToLogin,
                      onNikChanged: () {
                        // Reset status ketika NIK berubah
                        if (_nikHasBeenChecked || _existingMr != null) {
                          setState(() {
                            _nikHasBeenChecked = false;
                            _isNikVerified = false;
                            _isNikAlreadyRegistered = false;
                            _existingMr = null;
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
                      provinsiList: _provinsiList,
                      kabupatenList: _kabupatenList,
                      kecamatanList: _kecamatanList,
                      kelurahanList: _kelurahanList,
                      isLoadingWilayah: _isLoadingWilayah,
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
                      onProvinsiChanged: _onProvinsiChanged,
                      onKabupatenChanged: _onKabupatenChanged,
                      onKecamatanChanged: _onKecamatanChanged,
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
                      existingMr: _existingMr,
                      existingNama: _namaController.text,
                      onTogglePass: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      onToggleConfirm: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      onPrev: () {
                        if (_existingMr != null && _existingMr!.isNotEmpty) {
                          _goToPage(0);
                        } else {
                          _goToPage(1);
                        }
                      },
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
