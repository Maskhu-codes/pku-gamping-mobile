import 'package:flutter/material.dart';
import 'jadwal_constants.dart';

/// Search bar untuk mencari nama dokter atau poli.
///
/// Menerima callback [onChanged] agar parent bisa memfilter data
/// sesuai teks yang diketik pengguna.
class JadwalSearchBar extends StatelessWidget {
  const JadwalSearchBar({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kCardBorder),
        ),
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            color: kInk,
            fontFamily: kFontFamily,
          ),
          decoration: const InputDecoration(
            hintText: 'Cari dokter atau poli...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: kMuted,
              fontFamily: kFontFamily,
            ),
            prefixIcon: Icon(Icons.search, color: kMuted, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }
}
