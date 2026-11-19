import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/surah_model.dart';

class SurahCard extends StatelessWidget {
  final SurahModel surah;
  final VoidCallback onTap;

  const SurahCard({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Nomor surah
            _NomorBadge(nomor: surah.nomor),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.namaLatin, style: AppTextStyles.surahTitle),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.tempatTurun} • ${surah.jumlahAyat} Ayat',
                    style: AppTextStyles.surahSubtitle,
                  ),
                ],
              ),
            ),
            // Nama Arab
            Text(surah.nama, style: AppTextStyles.arabicText),
          ],
        ),
      ),
    );
  }
}

class _NomorBadge extends StatelessWidget {
  final int nomor;

  const _NomorBadge({required this.nomor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            size: 44,
            color: AppColors.primaryLighter,
          ),
          Text(
            '$nomor',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
