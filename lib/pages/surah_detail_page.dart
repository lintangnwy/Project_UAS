import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';
import '../models/surah_model.dart';
import '../services/local_storage_service.dart';
import '../services/surah_service.dart';
import '../widgets/loading_widget.dart' as lw;

// ─── Last-read5 marker decorations ────────────────────────────────────────────

const _kLastReadTopBar = BoxDecoration(
  color: Color(0xFFFFF3E0),
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
  ),
);

const _kLastReadCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  border: Border.fromBorderSide(
    BorderSide(color: Color(0xFFFFB300), width: 1.5),
  ),
  boxShadow: [
    BoxShadow(color: Color(0x33FFB300), blurRadius: 10, offset: Offset(0, 3)),
  ],
);

const _kLastReadBadgeDecoration = BoxDecoration(
  color: Color(0xFFFFB300),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

const _kLastReadNomorDecoration = BoxDecoration(
  color: Color(0xFFFFB300),
  shape: BoxShape.circle,
);

const _kLastReadBadgeStyle = TextStyle(
  color: Colors.white,
  fontSize: 10,
  fontWeight: FontWeight.bold,
  letterSpacing: 0.5,
);

// ─── Normal card decorations ──────────────────────────────────────────────────

const _kHeaderGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.headerDark, AppColors.headerLight],
  ),
);

const _kBismillahDecoration = BoxDecoration(
  color: AppColors.white15,
  borderRadius: BorderRadius.all(Radius.circular(20)),
);

const _kBadgeDecoration = BoxDecoration(
  color: AppColors.white20,
  borderRadius: BorderRadius.all(Radius.circular(20)),
);

const _kSectionCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  boxShadow: [BoxShadow(color: AppColors.black05, blurRadius: 10, offset: Offset(0, 2))],
);

const _kAyatCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  boxShadow: [BoxShadow(color: AppColors.black04, blurRadius: 8, offset: Offset(0, 2))],
);

const _kAyatTopBar = BoxDecoration(
  color: AppColors.primaryLighter,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
  ),
);

const _kNomorDecoration = BoxDecoration(
  color: AppColors.primary,
  shape: BoxShape.circle,
);

const _kToggleDecoration = BoxDecoration(
  color: AppColors.primary10,
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

const _kLatinBoxDecoration = BoxDecoration(
  color: Color(0xFFF8F8F8),
  borderRadius: BorderRadius.all(Radius.circular(10)),
  border: Border.fromBorderSide(BorderSide(color: AppColors.divider)),
);

const _kAyatBadgeDecoration = BoxDecoration(
  color: AppColors.primaryLighter,
  borderRadius: BorderRadius.all(Radius.circular(20)),
);

const _kSectionBarDecoration = BoxDecoration(
  color: AppColors.primary,
  borderRadius: BorderRadius.all(Radius.circular(2)),
);

// ─── Text styles ─────────────────────────────────────────────────────────────

const _kAppBarTitleStyle = TextStyle(
    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600);
const _kBadgeLabelStyle = TextStyle(
    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500);
const _kNomorStyle = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13);
const _kAyatCountStyle = TextStyle(
    color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12);

// ─── Page ─────────────────────────────────────────────────────────────────────

class SurahDetailPage extends StatefulWidget {
  final int nomor;
  final SurahModel? surahPreview;

  const SurahDetailPage({super.key, required this.nomor, this.surahPreview});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final _service = SurahService();
  final _storage = LocalStorageService.instance;
  final _scrollController = ScrollController();

  SurahDetailModel? _detail;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isBookmarked = false;

  /// Nomor ayat yang terakhir ditandai. null = belum pernah ditandai.
  int? _lastReadAyat;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _checkBookmark();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      // Cek apakah surah ini sudah punya riwayat baca sebelumnya
      final existing = await _storage.getLastRead();
      final savedAyat = (existing != null && existing.nomor == widget.nomor)
          ? existing.nomorAyat
          : null;

      final data = await _service.fetchSurahDetail(widget.nomor);
      if (mounted) setState(() {
        _detail = data;
        _isLoading = false;
        // Hanya tampilkan marker jika memang sudah pernah ditandai sebelumnya
        _lastReadAyat = savedAyat;
      });

