import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Widget mini audio player yang ditampilkan di halaman detail surah.
/// Navigasi ke AudioPlayerPage dilakukan dari parent.
class AudioPlayerWidget extends StatelessWidget {
  final String surahName;
  final VoidCallback onPlay;

  const AudioPlayerWidget({
    super.key,
    required this.surahName,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.headset_rounded,
              color: AppColors.textOnPrimary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Murottal $surahName',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Dengarkan murottal lengkap',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_filled_rounded),
            iconSize: 42,
            color: AppColors.textOnPrimary,
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}
