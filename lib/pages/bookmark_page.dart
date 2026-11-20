import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';
import '../models/surah_model.dart';
import '../services/local_storage_service.dart';
import '../services/surah_service.dart';
import '../widgets/loading_widget.dart' as lw;

// ─── Cached static decorations ───────────────────────────────────────────────

const _kDismissBg = BoxDecoration(color: AppColors.error);
const _kBadgePadding = EdgeInsets.symmetric(horizontal: 24, vertical: 12);

// ─── Page ─────────────────────────────────────────────────────────────────────

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});
  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final _storage = LocalStorageService.instance;
  final _service = SurahService();

  List<SurahModel> _surahs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final nomors = await _storage.getBookmarks();
      if (nomors.isEmpty) {
        if (mounted) setState(() { _surahs = []; _isLoading = false; });
        return;
      }
      final all = await _service.fetchSurahList();
      final filtered = all.where((s) => nomors.contains(s.nomor)).toList()
        ..sort((a, b) => nomors.indexOf(a.nomor).compareTo(nomors.indexOf(b.nomor)));
      if (mounted) setState(() { _surahs = filtered; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _remove(SurahModel surah) async {
    await _storage.removeBookmark(surah.nomor);
    setState(() => _surahs.remove(surah));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${surah.namaLatin} dihapus dari bookmark'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () async {
            await _storage.addBookmark(surah.nomor);
            _load();
          },
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppConstants.routeHome),
        ),
        title: const Text(
          'Bookmark',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_surahs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Hapus semua bookmark',
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: _isLoading
          ? const lw.LoadingWidget(message: 'Memuat bookmark...')
          : _error != null
              ? lw.ErrorWidget(message: _error!, onRetry: _load)
              : _surahs.isEmpty ? _buildEmpty() : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmark_border_rounded,
              size: 72, color: AppColors.primaryLight40),
          const SizedBox(height: 16),
          Text('Belum ada bookmark', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          Text(
            'Tekan ikon bookmark pada halaman\ndetail surah untuk menyimpan.',
            style: AppTextStyles.body2, textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: _kBadgePadding,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            icon: const Icon(Icons.list_alt_rounded),
            label: const Text('Buka Daftar Surah'),
            onPressed: () => context.go(AppConstants.routeSurahList),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _surahs.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, i) {
        final surah = _surahs[i];
        return Dismissible(
          key: ValueKey(surah.nomor),
          direction: DismissDirection.endToStart,
          background: const DecoratedBox(
            decoration: _kDismissBg,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete_rounded, color: Colors.white),
              ),
            ),
          ),
          onDismissed: (_) => _remove(surah),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: _NomorBadge(nomor: surah.nomor),
            title: Text(surah.namaLatin, style: AppTextStyles.surahTitle),
            subtitle: Text('${surah.tempatTurun} • ${surah.jumlahAyat} Ayat',
                style: AppTextStyles.surahSubtitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(surah.nama, style: AppTextStyles.arabicBookmark),
                IconButton(
                  icon: const Icon(Icons.bookmark_rounded,
                      color: AppColors.primary),
                  tooltip: 'Hapus bookmark',
                  onPressed: () => _remove(surah),
                ),
              ],
            ),
            onTap: () => context.push(
                AppConstants.surahDetailPath(surah.nomor), extra: surah),
          ),
        );
      },
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Bookmark?'),
        content: const Text(
            'Semua surah yang di-bookmark akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final bm = await _storage.getBookmarks();
              for (final n in bm) await _storage.removeBookmark(n);
              if (mounted) setState(() => _surahs = []);
            },
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }
}

// ─── Nomor Badge ──────────────────────────────────────────────────────────────

class _NomorBadge extends StatelessWidget {
  final int nomor;
  const _NomorBadge({required this.nomor});

  static final _numStyle = AppTextStyles.caption.copyWith(
      fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44, height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.star_rounded, size: 44, color: AppColors.primaryLighter),
          Text('$nomor', style: _numStyle),
        ],
      ),
    );
  }
}
