import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/data/wilayah_data.dart';

/// Langkah 2: Pengisian Biodata Pasien, Alamat, dan Kontak.
///
/// Revisi:
/// - Tempat lahir sebagai dropdown (searchable)
/// - Cascading dropdown: Provinsi → Kabupaten/Kota → Kecamatan → Kelurahan/Desa
/// - Alamat email dihapus dari kontak pasien
class RegisterStep2Pasien extends StatelessWidget {
  const RegisterStep2Pasien({
    super.key,
    required this.namaController,
    required this.selectedTempatLahir,
    required this.selectedTanggalLahir,
    required this.selectedJenisKelamin,
    required this.selectedGolDarah,
    required this.selectedAgama,
    required this.selectedWargaNegara,
    required this.selectedPekerjaan,
    required this.selectedPendidikan,
    required this.selectedStatusKawin,
    required this.namaIbuController,
    required this.selectedProvinsi,
    required this.selectedKabupaten,
    required this.selectedKecamatan,
    required this.selectedKelurahan,
    required this.alamatController,
    required this.nomorHpController,
    required this.onTempatLahirChanged,
    required this.onTanggalLahirChanged,
    required this.onJenisKelaminChanged,
    required this.onGolDarahChanged,
    required this.onAgamaChanged,
    required this.onWargaNegaraChanged,
    required this.onPekerjaanChanged,
    required this.onPendidikanChanged,
    required this.onStatusKawinChanged,
    required this.onProvinsiChanged,
    required this.onKabupatenChanged,
    required this.onKecamatanChanged,
    required this.onKelurahanChanged,
    required this.onPrev,
    required this.onLanjut,
  });

  final TextEditingController namaController;
  final String? selectedTempatLahir;
  final DateTime? selectedTanggalLahir;
  final String? selectedJenisKelamin;
  final String? selectedGolDarah;
  final String? selectedAgama;
  final String? selectedWargaNegara;
  final String? selectedPekerjaan;
  final String? selectedPendidikan;
  final String? selectedStatusKawin;
  final TextEditingController namaIbuController;

  final String? selectedProvinsi;
  final String? selectedKabupaten;
  final String? selectedKecamatan;
  final String? selectedKelurahan;
  final TextEditingController alamatController;

  final TextEditingController nomorHpController;

  final ValueChanged<String?> onTempatLahirChanged;
  final ValueChanged<DateTime> onTanggalLahirChanged;
  final ValueChanged<String?> onJenisKelaminChanged;
  final ValueChanged<String?> onGolDarahChanged;
  final ValueChanged<String?> onAgamaChanged;
  final ValueChanged<String?> onWargaNegaraChanged;
  final ValueChanged<String?> onPekerjaanChanged;
  final ValueChanged<String?> onPendidikanChanged;
  final ValueChanged<String?> onStatusKawinChanged;
  final ValueChanged<String?> onProvinsiChanged;
  final ValueChanged<String?> onKabupatenChanged;
  final ValueChanged<String?> onKecamatanChanged;
  final ValueChanged<String?> onKelurahanChanged;

  final VoidCallback onPrev;
  final VoidCallback onLanjut;

