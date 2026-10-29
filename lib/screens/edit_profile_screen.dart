import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/data/wilayah_data.dart';
import 'package:pku_gamping_app/services/app_notification_service.dart';
import 'package:pku_gamping_app/services/profile_photo_service.dart';

/// Halaman Edit Profil Pasien RS PKU Muhammadiyah Gamping.
/// 
/// Desain natural, clean, dan terstruktur sesuai alur pendaftaran SIMRS:
/// 1. Data Pasien (Read-only: NIK, Nama sesuai KTP, Jenis Kelamin dengan ikon gembok)
/// 2. Alamat Domisili (Provinsi, Kabupaten, Kecamatan, Kelurahan, Alamat Lengkap)
/// 3. Kontak (No. HP & Email)
/// 4. Keamanan Akun (Opsi ganti sandi dengan verifikasi kata sandi saat ini)
///
/// Dilengkapi fitur expand/collapse section dan layout 2 kolom yang efisien.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ── State Expand / Collapse Section ──
  bool _isDataPasienExpanded = true;
  bool _isAlamatExpanded = true;
  bool _isKontakExpanded = true;
  bool _isKeamananExpanded = true;

  // ── 1. Data Pasien ──
  late final String _nik;
  late final String _namaKtp;
  late final String _jenisKelamin;

  String? _selectedTempatLahir;
  DateTime? _selectedTanggalLahir;
  String? _selectedGolDarah;
  String? _selectedAgama;
  String? _selectedWargaNegara;
  String? _selectedPendidikan;
  String? _selectedPekerjaan;
  String? _selectedStatusKawin;
  late final TextEditingController _namaIbuController;

  // ── 2. Alamat ──
  String? _selectedProvinsi;
  String? _selectedKabupaten;
  String? _selectedKecamatan;
  String? _selectedKelurahan;
  late final TextEditingController _alamatController;

  // ── 3. Kontak ──
  late final TextEditingController _nomorHpController;
  late final TextEditingController _emailController;

  // ── Status Penyimpanan ──
  bool _isSaving = false;

  // ── Konstanta Pilihan Dropdown ──
  static const List<String> _listGolDarah = [
    'A',
    'B',
    'AB',
    'O',
    'Tidak Tahu',
  ];

  static const List<String> _listAgama = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
    'Lainnya',
  ];

  static const List<String> _listWargaNegara = [
    'WNI',
    'WNA',
  ];

  static const List<String> _listPendidikan = [
    'SD / Sederajat',
    'SMP / Sederajat',
    'SMA / SMK / Sederajat',
    'D1 / D2 / D3',
    'S1 / Sarjana',
    'S2 / Magister',
    'S3 / Doktoral',
    'Tidak / Belum Sekolah',
  ];

  static const List<String> _listPekerjaan = [
    'PNS / TNI / POLRI',
    'Karyawan Swasta',
    'Wiraswasta',
    'Petani / Peternak',
    'Pelajar / Mahasiswa',
    'Ibu Rumah Tangga',
    'Pensiunan',
    'Belum / Tidak Bekerja',
    'Lainnya',
  ];

  static const List<String> _listStatusKawin = [
    'Belum Kawin',
    'Kawin',
    'Cerai Hidup',
    'Cerai Mati',
  ];

  @override
  void initState() {
    super.initState();

    final patientData = SessionManager.patientData;

    // Data Read-Only identitas
    _namaKtp = SessionManager.namaPasien;
    _nik = SessionManager.nik ?? '3471040506920001';
    _jenisKelamin = 'Laki-laki';

    // Data Pasien editable
    _selectedTempatLahir = patientData?['tempat_lahir'] as String? ?? 'Yogyakarta';
    _selectedTanggalLahir = DateTime(1990, 5, 14);
    _selectedGolDarah = patientData?['golongan_darah'] as String? ?? 'O';
    _selectedAgama = patientData?['agama'] as String? ?? 'Islam';
    _selectedWargaNegara = patientData?['warga_negara'] as String? ?? 'WNI';
    _selectedPendidikan = patientData?['pendidikan'] as String? ?? 'S1 / Sarjana';
    _selectedPekerjaan = patientData?['pekerjaan'] as String? ?? 'Karyawan Swasta';
    _selectedStatusKawin = patientData?['status_kawin'] as String? ?? 'Kawin';
    _namaIbuController = TextEditingController(
      text: patientData?['nama_ibu'] as String? ?? 'Siti Aminah',
    );

    // Alamat
    _selectedProvinsi = patientData?['provinsi'] as String? ?? 'D.I. Yogyakarta';
    _selectedKabupaten = patientData?['kabupaten'] as String? ?? 'Kab. Sleman';
    _selectedKecamatan = patientData?['kecamatan'] as String? ?? 'Gamping';
    _selectedKelurahan = patientData?['kelurahan'] as String? ?? 'Ambarketawang';
    _alamatController = TextEditingController(
      text: patientData?['alamat'] as String? ??
          'Jl. Wates Km. 5, Ambarketawang, Gamping',
    );

    // Kontak
    _nomorHpController = TextEditingController(
      text: patientData?['nomor_hp'] as String? ?? '081234567890',
    );
    _emailController = TextEditingController(
      text: SessionManager.username ?? 'dahlan.muda@gmail.com',
    );
  }

  @override
  void dispose() {
    _namaIbuController.dispose();
    _alamatController.dispose();
    _nomorHpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Simulasi penyimpanan di sisi frontend
  Future<void> _handleSave() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    // Simulasi delay operasi simpan
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // Simpan data ke session lokal
    final currentData = SessionManager.patientData ?? {};
    final updatedData = Map<String, dynamic>.from(currentData);
    updatedData['golongan_darah'] = _selectedGolDarah;
    updatedData['tempat_lahir'] = _selectedTempatLahir;
    updatedData['agama'] = _selectedAgama;
    updatedData['warga_negara'] = _selectedWargaNegara;
    updatedData['pendidikan'] = _selectedPendidikan;
    updatedData['pekerjaan'] = _selectedPekerjaan;
    updatedData['status_kawin'] = _selectedStatusKawin;
    updatedData['nama_ibu'] = _namaIbuController.text.trim();
    updatedData['provinsi'] = _selectedProvinsi;
    updatedData['kabupaten'] = _selectedKabupaten;
    updatedData['kecamatan'] = _selectedKecamatan;
    updatedData['kelurahan'] = _selectedKelurahan;
    updatedData['alamat'] = _alamatController.text.trim();
    updatedData['nomor_hp'] = _nomorHpController.text.trim();
    await SessionManager.savePatientData(updatedData);

    if (!mounted) return;

    setState(() => _isSaving = false);

    // Tampilkan notifikasi floating SnackBar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Perubahan berhasil disimpan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );

    // Langsung kembali ke halaman profil
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _openChangePasswordBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _ChangePasswordBottomSheet(),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    final nama = SessionManager.namaPasien;
    final parts = nama.trim().split(RegExp(r'\s+'));
    final inisial = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (parts.isNotEmpty && parts[0].isNotEmpty ? parts[0].substring(0, 1).toUpperCase() : 'DM');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => ProfilePhotoService.showPhotoActionSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                // Avatar dengan Badge Kamera
                ValueListenableBuilder<String?>(
                  valueListenable: SessionManager.profilePhotoNotifier,
                  builder: (context, photoPath, _) {
                    final hasPhoto = photoPath != null &&
                        photoPath.isNotEmpty &&
                        File(photoPath).existsSync();

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: hasPhoto
                                ? Image.file(
                                    File(photoPath),
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text(
                                      inisial,
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E40AF),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Tombol Ubah Foto
                IgnorePointer(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.photo_camera_outlined, size: 16),
                    label: const Text(
                      'Ubah Foto Profil',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mendukung foto JPG/PNG (Maksimal 5 MB)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cascading dropdown wilayah
    final kabupatenList =
        WilayahData.getKabupatenByProvinsi(_selectedProvinsi);
    final kecamatanList =
        WilayahData.getKecamatanByKabupaten(_selectedKabupaten);
    final kelurahanList =
        WilayahData.getKelurahanByKecamatan(_selectedKecamatan);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1E3A8A),
            size: 24,
          ),
          tooltip: 'Kembali ke Profil',
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RS PKU GAMPING',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB),
                letterSpacing: 0.6,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Edit Profil',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ValueListenableBuilder<bool>(
              valueListenable: AppNotificationService.isEnabledNotifier,
              builder: (context, isEnabled, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: AppNotificationService.unreadCountNotifier,
                  builder: (context, unreadCount, _) {
                    return IconButton(
                      icon: SizedBox(
                        width: 28,
                        height: 28,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              isEnabled
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_none_rounded,
                              color: isEnabled
                                  ? AppColors.primary
                                  : const Color(0xFF64748B),
                              size: 24,
                            ),
                            if (!isEnabled)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: Colors.white, width: 1.5),
                                  ),
                                ),
                              )
                            else if (unreadCount > 0)
                              Positioned(
                                top: -2,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    unreadCount > 9 ? '9+' : '$unreadCount',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      tooltip:
                          isEnabled ? 'Pusat Notifikasi' : 'Aktifkan Notifikasi',
                      onPressed: () {
                        AppNotificationService.handleBellTap(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              disabledForegroundColor: const Color(0xFF94A3B8),
              minimumSize: const Size(double.infinity, 48),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 0. Section: Foto Profil ──
                _buildPhotoSection(context),
                const SizedBox(height: 14),

                // ── 1. Section: Data Pasien ──
                _buildCollapsibleSection(
                  title: 'Data Pasien',
                  subtitle: 'Identitas utama pasien sesuai KTP',
                  icon: Icons.person_outline_rounded,
                  isExpanded: _isDataPasienExpanded,
                  onToggle: () {
                    setState(() {
                      _isDataPasienExpanded = !_isDataPasienExpanded;
                    });
                  },
                  content: [
                    // Keterangan khusus identitas terkunci
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 15,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'NIK, Nama, dan Jenis Kelamin terkunci sesuai rekam medis resmi.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // NIK (Read-Only)
                    _buildFieldLabel('NIK'),
                    _buildReadOnlyField(
                      value: _nik,
                      icon: Icons.lock_rounded,
                    ),
                    const SizedBox(height: 12),

                    // Nama sesuai KTP (Read-Only)
                    _buildFieldLabel('Nama sesuai KTP'),
                    _buildReadOnlyField(
                      value: _namaKtp,
                      icon: Icons.lock_rounded,
                    ),
                    const SizedBox(height: 12),

                    // Jenis Kelamin (Read-Only) & Golongan Darah (2 Kolom)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Jenis Kelamin'),
                              _buildReadOnlyField(
                                value: _jenisKelamin,
                                icon: Icons.lock_rounded,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Golongan Darah'),
                              _buildDropdown(
                                initialValue: _selectedGolDarah,
                                items: _listGolDarah,
                                hint: 'Pilih Gol.',
                                onChanged: (val) {
                                  setState(() => _selectedGolDarah = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tempat Lahir & Tanggal Lahir (2 Kolom)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Tempat Lahir'),
                              _buildSearchableTempatLahirDropdown(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Tanggal Lahir'),
                              _buildDatePicker(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Agama & Warga Negara (2 Kolom)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Agama'),
                              _buildDropdown(
                                initialValue: _selectedAgama,
                                items: _listAgama,
                                hint: 'Pilih Agama',
                                onChanged: (val) {
                                  setState(() => _selectedAgama = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Warga Negara'),
                              _buildDropdown(
                                initialValue: _selectedWargaNegara,
                                items: _listWargaNegara,
                                hint: 'Pilih',
                                onChanged: (val) {
                                  setState(() => _selectedWargaNegara = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Pendidikan Terakhir & Pekerjaan (2 Kolom)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Pendidikan Terakhir'),
                              _buildDropdown(
                                initialValue: _selectedPendidikan,
                                items: _listPendidikan,
                                hint: 'Pilih Pendidikan',
                                onChanged: (val) {
                                  setState(() => _selectedPendidikan = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Pekerjaan'),
                              _buildDropdown(
                                initialValue: _selectedPekerjaan,
                                items: _listPekerjaan,
                                hint: 'Pilih Pekerjaan',
                                onChanged: (val) {
                                  setState(() => _selectedPekerjaan = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Status Kawin & Nama Ibu Kandung
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Status Perkawinan'),
                              _buildDropdown(
                                initialValue: _selectedStatusKawin,
                                items: _listStatusKawin,
                                hint: 'Pilih Status',
                                onChanged: (val) {
                                  setState(() => _selectedStatusKawin = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Nama Ibu Kandung'),
                              _buildTextInput(
                                controller: _namaIbuController,
                                hint: 'Nama lengkap ibu',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── 2. Section: Alamat ──
                _buildCollapsibleSection(
                  title: 'Alamat',
                  subtitle: 'Domisili tempat tinggal saat ini',
                  icon: Icons.home_outlined,
                  isExpanded: _isAlamatExpanded,
                  onToggle: () {
                    setState(() {
                      _isAlamatExpanded = !_isAlamatExpanded;
                    });
                  },
                  content: [
                    // Provinsi & Kabupaten (2 Kolom)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Provinsi'),
                              _buildDropdown(
                                initialValue: _selectedProvinsi,
                                items: WilayahData.provinsiList,
                                hint: 'Pilih Provinsi',
                                onChanged: (val) {
                                  setState(() {
                                    _selectedProvinsi = val;
                                    _selectedKabupaten = null;
                                    _selectedKecamatan = null;
                                    _selectedKelurahan = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Kabupaten / Kota'),
                              _buildDropdown(
                                key: ValueKey('kab_$_selectedProvinsi'),
                                initialValue: _selectedKabupaten,
                                items: kabupatenList,
                                hint: 'Pilih Kab/Kota',
                                onChanged: (val) {
                                  setState(() {
                                    _selectedKabupaten = val;
                                    _selectedKecamatan = null;
                                    _selectedKelurahan = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Kecamatan & Kelurahan (2 Kolom)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Kecamatan'),
                              _buildDropdown(
                                key: ValueKey('kec_$_selectedKabupaten'),
                                initialValue: _selectedKecamatan,
                                items: kecamatanList,
                                hint: 'Pilih Kecamatan',
                                onChanged: (val) {
                                  setState(() {
                                    _selectedKecamatan = val;
                                    _selectedKelurahan = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Kelurahan / Desa'),
                              _buildDropdown(
                                key: ValueKey('kel_$_selectedKecamatan'),
                                initialValue: _selectedKelurahan,
                                items: kelurahanList,
                                hint: 'Pilih Kelurahan',
                                onChanged: (val) {
                                  setState(() => _selectedKelurahan = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Alamat Lengkap
                    _buildFieldLabel('Alamat Lengkap / Jalan'),
                    _buildTextInput(
                      controller: _alamatController,
                      hint: 'Nama jalan, RT/RW, nomor rumah',
                      maxLines: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── 3. Section: Kontak ──
                _buildCollapsibleSection(
                  title: 'Kontak',
                  subtitle: 'Informasi kontak aktif untuk konfirmasi & notifikasi',
                  icon: Icons.contact_phone_outlined,
                  isExpanded: _isKontakExpanded,
                  onToggle: () {
                    setState(() {
                      _isKontakExpanded = !_isKontakExpanded;
                    });
                  },
                  content: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('No. Handphone / WA'),
                              _buildTextInput(
                                controller: _nomorHpController,
                                hint: '081234567890',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(14),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Alamat Email'),
                              _buildTextInput(
                                controller: _emailController,
                                hint: 'email@domain.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── 4. Section: Keamanan Akun ──
                _buildCollapsibleSection(
                  title: 'Keamanan Akun',
                  subtitle: 'Kelola keamanan kata sandi login Anda',
                  icon: Icons.shield_outlined,
                  isExpanded: _isKeamananExpanded,
                  onToggle: () {
                    setState(() {
                      _isKeamananExpanded = !_isKeamananExpanded;
                    });
                  },
                  content: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kata Sandi Akun',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '••••••••••••',
                                style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Perlu kata sandi saat ini untuk mengubah sandi',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _openChangePasswordBottomSheet(context),
                          icon: const Icon(Icons.key_rounded, size: 16),
                          label: const Text(
                            'Ubah Sandi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper UI Components yang Natural & Konsisten ──

  /// Komponen Kartu Collapsible dengan header interaktif
  Widget _buildCollapsibleSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris Expand/Collapse
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 19, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Konten Section saat terbuka
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  /// Field Read-Only dengan tampilan disabled dan ikon gembok
  Widget _buildReadOnlyField({
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  /// Input Teks Standar
  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// Dropdown Reusable Konsisten
  Widget _buildDropdown({
    Key? key,
    required String? initialValue,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.contains(initialValue) ? initialValue : null;

    return DropdownButtonFormField<String>(
      key: key,
      initialValue: validValue,
      onChanged: onChanged,
      isExpanded: true,
      dropdownColor: Colors.white,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF0F172A),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF64748B),
        size: 20,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  /// Dialog Dropdown Pencarian Tempat Lahir
  Widget _buildSearchableTempatLahirDropdown() {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (ctx) => _SearchableDropdownDialog(
            title: 'Pilih Tempat Lahir',
            items: TempatLahirData.tempatLahirList,
            selectedValue: _selectedTempatLahir,
          ),
        );
        if (selected != null) {
          setState(() => _selectedTempatLahir = selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedTempatLahir ?? 'Pilih Tempat',
                style: TextStyle(
                  fontSize: 13,
                  color: _selectedTempatLahir != null
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF94A3B8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Pemilih Tanggal Lahir
  Widget _buildDatePicker() {
    final tgl = _selectedTanggalLahir;
    final text = tgl != null
        ? '${tgl.day.toString().padLeft(2, '0')}/${tgl.month.toString().padLeft(2, '0')}/${tgl.year}'
        : 'Pilih Tanggal';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedTanggalLahir ?? DateTime(1990, 5, 14),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF0F172A),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: tgl != null
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF94A3B8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF64748B),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal Bottom Sheet Ganti Sandi dengan Verifikasi Sandi Saat Ini
class _ChangePasswordBottomSheet extends StatefulWidget {
  const _ChangePasswordBottomSheet();

  @override
  State<_ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState
    extends State<_ChangePasswordBottomSheet> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePassword() async {
    final currentPass = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    // Sandi saat ini (default: '12345678')
    final storedPass =
        SessionManager.prefs.getString('pku_user_password') ?? '12345678';

    if (currentPass.isEmpty) {
      setState(() => _errorMessage = 'Masukkan kata sandi saat ini.');
      return;
    }

    if (currentPass != storedPass) {
      setState(() => _errorMessage = 'Kata sandi saat ini tidak sesuai.');
      return;
    }

    if (newPass.isEmpty) {
      setState(() => _errorMessage = 'Masukkan kata sandi baru.');
      return;
    }

    if (newPass.length < 8) {
      setState(() => _errorMessage = 'Kata sandi baru minimal 8 karakter.');
      return;
    }

    if (newPass == currentPass) {
      setState(() => _errorMessage =
          'Kata sandi baru tidak boleh sama dengan kata sandi saat ini.');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Konfirmasi kata sandi tidak cocok.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Simulasi delay proses penyimpanan sandi baru
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // Simpan kata sandi baru ke sesi SharedPreferences
    await SessionManager.prefs.setString('pku_user_password', newPass);

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Kata sandi berhasil diperbarui',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: bottomInset + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pill drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ubah Kata Sandi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Masukkan kata sandi saat ini untuk verifikasi',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),

            // Pesan Error jika ada
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 1. Kata Sandi Saat Ini
            const Text(
              'Kata Sandi Saat Ini *',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 5),
            _buildPassField(
              controller: _currentPasswordController,
              hint: 'Masukkan kata sandi saat ini',
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.forgotPassword);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lupa Kata Sandi?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // 2. Kata Sandi Baru
            const Text(
              'Kata Sandi Baru *',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 5),
            _buildPassField(
              controller: _newPasswordController,
              hint: 'Minimal 8 karakter',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 12),

            // 3. Konfirmasi Kata Sandi Baru
            const Text(
              'Konfirmasi Kata Sandi Baru *',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 5),
            _buildPassField(
              controller: _confirmPasswordController,
              hint: 'Ulangi kata sandi baru',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 18),

            // Tombol Simpan Sandi Baru
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Perbarui Kata Sandi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: const Color(0xFF94A3B8),
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// Dialog Pop-up Pencarian Tempat Lahir yang Ringan & Efisien
class _SearchableDropdownDialog extends StatefulWidget {
  const _SearchableDropdownDialog({
    required this.title,
    required this.items,
    this.selectedValue,
  });

  final String title;
  final List<String> items;
  final String? selectedValue;

  @override
  State<_SearchableDropdownDialog> createState() =>
      _SearchableDropdownDialogState();
}

class _SearchableDropdownDialogState extends State<_SearchableDropdownDialog> {
  late final TextEditingController _searchController;
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 460),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: _filter,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Cari kota / kabupaten...',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final isSelected = item == widget.selectedValue;
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                              size: 18,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
