import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Modal Bottom Sheet yang dapat di-scroll untuk memilih Poli.
class PoliSelectionSheet extends StatefulWidget {
  const PoliSelectionSheet({
    super.key,
    required this.selectedPoli,
    required this.onPoliSelected,
  });

  final PoliModel? selectedPoli;
  final ValueChanged<PoliModel> onPoliSelected;

  static Future<void> show({
    required BuildContext context,
    required PoliModel? selectedPoli,
    required ValueChanged<PoliModel> onPoliSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PoliSelectionSheet(
        selectedPoli: selectedPoli,
        onPoliSelected: onPoliSelected,
      ),
    );
  }

  @override
  State<PoliSelectionSheet> createState() => _PoliSelectionSheetState();
}

class _PoliSelectionSheetState extends State<PoliSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allPoli = PendaftaranDummyData.listPoli;
    final filteredList = allPoli.where((poli) {
      return poli.nama.toLowerCase().contains(_query.toLowerCase()) ||
          poli.deskripsi.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Poli Tujuan',
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

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _query = val),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: kPendaftaranFontFamily,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari nama poli...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: kPendaftaranMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: kPendaftaranMuted,
                    size: 20,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // List Poli
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Text(
                      'Poli tidak ditemukan',
                      style: TextStyle(
                        color: kPendaftaranMuted,
                        fontFamily: kPendaftaranFontFamily,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final poli = filteredList[index];
                      final isSelected = poli.id == widget.selectedPoli?.id;

                      return InkWell(
                        onTap: () {
                          widget.onPoliSelected(poli);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF6FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? kPendaftaranPrimary
                                  : kPendaftaranCardBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFDBEAFE)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  poli.icon,
                                  color: isSelected
                                      ? kPendaftaranPrimary
                                      : const Color(0xFF64748B),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      poli.nama,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? kPendaftaranPrimary
                                            : kPendaftaranInk,
                                        fontFamily: kPendaftaranFontFamily,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      poli.deskripsi,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: kPendaftaranMuted,
                                        fontFamily: kPendaftaranFontFamily,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: kPendaftaranPrimary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Modal Bottom Sheet yang dapat di-scroll untuk memilih Dokter.
/// Hanya menampilkan dokter yang bertugas di Poli yang dipilih.
class DokterSelectionSheet extends StatefulWidget {
  const DokterSelectionSheet({
    super.key,
    required this.selectedPoli,
    required this.selectedDokter,
    required this.onDokterSelected,
  });

  final PoliModel selectedPoli;
  final DokterPendaftaranModel? selectedDokter;
  final ValueChanged<DokterPendaftaranModel> onDokterSelected;

  static Future<void> show({
    required BuildContext context,
    required PoliModel selectedPoli,
    required DokterPendaftaranModel? selectedDokter,
    required ValueChanged<DokterPendaftaranModel> onDokterSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DokterSelectionSheet(
        selectedPoli: selectedPoli,
        selectedDokter: selectedDokter,
        onDokterSelected: onDokterSelected,
      ),
    );
  }

  @override
  State<DokterSelectionSheet> createState() => _DokterSelectionSheetState();
}

class _DokterSelectionSheetState extends State<DokterSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter dokter hanya yang ada di poli terpilih
    final doktersInPoli = PendaftaranDummyData.listDokter.where((d) {
      return d.poliId == widget.selectedPoli.id;
    }).toList();

    final filteredList = doktersInPoli.where((d) {
      return d.nama.toLowerCase().contains(_query.toLowerCase()) ||
          d.spesialisasi.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Dokter Tujuan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kPendaftaranInk,
                        fontFamily: kPendaftaranFontFamily,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.selectedPoli.nama,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kPendaftaranPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: kPendaftaranFontFamily,
                      ),
                    ),
                  ],
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

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _query = val),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: kPendaftaranFontFamily,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari nama dokter...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: kPendaftaranMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: kPendaftaranMuted,
                    size: 20,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // List Dokter
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Belum ada dokter yang terdaftar pada poli ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kPendaftaranMuted,
                          fontFamily: kPendaftaranFontFamily,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final dokter = filteredList[index];
                      final isSelected =
                          dokter.id == widget.selectedDokter?.id;

                      return InkWell(
                        onTap: () {
                          widget.onDokterSelected(dokter);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF6FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? kPendaftaranPrimary
                                  : kPendaftaranCardBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: kPendaftaranPrimary,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dokter.nama,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? kPendaftaranPrimary
                                            : kPendaftaranInk,
                                        fontFamily: kPendaftaranFontFamily,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dokter.spesialisasi,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: kPendaftaranMuted,
                                        fontFamily: kPendaftaranFontFamily,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${dokter.jadwalSlots.length} jadwal tersedia',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF0F766E),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: kPendaftaranFontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: kPendaftaranPrimary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