      // Simpan ke riwayat — gunakan posisi tersimpan atau ayat 1 jika baru
      await _storage.saveLastRead(
        nomor: data.nomor, namaLatin: data.namaLatin,
        nama: data.nama, nomorAyat: savedAyat ?? 1,
      );

      // Auto-scroll ke ayat terakhir hanya jika lebih dari ayat 1
      if (savedAyat != null && savedAyat > 1 && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAyat(savedAyat, data.ayat.length);
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _scrollToAyat(int nomorAyat, int totalAyat) {
    if (!_scrollController.hasClients) return;
    const double appBar        = 56;
    const double headerCard    = 190;
    const double staticSection = 320;
    const double cardHeight    = 220;
    final index  = (nomorAyat - 1).clamp(0, totalAyat - 1);
    final offset = appBar + headerCard + staticSection + index * cardHeight;
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _markLastRead(int nomorAyat) async {
    final d = _detail;
    if (d == null) return;
    await _storage.saveLastRead(
      nomor: d.nomor, namaLatin: d.namaLatin,
      nama: d.nama, nomorAyat: nomorAyat,
    );
    if (mounted) setState(() => _lastReadAyat = nomorAyat);
  }

  Future<void> _checkBookmark() async {
    final val = await _storage.isBookmarked(widget.nomor);
    if (mounted) setState(() => _isBookmarked = val);
  }

  Future<void> _toggleBookmark() async {
    final now = await _storage.toggleBookmark(widget.nomor);
    if (mounted) {
      setState(() => _isBookmarked = now);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(now
            ? '${_detail?.namaLatin} ditambahkan ke bookmark'
            : '${_detail?.namaLatin} dihapus dari bookmark'),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  static String _cleanHtml(String t) =>
      t.replaceAll('<br>', '\n\n').replaceAll(RegExp(r'<[^>]*>'), '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: _isLoading
          ? const lw.LoadingWidget(message: AppConstants.loadingText)
          : _errorMessage != null
              ? lw.ErrorWidget(message: _errorMessage!, onRetry: _fetchDetail)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final d = _detail!;
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // ── Pinned AppBar ────────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.headerDark,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text(d.namaLatin, style: _kAppBarTitleStyle),
          actions: [
            // Bookmark surah (bukan bookmark per ayat)
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  key: ValueKey(_isBookmarked),
                  color: Colors.white,
                ),
              ),
              tooltip: _isBookmarked
                  ? 'Hapus bookmark surah'
                  : 'Bookmark surah ini',
              onPressed: _toggleBookmark,
            ),
          ],
        ),

        // ── Header card ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: DecoratedBox(
            decoration: _kHeaderGradient,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: _kBismillahDecoration,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Text(
                        'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                        style: AppTextStyles.arabicBismillah,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(d.nama, style: AppTextStyles.arabicHeaderWhite),
                  const SizedBox(height: 4),
                  Text(
                    '${d.namaLatin}  •  ${d.arti}',
                    style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.white90,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _Badge(
                          icon: Icons.location_on_rounded,
                          label: d.tempatTurun),
                      _Badge(
                          icon: Icons.format_list_numbered_rounded,
                          label: '${d.jumlahAyat} Ayat'),
                      _Badge(
                          icon: Icons.tag_rounded,
                          label: 'Surah ${d.nomor}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Deskripsi + ayat header ───────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              DecoratedBox(
                decoration: _kSectionCardDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Tentang Surah',
                            style: AppTextStyles.headline3),
                      ]),
                      const Divider(height: 20),
                      Text(
                        _cleanHtml(d.deskripsi),
                        style: AppTextStyles.body1,
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(
                    width: 4, height: 22,
                    child: DecoratedBox(
                        decoration: _kSectionBarDecoration),
                  ),
                  const SizedBox(width: 10),
                  Text('Daftar Ayat', style: AppTextStyles.headline3),
                  const Spacer(),
                  DecoratedBox(
                    decoration: _kAyatBadgeDecoration,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      child: Text('${d.jumlahAyat} ayat',
                          style: _kAyatCountStyle),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),

        // ── Daftar ayat — lazy render ─────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
          sliver: SliverList.builder(
            itemCount: d.ayat.length,
            itemBuilder: (context, i) => _AyatCard(
              ayat: d.ayat[i],
              surahName: d.namaLatin,
              isLastRead: _lastReadAyat != null &&
                  d.ayat[i].nomorAyat == _lastReadAyat,
              onLastRead: _markLastRead,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Header badge ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _kBadgeDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 5),
            Text(label, style: _kBadgeLabelStyle),
          ],
        ),
      ),
    );
  }
}

