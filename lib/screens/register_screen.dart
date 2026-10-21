
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

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

    _alamatController.addListener(() {
      setState(() {});
    });

    _emailKontakController.addListener(() {
      if (_emailController.text.isEmpty && _currentPage < 2) {
        _emailController.text = _emailKontakController.text;
      }
    });
  }

  @override
  void dispose() {
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

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _isNikChecking = false;
      _isNikVerified = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('NIK valid dan terhubung dengan SIMRS PKU Gamping.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleStep1Submit() {
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

    // Auto-isi email langkah 3 jika belum diisi manual.
    if (_emailController.text.trim().isEmpty &&
        _emailKontakController.text.trim().isNotEmpty) {
      _emailController.text = _emailKontakController.text.trim();
    }

    // Buat saran username jika masih kosong.
    if (_usernameController.text.trim().isEmpty &&
        _namaController.text.trim().isNotEmpty) {
      final sanitized = _namaController.text
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '');

      _usernameController.text = sanitized.isNotEmpty
          ? '${sanitized}_${_nikController.text.length >= 4 ? _nikController.text.substring(12) : "pku"}'
          : 'pasien_pku';
    }

    _goToPage(2);
  }

  void _handleDaftar() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan alamat email yang valid.'),
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

    await Future.delayed(const Duration(milliseconds: 700));

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
              _buildTopHeader(),
              _buildStepperSection(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (idx) {
                    setState(() => _currentPage = idx);
                  },
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Top Header
  Widget _buildTopHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: _prevPage,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Pasien Baru',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Lengkapi data diri Anda untuk mendaftar akun baru',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stepper Section
  Widget _buildStepperSection() {
    final stepTitles = ['Cek Identitas', 'Data Pasien', 'Keamanan'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentPage == 0) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Registrasi Online SIMRS',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Buat Akun Baru',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Lengkapi data diri Anda untuk membuat akun dan terhubung ke sistem RS PKU Muhammadiyah Gamping.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
          ] else if (_currentPage == 2) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'RS PKU MUHAMMADIYAH GAMPING',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Buat Akun Baru',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Lengkapi data di bawah ini untuk membuat akun baru di PKU Muhammadiyah Gamping',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Langkah ${_currentPage + 1} dari $_totalPages',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  stepTitles[_currentPage],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: List.generate(_totalPages, (i) {
              final isPassedOrCurrent = i <= _currentPage;

              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    left: i == 0 ? 0 : 3,
                    right: i == _totalPages - 1 ? 0 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: isPassedOrCurrent
                        ? AppColors.primary
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(child: _buildStepTab(0, '1. Cek NIK')),
              Expanded(child: _buildStepTab(1, '2. Data Pasien')),
              Expanded(child: _buildStepTab(2, '3. Keamanan')),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  Widget _buildStepTab(int index, String label) {
    final active = _currentPage == index;
    final done = _currentPage > index;

    return GestureDetector(
      onTap: () {
        if (index <= _currentPage) {
          _goToPage(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: active || done ? FontWeight.w600 : FontWeight.w400,
            color: active
                ? AppColors.primary
                : (done ? AppColors.textPrimary : AppColors.textHint),
          ),
        ),
      ),
    );
  }

  // STEP 1: Cek NIK
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Identitas Pasien',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Pastikan nomor 16 digit NIK Anda valid dan sesuai KTP untuk pemeriksaan data.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _fieldLabel('NIK (Nomor KTP) *'),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isNikVerified
                        ? AppColors.success
                        : AppColors.border,
                    width: _isNikVerified ? 1.5 : 1,
                  ),
                  color: AppColors.background,
                ),
                child: Row(
                  children: [
                    // Ikon kartu dihapus; input tetap memiliki jarak yang rapi.
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: TextFormField(
                          controller: _nikController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                          ],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Contoh: 347104xxxxxxxxx',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          onChanged: (val) {
                            if (_isNikVerified) {
                              setState(() => _isNikVerified = false);
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: _isNikChecking ? null : _cekNikAsync,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isNikVerified
                              ? const Color(0xFFE8F5E9)
                              : AppColors.primary,
                          foregroundColor: _isNikVerified
                              ? const Color(0xFF2E7D32)
                              : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isNikChecking
                            ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isNikVerified) ...[
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              _isNikVerified ? 'Valid' : 'Cek NIK',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pastikan nomor NIK sesuai dengan KTP Anda.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pendaftaran Pasien Baru',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nomor Rekam Medis (No. RM) baru akan dibuatkan secara otomatis berdasarkan data identitas di atas.\n\nTerkoneksi dengan Sistem SIMRS RS PKU Muhammadiyah Gamping.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFFB45309),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleStep1Submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cek NIK & Lanjutkan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Footer login dihapus.
        ],
      ),
    );
  }

  // STEP 2: Data Pasien
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lengkapi data diri Anda untuk membuat akun dan terhubung ke sistem RS PKU Muhammadiyah Gamping.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          _sectionBadgeHeader(
            icon: Icons.person_outline_rounded,
            title: 'Data Pasien',
            badge: 'Wajib',
            subtitle: 'Identitas sesuai KTP, KK, atau Paspor',
          ),
          const SizedBox(height: 10),
          _card(
            children: [
              _fieldLabel('Nama Lengkap *'),
              _inputField(
                controller: _namaController,
                hint: 'Masukkan nama lengkap sesuai KTP',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Tempat Lahir *'),
                        _inputField(
                          controller: _tempatLahirController,
                          hint: 'Kota Lahir',
                          icon: Icons.location_city_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Tanggal Lahir *'),
                        _datePicker(context),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Jenis Kelamin *'),
                        _dropdown(
                          initialValue: _selectedJenisKelamin,
                          items: const ['Laki-laki', 'Perempuan'],
                          hint: 'Pilih',
                          icon: Icons.wc_rounded,
                          onChanged: (v) =>
                              setState(() => _selectedJenisKelamin = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Gol. Darah *'),
                        _dropdown(
                          initialValue: _selectedGolDarah,
                          items: const ['A', 'B', 'AB', 'O', 'Tidak Tahu'],
                          hint: 'Pilih',
                          icon: Icons.bloodtype_outlined,
                          onChanged: (v) =>
                              setState(() => _selectedGolDarah = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Agama *'),
                        _dropdown(
                          initialValue: _selectedAgama,
                          items: const [
                            'Islam',
                            'Kristen',
                            'Katolik',
                            'Hindu',
                            'Buddha',
                            'Konghucu',
                            'Lainnya',
                          ],
                          hint: 'Pilih Agama',
                          icon: Icons.account_balance_outlined,
                          onChanged: (v) => setState(() => _selectedAgama = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Warga Negara *'),
                        _dropdown(
                          initialValue: _selectedWargaNegara,
                          items: const ['WNI', 'WNA'],
                          hint: 'Pilih',
                          icon: Icons.flag_outlined,
                          onChanged: (v) =>
                              setState(() => _selectedWargaNegara = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _fieldLabel('Pekerjaan *'),
              _dropdown(
                initialValue: _selectedPekerjaan,
                items: const [
                  'PNS / TNI / POLRI',
                  'Karyawan Swasta',
                  'Wiraswasta',
                  'Petani / Peternak',
                  'Pelajar / Mahasiswa',
                  'Ibu Rumah Tangga',
                  'Pensiunan',
                  'Belum / Tidak Bekerja',
                  'Lainnya',
                ],
                hint: 'Pilih Pekerjaan',
                icon: Icons.work_outline_rounded,
                onChanged: (v) => setState(() => _selectedPekerjaan = v),
              ),
              const SizedBox(height: 12),

              _fieldLabel('Pendidikan Terakhir *'),
              _dropdown(
                initialValue: _selectedPendidikan,
                items: const [
                  'SD / Sederajat',
                  'SMP / Sederajat',
                  'SMA / SMK / Sederajat',
                  'D1 / D2 / D3',
                  'S1 / Sarjana',
                  'S2 / Magister',
                  'S3 / Doktoral',
                  'Tidak / Belum Sekolah',
                ],
                hint: 'Pilih Pendidikan Terakhir',
                icon: Icons.school_outlined,
                onChanged: (v) => setState(() => _selectedPendidikan = v),
              ),
              const SizedBox(height: 12),

              _fieldLabel('Status Kawin *'),
              _dropdown(
                initialValue: _selectedStatusKawin,
                items: const [
                  'Belum Kawin',
                  'Kawin',
                  'Cerai Hidup',
                  'Cerai Mati',
                ],
                hint: 'Pilih Status Perkawinan',
                icon: Icons.family_restroom_outlined,
                onChanged: (v) => setState(() => _selectedStatusKawin = v),
              ),
              const SizedBox(height: 12),

              _fieldLabel('Nama Ibu Kandung *'),
              _inputField(
                controller: _namaIbuController,
                hint: 'Nama lengkap ibu kandung',
                icon: Icons.face_retouching_natural_outlined,
              ),
              const SizedBox(height: 4),
              Text(
                'Wajib diisi sesuai Kartu Keluarga (KK)',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _sectionBadgeHeader(
            icon: Icons.home_outlined,
            title: 'Alamat Tempat Tinggal',
            badge: 'Domisili',
            subtitle:
            'Alamat domisili saat ini (tidak harus sama dengan KTP/KK)',
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pilih lokasi untuk mempermudah saat kunjungan',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _card(
            children: [
              _fieldLabel('Provinsi *'),
              _dropdown(
                initialValue: _selectedProvinsi,
                items: const [
                  'D.I. Yogyakarta',
                  'Jawa Tengah',
                  'Jawa Timur',
                  'Jawa Barat',
                  'DKI Jakarta',
                  'Banten',
                  'Bali',
                  'Lainnya',
                ],
                hint: 'Pilih Provinsi',
                icon: Icons.map_outlined,
                onChanged: (v) => setState(() => _selectedProvinsi = v),
              ),
              const SizedBox(height: 12),

              _fieldLabel('Kabupaten / Kota *'),
              _dropdown(
                initialValue: _selectedKabupaten,
                items: const [
                  'Kab. Sleman',
                  'Kab. Bantul',
                  'Kota Yogyakarta',
                  'Kab. Kulon Progo',
                  'Kab. Gunungkidul',
                  'Kab. Magelang',
                  'Kab. Klaten',
                  'Lainnya',
                ],
                hint: 'Pilih Kabupaten / Kota',
                icon: Icons.location_city_outlined,
                onChanged: (v) => setState(() => _selectedKabupaten = v),
              ),
              const SizedBox(height: 12),

              _fieldLabel('Kecamatan *'),
              _dropdown(
                initialValue: _selectedKecamatan,
                items: const [
                  'Gamping',
                  'Godean',
                  'Mlati',
                  'Seyegan',
                  'Depok',
                  'Kasihan',
                  'Sedayu',
                  'Pajangan',
                  'Lainnya',
                ],
                hint: 'Pilih Kecamatan',
                icon: Icons.navigation_outlined,
                onChanged: (v) => setState(() => _selectedKecamatan = v),
              ),
              const SizedBox(height: 12),

              _fieldLabel('Kelurahan / Desa *'),
              _dropdown(
                initialValue: _selectedKelurahan,
                items: const [
                  'Ambarketawang',
                  'Balecatur',
                  'Banyuraden',
                  'Nogotirto',
                  'Trihanggo',
                  'Sidoagung',
                  'Sidomoyo',
                  'Lainnya',
                ],
                hint: 'Pilih Kelurahan / Desa',
                icon: Icons.home_work_outlined,
                onChanged: (v) => setState(() => _selectedKelurahan = v),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: _fieldLabel('Alamat Lengkap / Jalan *')),
                  Text(
                    '${_alamatController.text.length}/150 karakter',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              _inputField(
                controller: _alamatController,
                hint: 'Masukkan nama jalan, RT/RW, nomor rumah, patokan alamat',
                icon: Icons.home_outlined,
                maxLines: 2,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(150),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          _sectionBadgeHeader(
            icon: Icons.contact_phone_outlined,
            title: 'Kontak Pasien',
            badge: 'Aktif',
            subtitle: 'Informasi kontak untuk verifikasi & notifikasi',
          ),
          const SizedBox(height: 10),

          _card(
            children: [
              _fieldLabel('No. Handphone / WhatsApp *'),
              TextFormField(
                controller: _nomorHpController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '812-3456-7890',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_android_outlined,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+62',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _fieldLabel('Alamat Email *'),
              _inputField(
                controller: _emailKontakController,
                hint: 'contoh@email.com',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 6),
              Text(
                'Status verifikasi melalui nomor telepon / WhatsApp & email Anda.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tombol Kembali & Lanjut Langkah 3.
          // Ikon pada tombol Lanjut Langkah 3 dihapus.
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _goToPage(0),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                    ),
                    label: Text(
                      'Kembali',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      foregroundColor: AppColors.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handleStep2Submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Lanjut Langkah 3',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Footer login dihapus dan jarak bawah dirapikan.
        ],
      ),
    );
  }

  // STEP 3: Buat Akun & Keamanan
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionBadgeHeader(
            icon: Icons.shield_outlined,
            title: 'Akun & Sandi',
            badge: 'Keamanan',
            subtitle: 'Buat akun untuk login ke aplikasi PKU Gamping',
          ),
          const SizedBox(height: 12),

          _card(
            children: [
              _fieldLabel('Alamat Email *'),
              _inputField(
                controller: _emailController,
                hint: 'pasien.gamping@gmail.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              _fieldLabel('Username *'),
              _inputField(
                controller: _usernameController,
                hint: 'pku_gamping2381',
                icon: Icons.account_circle_outlined,
              ),
              const SizedBox(height: 14),

              _fieldLabel('Kata Sandi Baru *'),
              _passInputField(
                controller: _passwordController,
                hint: 'Minimal 8 karakter',
                obscure: _obscurePass,
                onToggle: () {
                  setState(() => _obscurePass = !_obscurePass);
                },
              ),
              const SizedBox(height: 14),

              _fieldLabel('Konfirmasi Kata Sandi *'),
              _passInputField(
                controller: _confirmPasswordController,
                hint: 'Ulangi kata sandi',
                obscure: _obscureConfirm,
                onToggle: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Minimal 8 karakter, kombinasi huruf, angka & simbol',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleDaftar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : Text(
                'Daftar',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Center(
            child: Text(
              'Dengan membuat akun, Anda menyetujui Syarat & Ketentuan serta Kebijakan Privasi layanan digital RS PKU Muhammadiyah Gamping.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),

          // Tombol Kembali dan teks "Sudah punya akun? Masuk" dihapus.
          // Jarak kosong tambahan juga dihapus.
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _sectionBadgeHeader({
    required IconData icon,
    required String title,
    required String badge,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.textHint,
        ),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 18),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _passInputField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.textHint,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.textHint,
          size: 18,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textHint,
            size: 18,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String? initialValue,
    required List<String> items,
    required String hint,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    final validValue = items.contains(initialValue) ? initialValue : null;

    return DropdownButtonFormField<String>(
      initialValue: validValue,
      onChanged: onChanged,
      isExpanded: true,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textHint,
        size: 20,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.textHint,
        ),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 18),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: Text(
            e,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _datePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedTanggalLahir ?? DateTime(1995, 1, 1),
          firstDate: DateTime(1930),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          ),
        );

        if (picked != null) {
          setState(() => _selectedTanggalLahir = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textHint,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedTanggalLahir == null
                    ? 'Pilih Tanggal'
                    : '${_selectedTanggalLahir!.day.toString().padLeft(2, '0')}/${_selectedTanggalLahir!.month.toString().padLeft(2, '0')}/${_selectedTanggalLahir!.year}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _selectedTanggalLahir == null
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