  @override
  Widget build(BuildContext context) {
    // Cascading data
    final kabupatenList =
        WilayahData.getKabupatenByProvinsi(selectedProvinsi);
    final kecamatanList =
        WilayahData.getKecamatanByKabupaten(selectedKabupaten);
    final kelurahanList =
        WilayahData.getKelurahanByKecamatan(selectedKecamatan);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lengkapi data diri Anda untuk membuat akun dan terhubung ke sistem RS PKU Muhammadiyah Gamping.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // ── 1. Data Pasien Card ──
          _buildBadgeHeader(
            icon: Icons.person_outline_rounded,
            title: 'Data Pasien',
            badge: 'Wajib',
            subtitle: 'Identitas sesuai KTP, KK, atau Paspor',
          ),
          const SizedBox(height: 10),
          _buildCard(
            children: [
              _buildFieldLabel('Nama Lengkap *'),
              _buildInputField(
                controller: namaController,
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
                        _buildFieldLabel('Tempat Lahir *'),
                        _buildSearchableDropdown(
                          context: context,
                          value: selectedTempatLahir,
                          items: TempatLahirData.tempatLahirList,
                          hint: 'Pilih Tempat Lahir',
                          icon: Icons.location_city_outlined,
                          onChanged: onTempatLahirChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Tanggal Lahir *'),
                        _buildDatePicker(context),
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
                        _buildFieldLabel('Jenis Kelamin *'),
                        _buildDropdown(
                          initialValue: selectedJenisKelamin,
                          items: const ['Laki-laki', 'Perempuan'],
                          hint: 'Pilih',
                          icon: Icons.wc_rounded,
                          onChanged: onJenisKelaminChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Gol. Darah *'),
                        _buildDropdown(
                          initialValue: selectedGolDarah,
                          items: const ['A', 'B', 'AB', 'O', 'Tidak Tahu'],
                          hint: 'Pilih',
                          icon: Icons.bloodtype_outlined,
                          onChanged: onGolDarahChanged,
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
                        _buildFieldLabel('Agama *'),
                        _buildDropdown(
                          initialValue: selectedAgama,
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
                          onChanged: onAgamaChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Warga Negara *'),
                        _buildDropdown(
                          initialValue: selectedWargaNegara,
                          items: const ['WNI', 'WNA'],
                          hint: 'Pilih',
                          icon: Icons.flag_outlined,
                          onChanged: onWargaNegaraChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildFieldLabel('Pekerjaan *'),
              _buildDropdown(
                initialValue: selectedPekerjaan,
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
                onChanged: onPekerjaanChanged,
              ),
              const SizedBox(height: 12),

              _buildFieldLabel('Pendidikan Terakhir *'),
              _buildDropdown(
                initialValue: selectedPendidikan,
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
                onChanged: onPendidikanChanged,
              ),
              const SizedBox(height: 12),

              _buildFieldLabel('Status Kawin *'),
              _buildDropdown(
                initialValue: selectedStatusKawin,
                items: const [
                  'Belum Kawin',
                  'Kawin',
                  'Cerai Hidup',
                  'Cerai Mati',
                ],
                hint: 'Pilih Status Perkawinan',
                icon: Icons.family_restroom_outlined,
                onChanged: onStatusKawinChanged,
              ),
              const SizedBox(height: 12),

              _buildFieldLabel('Nama Ibu Kandung *'),
              _buildInputField(
                controller: namaIbuController,
                hint: 'Nama lengkap ibu kandung',
                icon: Icons.face_retouching_natural_outlined,
              ),
              const SizedBox(height: 4),
              const Text(
                'Wajib diisi sesuai Kartu Keluarga (KK)',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── 2. Alamat Domisili Card ──
          _buildBadgeHeader(
            icon: Icons.home_outlined,
            title: 'Alamat Tempat Tinggal',
            badge: 'Domisili',
            subtitle:
                'Alamat domisili saat ini (tidak harus sama dengan KTP/KK)',
          ),
          const SizedBox(height: 10),
          _buildCard(
            children: [
              _buildFieldLabel('Provinsi *'),
              _buildDropdown(
                initialValue: selectedProvinsi,
                items: WilayahData.provinsiList,
                hint: 'Pilih Provinsi',
                icon: Icons.map_outlined,
                onChanged: onProvinsiChanged,
              ),
              const SizedBox(height: 12),

              _buildFieldLabel('Kabupaten / Kota *'),
              _buildDropdown(
                initialValue: selectedKabupaten,
                items: kabupatenList,
                hint: 'Pilih Kabupaten / Kota',
                icon: Icons.location_city_outlined,
                onChanged: onKabupatenChanged,
              ),
              const SizedBox(height: 12),

              _buildFieldLabel('Kecamatan *'),
              _buildDropdown(
                initialValue: selectedKecamatan,
                items: kecamatanList,
                hint: 'Pilih Kecamatan',
                icon: Icons.navigation_outlined,
                onChanged: onKecamatanChanged,
              ),
              const SizedBox(height: 12),

              _buildFieldLabel('Kelurahan / Desa *'),
              _buildDropdown(
                initialValue: selectedKelurahan,
                items: kelurahanList,
                hint: 'Pilih Kelurahan / Desa',
                icon: Icons.home_work_outlined,
                onChanged: onKelurahanChanged,
              ),
              const SizedBox(height: 12),

              _buildFieldLabel('Alamat Lengkap / Jalan *'),
              _buildInputField(
                controller: alamatController,
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

          // ── 3. Kontak Pasien Card (tanpa email) ──
          _buildBadgeHeader(
            icon: Icons.contact_phone_outlined,
            title: 'Kontak Pasien',
            badge: 'Aktif',
            subtitle: 'Informasi kontak untuk verifikasi & notifikasi',
          ),
          const SizedBox(height: 10),
          _buildCard(
            children: [
              _buildFieldLabel('No. Handphone / WhatsApp *'),
              TextFormField(
                controller: nomorHpController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '812-3456-7890',
                  hintStyle: const TextStyle(
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
                      children: const [
                        Icon(
                          Icons.phone_android_outlined,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '+62',
                          style: TextStyle(
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
              const SizedBox(height: 6),
              const Text(
                'Status verifikasi melalui nomor telepon / WhatsApp Anda.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Tombol Kembali & Lanjut Langkah 3 ──
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onPrev,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'Kembali',
                      style: TextStyle(
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
                    onPressed: onLanjut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Lanjut Langkah 3 →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ──

  Widget _buildBadgeHeader({
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
                      style: const TextStyle(
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
                      style: const TextStyle(
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
                style: const TextStyle(
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

  Widget _buildCard({required List<Widget> children}) {
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInputField({
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
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
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

  Widget _buildDropdown({
    required String? initialValue,
    required List<String> items,
    required String hint,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.contains(initialValue) ? initialValue : null;

    return DropdownButtonFormField<String>(
      initialValue: validValue,
      onChanged: onChanged,
      isExpanded: true,
      style: const TextStyle(
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
        hintStyle: const TextStyle(
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
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// Dropdown Tempat Lahir dengan fitur pencarian
  Widget _buildSearchableDropdown({
    required BuildContext context,
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (ctx) => _SearchableDropdownDialog(
            title: 'Pilih Tempat Lahir',
            items: items,
            selectedValue: value,
          ),
        );
        if (selected != null) {
          onChanged(selected);
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
            Icon(icon, color: AppColors.textHint, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      value == null ? AppColors.textHint : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedTanggalLahir ?? DateTime(1995, 1, 1),
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
          onTanggalLahirChanged(picked);
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
                selectedTanggalLahir == null
                    ? 'Pilih Tanggal'
                    : '${selectedTanggalLahir!.day.toString().padLeft(2, '0')}/${selectedTanggalLahir!.month.toString().padLeft(2, '0')}/${selectedTanggalLahir!.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: selectedTanggalLahir == null
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

/// Dialog pencarian untuk dropdown Tempat Lahir
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
  final _searchController = TextEditingController();
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
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
            .where((item) =>
                item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search field
                  TextField(
                    controller: _searchController,
                    onChanged: _filter,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari kota...',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border),
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
                ],
              ),
            ),
            const Divider(height: 1),
            // List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = item == widget.selectedValue;
                  return ListTile(
                    dense: true,
                    selected: isSelected,
                    selectedTileColor:
                        AppColors.primary.withValues(alpha: 0.08),
                    title: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppColors.primary,
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
    );
  }
}
