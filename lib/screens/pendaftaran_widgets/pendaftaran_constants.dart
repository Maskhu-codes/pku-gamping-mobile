import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

// Re-export model dan mock data terpusat agar kompatibel dengan seluruh widget pendaftaran
export 'package:pku_gamping_app/models/pasien_model.dart';
export 'package:pku_gamping_app/models/pendaftaran_model.dart';
export 'package:pku_gamping_app/services/pendaftaran_service.dart';
export 'package:pku_gamping_app/services/mock/pendaftaran_mock_data.dart';

/// ─── Token Warna & Tipografi Pendaftaran (Tersinkron dengan AppColors) ───
const Color kPendaftaranPrimary = AppColors.primary;
const Color kPendaftaranInk = AppColors.textPrimary;
const Color kPendaftaranMuted = AppColors.textMuted;
const Color kPendaftaranPageBg = AppColors.pageBackground;
const Color kPendaftaranCardBorder = Color(0xFFE2E8F0);
const Color kPendaftaranDivider = Color(0xFFEDF2F7);

// Accent colors
const Color kPendaftaranSelectedBadge = Color(0xFF0A3A8A);
const Color kPendaftaranSlotAvailableBg = Color(0xFFEBF3FF);
const Color kPendaftaranSlotAvailableText = AppColors.primary;
const Color kPendaftaranSlotFullBg = Color(0xFFFEE2E2);
const Color kPendaftaranSlotFullText = Color(0xFFDC2626);

// Warning/Info banner BPJS
const Color kPendaftaranBannerBg = Color(0xFFFEF9EE);
const Color kPendaftaranBannerBorder = Color(0xFFFDE68A);
const Color kPendaftaranBannerText = Color(0xFF78350F);

const String kPendaftaranFontFamily = 'Plus Jakarta Sans';
