import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/models/app_notification_item.dart';
import 'package:pku_gamping_app/services/app_notification_service.dart';

/// Bottom Sheet Pusat Notifikasi Pasien RS PKU Muhammadiyah Gamping
class NotificationCenterSheet extends StatefulWidget {
  const NotificationCenterSheet({super.key});

  @override
  State<NotificationCenterSheet> createState() =>
      _NotificationCenterSheetState();
}

class _NotificationCenterSheetState extends State<NotificationCenterSheet> {
  NotificationCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            // 1. Drag Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pusat Notifikasi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Pembaruan antrean & hasil layanan medis Anda',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menu Opsi / Toggle Pengaturan
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    color: const Color(0xFF64748B),
                    tooltip: 'Pengaturan Notifikasi',
                    onPressed: () => _showSettingsDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: const Color(0xFF64748B),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // 3. Filter Chips & Aksi Tandai Dibaca
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Semua', null),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Antrean',
                            NotificationCategory.antrean,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Hasil Lab',
                            NotificationCategory.lab,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Farmasi',
                            NotificationCategory.farmasi,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable:
                        AppNotificationService.unreadCountNotifier,
                    builder: (context, unreadCount, _) {
                      if (unreadCount == 0) return const SizedBox.shrink();
                      return TextButton.icon(
                        onPressed: () =>
                            AppNotificationService.markAllAsRead(),
                        icon: const Icon(Icons.done_all_rounded, size: 16),
                        label: const Text(
                          'Tandai dibaca',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 4. Daftar Notifikasi
            Expanded(
              child: ValueListenableBuilder<List<AppNotificationItem>>(
                valueListenable:
                    AppNotificationService.notificationsNotifier,
                builder: (context, allItems, _) {
                  final filteredItems = _selectedCategory == null
                      ? allItems
                      : allItems
                          .where((n) => n.category == _selectedCategory)
                          .toList();

                  if (filteredItems.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _NotificationCard(
                        item: item,
                        onTap: () {
                          AppNotificationService.markAsRead(item.id);
                          if (item.route != null) {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              item.route!,
                              arguments: item.routeArguments,
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationCategory? category) {
    final isSelected = _selectedCategory == category;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 32,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum Ada Notifikasi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pembaruan antrean, resep, dan hasil lab Anda akan ditampilkan di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.settings_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Pengaturan Notifikasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola izin notifikasi aplikasi di perangkat Anda.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: AppNotificationService.isEnabledNotifier,
              builder: (ctx, isEnabled, _) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Aktifkan Notifikasi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isEnabled ? 'Notifikasi aktif' : 'Notifikasi dinonaktifkan',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: isEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) async {
                    await AppNotificationService.toggleNotifications(context, val);
                    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final AppNotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _getCategoryStyle(item.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead
                ? const Color(0xFFE2E8F0)
                : AppColors.primary.withValues(alpha: 0.3),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            if (!item.isRead)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon Kategori
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: style.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(style.icon, color: style.iconColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Konten Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.route != null)
                        const Row(
                          children: [
                            Text(
                              'Lihat Detail',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _CategoryStyle _getCategoryStyle(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.antrean:
        return _CategoryStyle(
          icon: Icons.confirmation_number_rounded,
          iconColor: const Color(0xFF2563EB),
          bgColor: const Color(0xFFEFF6FF),
        );
      case NotificationCategory.lab:
        return _CategoryStyle(
          icon: Icons.biotech_rounded,
          iconColor: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF5F3FF),
        );
      case NotificationCategory.farmasi:
        return _CategoryStyle(
          icon: Icons.medication_rounded,
          iconColor: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
        );
      case NotificationCategory.jadwal:
        return _CategoryStyle(
          icon: Icons.calendar_month_rounded,
          iconColor: const Color(0xFF16A34A),
          bgColor: const Color(0xFFF0FDF4),
        );
      case NotificationCategory.info:
        return _CategoryStyle(
          icon: Icons.info_rounded,
          iconColor: const Color(0xFF0D9488),
          bgColor: const Color(0xFFF0FDFA),
        );
    }
  }
}

class _CategoryStyle {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  _CategoryStyle({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}
