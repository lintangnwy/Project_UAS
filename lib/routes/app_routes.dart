import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../models/surah_model.dart';
import '../pages/audio_player_page.dart';
import '../pages/home_page.dart';
import '../pages/surah_detail_page.dart';
import '../pages/surah_list_page.dart';

final appRouter = GoRouter(
  initialLocation: AppConstants.routeHome,
  routes: [
    GoRoute(
      path: AppConstants.routeHome,
      builder: (_, __) => const HomePage(),
    ),
    GoRoute(
      path: AppConstants.routeSurahList,
      builder: (_, __) => const SurahListPage(),
      routes: [
        // Sub-route: /surah/:nomor — back akan kembali ke /surah
        GoRoute(
          path: ':nomor',
          builder: (context, state) {
            final nomor =
                int.tryParse(state.pathParameters['nomor'] ?? '1') ?? 1;
            final surahPreview = state.extra as SurahModel?;
            return SurahDetailPage(nomor: nomor, surahPreview: surahPreview);
          },
          routes: [
            // Sub-route: /surah/:nomor/audio — back kembali ke detail
            GoRoute(
              path: 'audio',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return AudioPlayerPage(
                  surahName: extra['surahName'] as String,
                  audioUrl: extra['audioUrl'] as String,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
