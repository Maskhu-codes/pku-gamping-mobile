import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';
import 'jadwal_constants.dart';

/// Komponen selektor Poliklinik modern RS PKU Gamping.
///
/// Menggantikan horizontal scroll chips yang melelahkan dengan Selector Card
/// ringkas dan Searchable Modal Bottom Sheet vertikal (one-thumb friendly).
class JadwalPoliFilter extends StatelessWidget {
  const JadwalPoliFilter({
    super.key,
    required this.poliList,
    required this.selectedPoli,
    required this.onPoliSelected,
    this.includeAllOption = true,
  });

  final List<String> poliList;
  final String selectedPoli;
  final ValueChanged<String> onPoliSelected;
  final bool includeAllOption;

  void _showPoliPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    final items = includeAllOption
        ? (poliList.contains('Semua') ? poliList : ['Semua', ...poliList])
        : poliList;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PoliPickerBottomSheet(
        items: items,
        selectedPoli: selectedPoli,
        onSelected: (poli) {
          onPoliSelected(poli);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPoli = selectedPoli.isNotEmpty ? selectedPoli : 'Pilih Poliklinik';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: PressableScale(
        onTap: () => _showPoliPicker(context),
        pressedScale: 0.98,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Icon Badge Medis Institusional
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 20,
                  color: kPrimaryBlue,
                ),
              ),
              const SizedBox(width: 12),

              // 2. Info Teks Bertingkat (Dual-tier Label)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'POLIKLINIK',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${poliList.length} Spesialis',
                            style: const TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayPoli,
                      style: const TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 3. Tombol Aksi Pill Ganti Poli
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Ganti',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryBlue,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: kPrimaryBlue,
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

/// Bottom Sheet Pencarian dan Pemilihan Poliklinik
class _PoliPickerBottomSheet extends StatefulWidget {
  const _PoliPickerBottomSheet({
    required this.items,
    required this.selectedPoli,
    required this.onSelected,
  });

  final List<String> items;
  final String selectedPoli;
  final ValueChanged<String> onSelected;

  @override
  State<_PoliPickerBottomSheet> createState() => _PoliPickerBottomSheetState();
}

class _PoliPickerBottomSheetState extends State<_PoliPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final maxSheetHeight = mediaQuery.size.height * 0.78;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag Handle ──
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header Modal ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Poliklinik',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tersedia ${widget.items.length} poliklinik rawat jalan',
                          style: const TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF64748B),
                    tooltip: 'Tutup',
                  ),
                ],
              ),
            ),

            // ── Search Field Instan ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari nama poliklinik...',
                    hintStyle: const TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 13.5,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.cancel_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // ── Daftar Poliklinik Vertikal (Scrollable) ──
            Expanded(
              child: _filteredItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final poli = _filteredItems[index];
                        final isSelected = poli == widget.selectedPoli;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Material(
                            color: isSelected
                                ? const Color(0xFFEBF3FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pop(context);
                                widget.onSelected(poli);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: kPrimaryBlue.withValues(
                                            alpha: 0.35,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      size: 20,
                                      color: isSelected
                                          ? kPrimaryBlue
                                          : const Color(0xFFCBD5E1),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        poli,
                                        style: TextStyle(
                                          fontFamily: kFontFamily,
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? kPrimaryBlue
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kPrimaryBlue,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Aktif',
                                          style: TextStyle(
                                            fontFamily: kFontFamily,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 26,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ditemukan "${_searchController.text}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Periksa ejaan nama poliklinik atau reset pencarian.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _searchController.clear(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Reset Pencarian',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
