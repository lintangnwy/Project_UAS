import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Logo / icon area
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 56,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Center(
                child: Text(
                  AppConstants.appName,
                  style: AppTextStyles.headline1.copyWith(
                    color: AppColors.primary,
                    fontSize: 36,
                  ),
                ),
              ),
              Center(
                child: Text(
                  AppConstants.appTagline,
                  style: AppTextStyles.body2,
                ),
              ),
              const SizedBox(height: 48),
              // Menu cards
              _MenuCard(
                icon: Icons.list_alt_rounded,
                title: 'Daftar Surah',
                subtitle: '114 Surah Al-Qur\'an',
                onTap: () => context.go(AppConstants.routeSurahList),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headline3),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.body2),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
