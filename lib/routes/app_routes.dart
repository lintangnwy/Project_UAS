import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../models/surah_model.dart';
import '../pages/bookmark_page.dart';
import '../pages/home_page.dart';
import '../pages/riwayat_page.dart';
import '../pages/surah_detail_page.dart';
import '../pages/surah_list_page.dart';
import '../widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: AppConstants.routeHome,
  routes: [
    // ── Shell: semua tab utama (punya BottomNav) ─────────────────────────────
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppConstants.routeHome,
          builder: (_, __) => const HomePage(),
        ),
        GoRoute(
          path: AppConstants.routeRiwayat,
          builder: (_, __) => const RiwayatPage(),
        ),
        GoRoute(
          path: AppConstants.routeBookmark,
          builder: (_, __) => const BookmarkPage(),
        ),
        GoRoute(
          path: AppConstants.routeSurahList,
          builder: (_, __) => const SurahListPage(),
        ),
      ],
    ),

    // ── Full-screen routes (tidak punya BottomNav) ───────────────────────────
    GoRoute(
      path: '/surah/:nomor',
      builder: (context, state) {
        final nomor =
            int.tryParse(state.pathParameters['nomor'] ?? '1') ?? 1;
        final surahPreview = state.extra as SurahModel?;
        return SurahDetailPage(nomor: nomor, surahPreview: surahPreview);
      },
    ),
  ],
);