// ─── Ayat Card ────────────────────────────────────────────────────────────────

class _AyatCard extends StatefulWidget {
  final AyatModel ayat;
  final String surahName;
  final bool isLastRead;
  final Future<void> Function(int) onLastRead;

  const _AyatCard({
    required this.ayat,
    required this.surahName,
    required this.isLastRead,
    required this.onLastRead,
  });

  @override
  State<_AyatCard> createState() => _AyatCardState();
}

class _AyatCardState extends State<_AyatCard> {
  bool _showLatin = true;

  static final _latinStyle = AppTextStyles.body2.copyWith(
      fontStyle: FontStyle.italic,
      color: AppColors.primary,
      fontSize: 13,
      height: 1.6);
  static final _terjStyle = AppTextStyles.body1
      .copyWith(color: AppColors.textSecondary, height: 1.6);
  static final _toggleStyle = AppTextStyles.caption
      .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600);
  static const _toggleStyleAmber = TextStyle(
      color: Color(0xFF7B4F00), fontSize: 12, fontWeight: FontWeight.w600);

  void _share() {
    final t = '${widget.surahName} : Ayat ${widget.ayat.nomorAyat}\n\n'
        '${widget.ayat.teksArab}\n\n${widget.ayat.teksLatin}\n\n'
        '${widget.ayat.teksIndonesia}\n\n— Dibagikan via Aplikasi Al-Qur\'an';
    Share.share(t,
        subject: '${widget.surahName} Ayat ${widget.ayat.nomorAyat}');
  }

  void _copy() {
    Clipboard.setData(ClipboardData(
        text: '${widget.ayat.teksArab}\n\n${widget.ayat.teksLatin}'
            '\n\n${widget.ayat.teksIndonesia}'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ayat disalin ke clipboard'),
        duration: Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final isLast = widget.isLastRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: isLast ? _kLastReadCardDecoration : _kAyatCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ───────────────────────────────────────────────────
            DecoratedBox(
              decoration: isLast ? _kLastReadTopBar : _kAyatTopBar,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    // Nomor ayat
                    DecoratedBox(
                      decoration: isLast
                          ? _kLastReadNomorDecoration
                          : _kNomorDecoration,
                      child: SizedBox(
                        width: 32, height: 32,
                        child: Center(
                          child: Text('${widget.ayat.nomorAyat}',
                              style: _kNomorStyle),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge terakhir dibaca
                    if (isLast)
                      DecoratedBox(
                        decoration: _kLastReadBadgeDecoration,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_rounded,
                                  size: 10, color: Colors.white),
                              SizedBox(width: 4),
                              Text('TERAKHIR DIBACA',
                                  style: _kLastReadBadgeStyle),
                            ],
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Toggle latin
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showLatin = !_showLatin),
                      child: DecoratedBox(
                        decoration: isLast
                            ? const BoxDecoration(
                                color: Color(0x1AFFB300),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(12)))
                            : _kToggleDecoration,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: Text(
                            _showLatin ? 'Sembunyikan' : 'Tampilkan Latin',
                            style: isLast
                                ? _toggleStyleAmber
                                : _toggleStyle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _Act(
                        icon: Icons.copy_rounded,
                        tooltip: 'Salin',
                        onTap: _copy),
                    _Act(
                        icon: Icons.share_rounded,
                        tooltip: 'Bagikan',
                        onTap: _share),
                    _Act(
                      icon: isLast
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_add_rounded,
                      tooltip: isLast
                          ? 'Posisi baca saat ini'
                          : 'Tandai posisi baca',
                      onTap: () async {
                        await widget.onLastRead(widget.ayat.nomorAyat);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                            content: Text(
                                'Posisi baca ditandai di Ayat ${widget.ayat.nomorAyat}'),
                            duration: const Duration(seconds: 2),
                          ));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // ── Body ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.ayat.teksArab,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.arabicLarge),
                  if (_showLatin) ...[
                    const SizedBox(height: 10),
                    DecoratedBox(
                      decoration: _kLatinBoxDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(widget.ayat.teksLatin,
                            style: _latinStyle),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(widget.ayat.teksIndonesia, style: _terjStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _Act extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _Act(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}
