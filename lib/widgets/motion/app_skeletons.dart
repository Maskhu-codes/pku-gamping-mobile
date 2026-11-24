import 'package:flutter/material.dart';
import 'app_shimmer.dart';

/// Skeleton selektor poliklinik (meniru bentuk `JadwalPoliFilter` kartu selektor).
class PoliChipsSkeleton extends StatelessWidget {
  const PoliChipsSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        height: 58,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 38, height: 38, borderRadius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SkeletonBox(width: 80, height: 10, borderRadius: 4),
                  SizedBox(height: 6),
                  SkeletonBox(width: 140, height: 14, borderRadius: 4),
                ],
              ),
            ),
            const SkeletonBox(width: 64, height: 28, borderRadius: 10),
          ],
        ),
      ),
    );
  }
}

/// Skeleton daftar kartu jadwal dokter (meniru bentuk `JadwalDokterList`).
class JadwalDokterListSkeleton extends StatelessWidget {
  const JadwalDokterListSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('jadwal_dokter_skeleton'),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: AppShimmer(
        child: Column(
          children: List.generate(itemCount, (index) {
            final isLast = index == itemCount - 1;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      const SkeletonBox(height: 48, isCircle: true),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Expanded(
                                  child: SkeletonBox(
                                    height: 14,
                                    borderRadius: 6,
                                  ),
                                ),
                                SizedBox(width: 12),
                                SkeletonBox(
                                  width: 62,
                                  height: 20,
                                  borderRadius: 10,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const SkeletonBox(
                              width: 120,
                              height: 11,
                              borderRadius: 5,
                            ),
                            const SizedBox(height: 8),
                            const SkeletonBox(
                              width: 96,
                              height: 11,
                              borderRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// Skeleton slot jadwal praktik dokter (meniru bentuk `PendaftaranJadwalPicker`).
class SlotPickerSkeleton extends StatelessWidget {
  const SlotPickerSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      key: const Key('slot_picker_skeleton'),
      child: Column(
        children: List.generate(itemCount, (index) {
          return Container(
            margin: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: Row(
              children: [
                const SkeletonBox(width: 38, height: 38, borderRadius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 150, height: 13, borderRadius: 6),
                      SizedBox(height: 8),
                      SkeletonBox(width: 105, height: 11, borderRadius: 5),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const SkeletonBox(width: 68, height: 24, borderRadius: 12),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton daftar item pada modal bottom sheet Poli & Dokter.
class SelectionSheetListSkeleton extends StatelessWidget {
  const SelectionSheetListSkeleton({
    super.key,
    this.itemCount = 5,
    this.circleLeading = false,
  });

  final int itemCount;
  final bool circleLeading;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      key: const Key('selection_sheet_skeleton'),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, _) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5EAF2)),
          ),
          child: Row(
            children: [
              SkeletonBox(
                width: 40,
                height: 40,
                borderRadius: 10,
                isCircle: circleLeading,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 160, height: 13, borderRadius: 6),
                    SizedBox(height: 7),
                    SkeletonBox(width: 110, height: 10, borderRadius: 5),
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

/// Skeleton halaman Antrean (meniru `DoctorSummaryCard` + `ActiveQueueCard`).
class QueueScreenSkeleton extends StatelessWidget {
  const QueueScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('queue_screen_skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      child: AppShimmer(
        child: Column(
          children: [
            // Skeleton Kartu Ringkasan Dokter
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5EAF2)),
              ),
              child: Row(
                children: [
                  const SkeletonBox(height: 52, isCircle: true),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonBox(width: 170, height: 14, borderRadius: 6),
                        SizedBox(height: 8),
                        SkeletonBox(width: 115, height: 12, borderRadius: 5),
                        SizedBox(height: 8),
                        SkeletonBox(width: 145, height: 11, borderRadius: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Skeleton Kartu Antrean Aktif
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5EAF2)),
              ),
              child: Column(
                children: [
                  const SkeletonBox(height: 44, borderRadius: 12),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(
                        child: SkeletonBox(height: 118, borderRadius: 16),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: SkeletonBox(height: 118, borderRadius: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SkeletonBox(height: 58, borderRadius: 14),
                  const SizedBox(height: 18),
                  const SkeletonBox(height: 48, borderRadius: 13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
