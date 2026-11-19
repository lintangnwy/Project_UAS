import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';
import '../models/surah_model.dart';
import '../services/surah_service.dart';
import '../widgets/loading_widget.dart' as lw;

class SurahDetailPage extends StatefulWidget {
  final int nomor;
  final SurahModel? surahPreview;

  const SurahDetailPage({
    super.key,
    required this.nomor,
    this.surahPreview,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final SurahService _service = SurahService();
  SurahDetailModel? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _service.fetchSurahDetail(widget.nomor);
      if (mounted) setState(() {
        _detail = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _cleanHtml(String text) => text
      .replaceAll('<br>', '\n\n')
      .replaceAll(RegExp(r'<[^>]*>'), '');

  void _openAudioPlayer() {
    if (_detail == null) return;
    final audioUrl =
        _detail!.audioFull['01'] ?? _detail!.audioFull.values.first;
    context.push(
      AppConstants.audioPlayerPath(widget.nomor),
      extra: {'surahName': _detail!.namaLatin, 'audioUrl': audioUrl},
    );
  }

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
      slivers: [
        _buildSliverHeader(d),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              _buildAudioBanner(d),
              const SizedBox(height: 20),
              _buildDeskripsiSection(d),
              const SizedBox(height: 24),
              _buildAyatHeader(d),
              const SizedBox(height: 12),
              ...d.ayat.map((ayat) => _AyatCard(ayat: ayat)),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  // ─── Sliver App Bar (gradient header) ──────────────────────────────────────

  Widget _buildSliverHeader(SurahDetailModel d) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF004D40), Color(0xFF00897B), Color(0xFF26A69A)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bismillah ornament
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontFamily: 'serif',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nama Arab
                  Text(
                    d.nama,
                    style: const TextStyle(
                      fontSize: 42,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Nama latin + arti
                  Text(
                    '${d.namaLatin}  •  ${d.arti}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Badge info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HeaderBadge(
                        icon: Icons.location_on_rounded,
                        label: d.tempatTurun,
                      ),
                      const SizedBox(width: 12),
                      _HeaderBadge(
                        icon: Icons.format_list_numbered_rounded,
                        label: '${d.jumlahAyat} Ayat',
                      ),
                      const SizedBox(width: 12),
                      _HeaderBadge(
                        icon: Icons.tag_rounded,
                        label: 'Surah ${d.nomor}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Audio Banner ───────────────────────────────────────────────────────────

  Widget _buildAudioBanner(SurahDetailModel d) {
    return GestureDetector(
      onTap: _openAudioPlayer,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00695C), Color(0xFF00897B)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Murottal Al-Qur\'an',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Dengarkan Surah ${d.namaLatin}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.headset_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  // ─── Deskripsi ──────────────────────────────────────────────────────────────

  Widget _buildDeskripsiSection(SurahDetailModel d) {
    return _SectionCard(
      title: 'Tentang Surah',
      icon: Icons.info_outline_rounded,
      child: Text(
        _cleanHtml(d.deskripsi),
        style: AppTextStyles.body1.copyWith(height: 1.7),
        textAlign: TextAlign.justify,
      ),
    );
  }

  // ─── Ayat header ────────────────────────────────────────────────────────────

  Widget _buildAyatHeader(SurahDetailModel d) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text('Daftar Ayat', style: AppTextStyles.headline3),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${d.jumlahAyat} ayat',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Header Badge ─────────────────────────────────────────────────────────────

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.headline3),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }
}

// ─── Ayat Card ────────────────────────────────────────────────────────────────

class _AyatCard extends StatefulWidget {
  final AyatModel ayat;

  const _AyatCard({required this.ayat});

  @override
  State<_AyatCard> createState() => _AyatCardState();
}

class _AyatCardState extends State<_AyatCard> {
  bool _showLatin = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top bar: nomor + toggle ─────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Nomor bulat
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.ayat.nomorAyat}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Toggle latin
                GestureDetector(
                  onTap: () => setState(() => _showLatin = !_showLatin),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _showLatin ? 'Sembunyikan Latin' : 'Tampilkan Latin',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Teks Arab
                Text(
                  widget.ayat.teksArab,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 2.2,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                // Transliterasi latin (toggle)
                if (_showLatin) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      widget.ayat.teksLatin,
                      style: AppTextStyles.body2.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Terjemahan
                Text(
                  widget.ayat.teksIndonesia,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
