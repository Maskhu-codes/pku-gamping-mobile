import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/services/app_feedback_service.dart';

/// Halaman Detail & Edit Profil Pasien RS PKU Gamping.
/// Memisahkan secara elegan antara:
/// 1. Data resmi Rekam Medis (Read-Only / Terproteksi)
/// 2. Data pribadi pelengkap & kontak (Editable oleh Pasien)
/// 3. Catatan alergi dan riwayat klinis
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Nilai Editable
  String _selectedPendidikan = 'S1 / Sarjana';
  String _selectedPekerjaan = 'Karyawan Swasta';
  String _selectedStatusNikah = 'Belum Menikah';
  String _selectedAgama = 'Islam';
  final String _selectedGolDarah = 'O+';
  final String _selectedJenisKelamin = 'Laki-laki';

  late final TextEditingController _alamatController;
  late final TextEditingController _wilayahController;
  late final TextEditingController _noHpController;
  late final TextEditingController _emailController;

  bool _isSaving = false;

  final List<String> _listAgama = const [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

  final List<String> _listStatusNikah = const [
    'Belum Menikah',
    'Menikah',
    'Cerai Hidup',
    'Cerai Mati',
  ];

  final List<String> _listPendidikan = const [
    'SD / Sederajat',
    'SMP / Sederajat',
    'SMA / SMK / Sederajat',
    'Diploma (D1 - D4)',
    'S1 / Sarjana',
    'S2 / Magister',
    'S3 / Doktoral',
  ];

  final List<String> _listPekerjaan = const [
    'PNS / ASN',
    'TNI / Polri',
    'Karyawan Swasta',
    'Wiraswasta / Pengusaha',
    'Pelajar / Mahasiswa',
    'Ibu Rumah Tangga',
    'Pensiunan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _alamatController = TextEditingController(
      text: 'Jl. Wates Km. 5, Gamping, Sleman',
    );
    _wilayahController = TextEditingController(
      text: 'DI Yogyakarta',
    );
    _noHpController = TextEditingController(
      text: '+62 812-****-4590',
    );
    _emailController = TextEditingController(
      text: 'dummy.online2@email.com',
    );
  }

  @override
  void dispose() {
    _alamatController.dispose();
    _wilayahController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showSelectorBottomSheet({
    required String title,
    required List<String> options,
    required String currentSelected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = options[index];
                    final isSelected = item == currentSelected;
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 2,
                      ),
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFF334155),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSaving = false);

    AppFeedback.showSuccess(
      context,
      title: 'Profil Berhasil Diperbarui',
      message: 'Perubahan data pribadi Anda telah berhasil disimpan ke sistem.',
      confirmText: 'Kembali',
      onDone: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nama = SessionManager.namaPasien;
    final noRm = SessionManager.noRm;
    final parts = nama.trim().split(RegExp(r'\s+'));
    final inisial = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (parts.isNotEmpty && parts[0].isNotEmpty
            ? parts[0].substring(0, 1).toUpperCase()
            : 'BD');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF1E293B),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali ke Profil',
        ),
        title: const Text(
          'Data & Profil Pasien',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _handleSave,
            icon: _isSaving
                ? const SizedBox.shrink()
                : const Icon(Icons.save_rounded, size: 18),
            label: _isSaving
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Kartu Header Identitas & Ringkasan Pasien
            _buildPatientHeader(inisial, nama, noRm),
            const SizedBox(height: 20),

            // 2. Data Pribadi Resmi Rekam Medis (Read-Only 🔒)
            _buildSectionHeader(
              title: 'Data Identitas Resmi',
              subtitle: 'Data resmi tersinkronisasi dengan Rekam Medis RS PKU.',
              actionIcon: Icons.lock_rounded,
              actionLabel: 'Terkunci',
            ),
            const SizedBox(height: 10),
            _buildOfficialIdentityCard(),
            const SizedBox(height: 24),

            // 3. Biodata Tambahan (Editable via Sheet)
            _buildSectionHeader(
              title: 'Biodata Tambahan',
              subtitle: 'Informasi pelengkap untuk kelengkapan administrasi.',
            ),
            const SizedBox(height: 10),
            _buildEditableBiodataCard(),
            const SizedBox(height: 24),

            // 4. Kontak & Alamat Domisili
            _buildSectionHeader(
              title: 'Kontak & Alamat Domisili',
              subtitle: 'Digunakan untuk konfirmasi jadwal dokter & pengiriman resep.',
            ),
            const SizedBox(height: 10),
            _buildContactAddressCard(),
            const SizedBox(height: 24),

            // 5. Alergi & Catatan Medis
            _buildSectionHeader(
              title: 'Alergi & Catatan Medis',
              subtitle: 'Catatan penting peringatan klinis dokter.',
            ),
            const SizedBox(height: 10),
            _buildMedicalNotesCard(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  /// Header Avatar, Nama, No. RM, dan Ringkasan Metrik
  Widget _buildPatientHeader(String inisial, String nama, String noRm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar dengan badge centang verifikasi
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    inisial,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nama
          Text(
            nama,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),

          // Badge No. RM
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 13,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Text(
                  'No. RM: $noRm',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Status Verifikasi
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 13,
                color: Color(0xFF16A34A),
              ),
              SizedBox(width: 5),
              Text(
                'Terverifikasi BPJS & Rekam Medis',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Kolom Metrik Ringkas
          Row(
            children: [
              _buildMetricItem('Kunjungan', '-'),
              const SizedBox(width: 8),
              _buildMetricItem('Resep Aktif', '-'),
              const SizedBox(width: 8),
              _buildMetricItem('Janji', '-'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Judul Seksi dengan Icon Status
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    IconData? actionIcon,
    String? actionLabel,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && actionIcon != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(actionIcon, size: 12, color: const Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Kartu Identitas Resmi Rekam Medis (Terkunci)
  Widget _buildOfficialIdentityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_ind_outlined,
                size: 16,
                color: Color(0xFF1D4ED8),
              ),
              const SizedBox(width: 8),
              const Text(
                'IDENTITAS PASIEN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
          const Divider(height: 20),

          // Baris 1: NIK & Nama Lengkap
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStaticField(
                  label: 'NIK / KTP',
                  value: '347104***********',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStaticField(
                  label: 'Nama Lengkap',
                  value: 'BY DUMMY ONLINE DUA',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Baris 2: Tempat, Tgl Lahir
          _buildStaticField(
            label: 'Tempat, Tgl. Lahir',
            value: 'Yogyakarta, 14 Mei 1990',
          ),
          const SizedBox(height: 14),

          // Baris 3: Jenis Kelamin & Gol Darah
          Row(
            children: [
              Expanded(
                child: _buildStaticField(
                  label: 'Jenis Kelamin',
                  value: _selectedJenisKelamin,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStaticField(
                  label: 'Gol. Darah',
                  value: _selectedGolDarah,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Banner Info Disclaimer Admisi
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perubahan data identitas rekam medis resmi hanya dapat dilakukan di loket Admisi RS PKU Gamping.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu Biodata Tambahan (Dapat Diedit Pasien)
  Widget _buildEditableBiodataCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSelectorTile(
                  icon: Icons.school_outlined,
                  label: 'Pendidikan Terakhir',
                  value: _selectedPendidikan,
                  onTap: () {
                    _showSelectorBottomSheet(
                      title: 'Pilih Pendidikan Terakhir',
                      options: _listPendidikan,
                      currentSelected: _selectedPendidikan,
                      onSelected: (val) => setState(() => _selectedPendidikan = val),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSelectorTile(
                  icon: Icons.work_outline_rounded,
                  label: 'Pekerjaan',
                  value: _selectedPekerjaan,
                  onTap: () {
                    _showSelectorBottomSheet(
                      title: 'Pilih Pekerjaan',
                      options: _listPekerjaan,
                      currentSelected: _selectedPekerjaan,
                      onSelected: (val) => setState(() => _selectedPekerjaan = val),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSelectorTile(
                  icon: Icons.favorite_border_rounded,
                  label: 'Status Pernikahan',
                  value: _selectedStatusNikah,
                  onTap: () {
                    _showSelectorBottomSheet(
                      title: 'Pilih Status Pernikahan',
                      options: _listStatusNikah,
                      currentSelected: _selectedStatusNikah,
                      onSelected: (val) => setState(() => _selectedStatusNikah = val),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSelectorTile(
                  icon: Icons.account_balance_outlined,
                  label: 'Agama',
                  value: _selectedAgama,
                  onTap: () {
                    _showSelectorBottomSheet(
                      title: 'Pilih Agama',
                      options: _listAgama,
                      currentSelected: _selectedAgama,
                      onSelected: (val) => setState(() => _selectedAgama = val),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Kartu Kontak & Alamat
  Widget _buildContactAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subheader Kontak
          const Row(
            children: [
              Icon(Icons.call_outlined, size: 15, color: Color(0xFF1D4ED8)),
              SizedBox(width: 8),
              Text(
                'KONTAK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Divider(height: 18),

          // No. HP & Email dengan tombol Ubah
          _buildContactRow(
            label: 'No. Handphone / WhatsApp',
            controller: _noHpController,
            icon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 12),
          _buildContactRow(
            label: 'Email',
            controller: _emailController,
            icon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 18),

          // Subheader Alamat
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF1D4ED8)),
              SizedBox(width: 8),
              Text(
                'ALAMAT DOMISILI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Divider(height: 18),

          // Input Alamat
          const Text(
            'Alamat Tempat Tinggal Saat Ini',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _alamatController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Masukkan alamat lengkap domisili',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(12),
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
          const SizedBox(height: 12),

          // Input Wilayah
          const Text(
            'Wilayah / Provinsi',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _wilayahController,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Contoh: DI Yogyakarta',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        ],
      ),
    );
  }

  /// Kartu Alergi & Catatan Medis
  Widget _buildMedicalNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum Ada Riwayat Alergi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Informasi alergi obat maupun makanan belum tercatat. Sampaikan kepada dokter/perawat pada saat konsultasi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: const Color(0xFF64748B)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF64748B)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
