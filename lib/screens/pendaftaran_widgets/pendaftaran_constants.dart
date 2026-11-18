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
const Color kPendaftaranCardBorder = AppColors.cardBorder;
const Color kPendaftaranDivider = Color(0xFFEDF2F7);

// Accent colors
const Color kPendaftaranSelectedBadge = AppColors.primaryDark;
const Color kPendaftaranSlotAvailableBg = AppColors.primarySoft;
const Color kPendaftaranSlotAvailableText = AppColors.primary;
const Color kPendaftaranSlotFullBg = Color(0xFFFEE2E2);
const Color kPendaftaranSlotFullText = Color(0xFFDC2626);

// Warning/Info banner (warm gold accent)
const Color kPendaftaranBannerBg = AppColors.goldSoft;
const Color kPendaftaranBannerBorder = AppColors.goldBorder;
const Color kPendaftaranBannerText = AppColors.goldText;

const String kPendaftaranFontFamily = 'Plus Jakarta Sans';
