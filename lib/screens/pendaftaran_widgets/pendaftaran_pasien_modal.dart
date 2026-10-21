import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Modal Bottom Sheet untuk memilih pasien terdaftar atau memasukkan identitas baru
/// sesuai workflow web PKU Gamping (No RM / NIK + Tanggal Lahir).
class PendaftaranPasienModal extends StatefulWidget {
  const PendaftaranPasienModal({
    super.key,
    required this.selectedPasien,
    required this.onPasienChanged,
  });

  final PasienModel selectedPasien;
  final ValueChanged<PasienModel> onPasienChanged;

  static Future<void> show({
    required BuildContext context,
    required PasienModel selectedPasien,
    required ValueChanged<PasienModel> onPasienChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PendaftaranPasienModal(
        selectedPasien: selectedPasien,
        onPasienChanged: onPasienChanged,
      ),
    );
  }

  @override
  State<PendaftaranPasienModal> createState() => _PendaftaranPasienModalState();
}

class _PendaftaranPasienModalState extends State<PendaftaranPasienModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controller form manual
  int _selectedJenisIdentitas = 0; // 0: No RM, 1: NIK
  final TextEditingController _nomorIdentitasController =
      TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomorIdentitasController.dispose();
    _tglLahirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Judul Modal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ganti Pasien Kunjungan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kPendaftaranInk,
                    fontFamily: kPendaftaranFontFamily,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: kPendaftaranMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab Bar (Pasien Tersimpan vs Input Manual)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              labelColor: kPendaftaranPrimary,
              unselectedLabelColor: kPendaftaranMuted,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontFamily: kPendaftaranFontFamily,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                fontFamily: kPendaftaranFontFamily,
              ),
              tabs: const [
                Tab(text: 'Keluarga Tersimpan'),
                Tab(text: 'Input Identitas Baru'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab Views
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListPasienTersimpan(),
                _buildFormInputManual(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tab 1: Daftar pasien keluarga yang tersimpan di akun
  Widget _buildListPasienTersimpan() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shrinkWrap: true,
      itemCount: PendaftaranDummyData.listPasienTersimpan.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final pasien = PendaftaranDummyData.listPasienTersimpan[index];
        final isSelected = pasien.id == widget.selectedPasien.id;

        return InkWell(
          onTap: () {
            widget.onPasienChanged(pasien);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isSelected ? kPendaftaranPrimary : kPendaftaranCardBorder,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      pasien.inisial,
                      style: TextStyle(
                        color: isSelected
                            ? kPendaftaranPrimary
                            : kPendaftaranInk,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        fontFamily: kPendaftaranFontFamily,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              pasien.nama,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: kPendaftaranInk,
                                fontFamily: kPendaftaranFontFamily,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pasien.hubungan,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                                fontFamily: kPendaftaranFontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'No. RM: ${pasien.noRm}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kPendaftaranMuted,
                          fontFamily: kPendaftaranFontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                // Radio Check
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color:
                      isSelected ? kPendaftaranPrimary : Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tab 2: Form manual identitas pasien sesuai format web PKU Gamping
  Widget _buildFormInputManual() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label Jenis Identitas
          const Text(
            'Pilih Jenis Identitas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kPendaftaranInk,
              fontFamily: kPendaftaranFontFamily,
            ),
          ),
          const SizedBox(height: 8),

          // Segmented Button: No. RM vs NIK
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kPendaftaranCardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedJenisIdentitas = 0),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedJenisIdentitas == 0
                            ? kPendaftaranPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(
                          'No. Rekam Medis',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _selectedJenisIdentitas == 0
                                ? Colors.white
                                : kPendaftaranInk,
                            fontFamily: kPendaftaranFontFamily,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedJenisIdentitas = 1),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedJenisIdentitas == 1
                            ? kPendaftaranPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(
                          'No. KTP / NIK',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _selectedJenisIdentitas == 1
                                ? Colors.white
                                : kPendaftaranInk,
                            fontFamily: kPendaftaranFontFamily,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Nomor Identitas
          const Text(
            'Nomor Identitas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kPendaftaranInk,
              fontFamily: kPendaftaranFontFamily,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nomorIdentitasController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: kPendaftaranFontFamily,
            ),
            decoration: InputDecoration(
              hintText: _selectedJenisIdentitas == 0
                  ? 'Masukkan nomor rekam medis...'
                  : 'Masukkan 16 digit NIK...',
              hintStyle: const TextStyle(
                color: kPendaftaranMuted,
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPendaftaranCardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPendaftaranCardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: kPendaftaranPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tanggal Lahir
          const Text(
            'Tanggal Lahir',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kPendaftaranInk,
              fontFamily: kPendaftaranFontFamily,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _tglLahirController,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: kPendaftaranFontFamily,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.calendar_month_outlined,
                color: kPendaftaranPrimary,
                size: 20,
              ),
              hintText: 'dd-mm-yyyy',
              hintStyle: const TextStyle(
                color: kPendaftaranMuted,
                fontSize: 13,
              ),
              helperText:
                  'Format: Tanggal-Bulan-Tahun (Contoh: 17-08-1945)',
              helperStyle: const TextStyle(
                color: kPendaftaranMuted,
                fontSize: 11,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPendaftaranCardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPendaftaranCardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: kPendaftaranPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Gunakan Pasien Ini
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final identitas = _nomorIdentitasController.text.trim();
                if (identitas.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan masukkan nomor identitas.'),
                    ),
                  );
                  return;
                }
                // Buat pasien baru dari input manual
                final pasienBaru = PasienModel(
                  id: 'p-custom-${DateTime.now().millisecondsSinceEpoch}',
                  nama: 'Pasien Terdaftar ($identitas)',
                  noRm: _selectedJenisIdentitas == 0 ? identitas : '3471-CUSTOM',
                  nik: _selectedJenisIdentitas == 1 ? identitas : '3471-CUSTOM',
                  tanggalLahir: _tglLahirController.text.trim().isNotEmpty
                      ? _tglLahirController.text.trim()
                      : '01-01-1990',
                  isTerhubung: true,
                  hubungan: 'Manual',
                );
                widget.onPasienChanged(pasienBaru);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPendaftaranPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Gunakan Pasien Ini',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: kPendaftaranFontFamily,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
