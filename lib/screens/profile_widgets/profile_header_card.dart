import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/profile_photo_service.dart';

/// Kartu header profil pasien — avatar foto/inisial, nama, No. RM, status verifikasi,
/// dan ringkasan data identitas (NIK, No. RM, Email, No. HP, Tanggal Lahir).
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    this.nama,
    this.noRm,
    this.nik,
    this.email,
    this.noHp,
    this.tglLahir,
  });

  final String? nama;
  final String? noRm;
  final String? nik;
  final String? email;
  final String? noHp;
  final String? tglLahir;

  static String _formatTanggal(String raw) {
    if (raw.isEmpty || raw == '-') return '-';
    try {
      final parsed = DateTime.parse(raw);
      const bulan = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return '${parsed.day} ${bulan[parsed.month]} ${parsed.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedNama = (nama != null && nama!.trim().isNotEmpty)
        ? nama!.trim()
        : SessionManager.namaPasien;
    final resolvedNoRm = (noRm != null && noRm!.trim().isNotEmpty)
        ? noRm!.trim()
        : SessionManager.noRm;
    final resolvedNik = (nik != null && nik!.trim().isNotEmpty)
        ? nik!.trim()
        : (SessionManager.nik ?? '-');
    final resolvedEmail = (email != null && email!.trim().isNotEmpty)
        ? email!.trim()
        : (SessionManager.email ?? '-');
    final resolvedNoHp = (noHp != null && noHp!.trim().isNotEmpty)
        ? noHp!.trim()
        : (SessionManager.noHp ?? '-');
    final rawTglLahir = (tglLahir != null && tglLahir!.trim().isNotEmpty)
        ? tglLahir!.trim()
        : (SessionManager.fdTglLahir ?? '-');
    final resolvedTglLahir = _formatTanggal(rawTglLahir);

    final parts = resolvedNama.trim().split(RegExp(r'\s+'));
    final inisial = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (parts.isNotEmpty && parts[0].isNotEmpty
            ? parts[0].substring(0, 1).toUpperCase()
            : 'DM');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Gradient Header Biru (Avatar, Nama, No. RM)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                // Avatar foto / inisial pasien (dapat ditekan untuk ganti foto)
                GestureDetector(
                  onTap: () => ProfilePhotoService.showPhotoActionSheet(context),
                  child: ValueListenableBuilder<String?>(
                    valueListenable: SessionManager.profilePhotoNotifier,
                    builder: (context, photoPath, _) {
                      final hasPhoto = photoPath != null &&
                          photoPath.isNotEmpty &&
                          File(photoPath).existsSync();

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBE4F8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: hasPhoto
                                  ? Image.file(
                                      File(photoPath),
                                      width: 58,
                                      height: 58,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(
                                        inisial,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E3A8A),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          // Badge ikon kamera kecil (menandakan bisa diubah)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resolvedNama,
                        key: const Key('profile_nama'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Badge No. RM
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'No. RM: $resolvedNoRm',
                          key: const Key('profile_mr_badge'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Status Verifikasi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Terverifikasi BPJS & Rekam Medis',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF15803D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Detail Biodata Pasien (NIK, MR, Email, HP, Tanggal Lahir)
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  icon: Icons.badge_outlined,
                  label: 'NIK',
                  value: resolvedNik,
                  valueKey: const Key('profile_nik'),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  icon: Icons.credit_card_rounded,
                  label: 'No. Rekam Medis (MR)',
                  value: resolvedNoRm,
                  valueKey: const Key('profile_mr'),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: resolvedEmail,
                  valueKey: const Key('profile_email'),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  icon: Icons.phone_android_rounded,
                  label: 'No. Handphone (HP)',
                  value: resolvedNoHp,
                  valueKey: const Key('profile_hp'),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  icon: Icons.cake_outlined,
                  label: 'Tanggal Lahir',
                  value: resolvedTglLahir,
                  valueKey: const Key('profile_tgl_lahir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Key valueKey,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF475569)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
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
              const SizedBox(height: 2),
              Text(
                value,
                key: valueKey,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
