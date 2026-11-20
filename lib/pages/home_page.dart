import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';
import '../services/local_storage_service.dart';

// ─── Cached static decorations ───────────────────────────────────────────────

const _kHeaderGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.headerDark, AppColors.headerMid, AppColors.headerLight],
  ),
);

const _kBismillahDecoration = BoxDecoration(
  color: AppColors.white10,
  borderRadius: BorderRadius.all(Radius.circular(12)),
  border: Border.fromBorderSide(BorderSide(color: AppColors.white15)),
);

const _kAppIconDecoration = BoxDecoration(
  color: AppColors.white15,
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

const _kLastReadGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
  ),
  borderRadius: BorderRadius.all(Radius.circular(18)),
);

const _kLastReadButtonDecoration = BoxDecoration(
  color: AppColors.white20,
  borderRadius: BorderRadius.all(Radius.circular(20)),
);

const _kStatCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(14)),
  boxShadow: [BoxShadow(color: AppColors.black05, blurRadius: 8, offset: Offset(0, 2))],
);

const _kMenuBorder = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(14)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFEEEEEE))),
);

const _kSectionBar = BoxDecoration(
  color: AppColors.primary,
  borderRadius: BorderRadius.all(Radius.circular(2)),
);

// ─── Text styles ─────────────────────────────────────────────────────────────

const _kAppTitleStyle = TextStyle(
    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.3);
const _kLastReadLabelStyle = TextStyle(
    color: AppColors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0);
const _kLastReadNameStyle = TextStyle(
    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
const _kLastReadAyatStyle = TextStyle(color: AppColors.white75, fontSize: 13);
const _kLastReadBtnStyle = TextStyle(
    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600);

// ─── Page ─────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = LocalStorageService.instance;
  LastReadData? _lastRead;
  int _bookmarkCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final lastRead = await _storage.getLastRead();
    final bookmarks = await _storage.getBookmarks();
    if (mounted) {
      setState(() {
        _lastRead = lastRead;
        _bookmarkCount = bookmarks.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadLocalData,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_lastRead != null) ...[
                    _LastReadCard(lastRead: _lastRead!, onTap: () =>
                        context.push(AppConstants.surahDetailPath(_lastRead!.nomor))),
                    const SizedBox(height: 20),
                  ],
                  _buildStatsRow(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('Menu Utama'),
                  const SizedBox(height: 12),
                  _MenuCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Daftar Surah',
                    subtitle: '114 Surah Al-Qur\'an',
                    color: AppColors.primary,
                    badge: null,
                    onTap: () => context.go(AppConstants.routeSurahList),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: Icons.history_rounded,
                    title: 'Riwayat Baca',
                    subtitle: _lastRead != null
                        ? 'Terakhir: ${_lastRead!.namaLatin} Ayat ${_lastRead!.nomorAyat}'
                        : 'Belum ada riwayat',
                    color: const Color(0xFF6A1B9A),
                    badge: null,
                    onTap: () => context.go(AppConstants.routeRiwayat),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: Icons.bookmark_rounded,
                    title: 'Bookmark',
                    subtitle: _bookmarkCount > 0
                        ? '$_bookmarkCount surah disimpan'
                        : 'Belum ada bookmark',
                    color: const Color(0xFF1565C0),
                    badge: _bookmarkCount > 0 ? '$_bookmarkCount' : null,
                    onTap: () => context.go(AppConstants.routeBookmark),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.headerDark,
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: _kHeaderGradient,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const DecoratedBox(
                        decoration: _kAppIconDecoration,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.menu_book_rounded,
                              color: Colors.white, size: 26),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Al-Qur\'an', style: _kAppTitleStyle),
                          Text(AppConstants.appTagline,
                              style: const TextStyle(
                                  color: AppColors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  DecoratedBox(
                    decoration: _kBismillahDecoration,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                          'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                          style: AppTextStyles.arabicHomeHero,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.menu_book_rounded, value: '114',
            label: 'Total\nSurah', color: AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(icon: Icons.bookmark_rounded,
            value: '$_bookmarkCount', label: 'Surah\nDisimpan',
            color: const Color(0xFF1565C0))),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(icon: Icons.history_rounded,
            value: _lastRead != null ? 'S.${_lastRead!.nomor}' : '-',
            label: 'Terakhir\nDibaca', color: const Color(0xFF6A1B9A))),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        const SizedBox(
          width: 4, height: 20,
          child: DecoratedBox(decoration: _kSectionBar),
        ),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.headline3),
      ],
    );
  }
}

// ─── Last Read Card ───────────────────────────────────────────────────────────

class _LastReadCard extends StatelessWidget {
  final LastReadData lastRead;
  final VoidCallback onTap;
  const _LastReadCard({required this.lastRead, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: _kLastReadGradient,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.history_rounded, color: Colors.white70, size: 13),
                        SizedBox(width: 5),
                        Text('LANJUTKAN MEMBACA', style: _kLastReadLabelStyle),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(lastRead.namaLatin, style: _kLastReadNameStyle),
                    const SizedBox(height: 2),
                    Text('Ayat ${lastRead.nomorAyat}', style: _kLastReadAyatStyle),
                    const SizedBox(height: 10),
                    const DecoratedBox(
                      decoration: _kLastReadButtonDecoration,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Buka Sekarang', style: _kLastReadBtnStyle),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 11),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(lastRead.nama, style: AppTextStyles.arabicLastRead),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.icon, required this.value,
      required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _kStatCardDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption,
                textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }
}

// ─── Menu Card ────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback onTap;
  const _MenuCard({required this.icon, required this.title,
      required this.subtitle, required this.color,
      required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        child: DecoratedBox(
          decoration: _kMenuBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: SizedBox(
                    width: 46, height: 46,
                    child: Icon(icon, color: color, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTextStyles.surahTitle.copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTextStyles.body2,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (badge != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      child: Text(badge!, style: const TextStyle(
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  Icon(Icons.chevron_right_rounded,
                      color: color.withValues(alpha: 0.6), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
