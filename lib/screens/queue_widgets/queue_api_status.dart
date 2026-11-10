
import 'package:flutter/material.dart';
import '../../services/antrean_service.dart';

class QueueApiStatus extends StatelessWidget {
  const QueueApiStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AntreanService.isLoadingApi,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: AntreanService.errorApi,
          builder: (context, error, _) {
            return ValueListenableBuilder<bool>(
              valueListenable:
                  AntreanService.antreanTerverifikasiApi,
              builder: (context, verified, _) {
                String message;
                IconData icon;
                Color color;

                if (isLoading) {
                  message = 'Memperbarui data antrean...';
                  icon = Icons.sync;
                  color = Colors.blue;
                } else if (error != null) {
                  message =
                      'Gagal terhubung ke server. Data mungkin belum terbaru.';
                  icon = Icons.warning_amber_rounded;
                  color = Colors.orange;
                } else if (verified) {
                  message = 'Data antrean berhasil diperbarui dari server';
                  icon = Icons.check_circle_outline;
                  color = Colors.green;
                } else {
                  message = 'Data antrean belum diverifikasi dari server';
                  icon = Icons.info_outline;
                  color = Colors.grey;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
