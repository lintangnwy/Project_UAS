import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';
import '../services/local_storage_service.dart';

// ─── Cached static decorations ───────────────────────────────────────────────

const _kCardGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.headerDark, AppColors.headerLight],
  ),
  borderRadius: BorderRadius.all(Radius.circular(20)),
);

const _kCardShadow = [
  BoxShadow(color: AppColors.primary30, blurRadius: 16, offset: Offset(0, 6)),
];

const _kNomorDecoration = BoxDecoration(
  color: AppColors.white20,
  shape: BoxShape.circle,
);

const _kContinueBtnDecoration = BoxDecoration(
  color: AppColors.white20,
  borderRadius: BorderRadius.all(Radius.circular(20)),
);

const _kDetailCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  boxShadow: [BoxShadow(color: AppColors.black05, blurRadius: 8, offset: Offset(0, 2))],
);

const _kInfoIconDecoration = BoxDecoration(
  color: AppColors.primaryLighter,
  borderRadius: BorderRadius.all(Radius.circular(8)),
);

const _kSectionBar = BoxDecoration(
  color: AppColors.primary,
  borderRadius: BorderRadius.all(Radius.circular(2)),
);

// ─── Text styles ─────────────────────────────────────────────────────────────

const _kNomorStyle    = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
const _kNameStyle     = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
const _kAyatStyle     = TextStyle(color: Colors.white70, fontSize: 13);
const _kContinueStyle = TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600);

// ─── Page ─────────────────────────────────────────────────────────────────────

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});
  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final _storage = LocalStorageService.instance;
  LastReadData? _lastRead;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _storage.getLastRead();
    if (mounted) setState(() { _lastRead = data; _isLoading = false; });
  }

  Future<void> _clearLastRead() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Riwayat?'),
        content: const Text('Riwayat baca terakhir akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _storage.clearLastRead();
      if (mounted) setState(() => _lastRead = null);
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
          'Riwayat Baca',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_lastRead != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Hapus riwayat',
              onPressed: _clearLastRead,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _lastRead == null ? _buildEmpty() : _buildContent(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_rounded, size: 80, color: AppColors.primaryLight40),
          const SizedBox(height: 16),
          Text('Belum ada riwayat', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          Text('Baca surah untuk menyimpan\nposisi terakhir secara otomatis.',
              style: AppTextStyles.body2, textAlign: TextAlign.center),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Buka Daftar Surah'),
            onPressed: () => context.go(AppConstants.routeSurahList),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final lr = _lastRead!;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section label
          Row(children: [
            const SizedBox(width: 4, height: 20,
                child: DecoratedBox(decoration: _kSectionBar)),
            const SizedBox(width: 10),
            Text('Terakhir Dibaca', style: AppTextStyles.headline3),
          ]),
          const SizedBox(height: 14),

          // Main card
          GestureDetector(
            onTap: () => context.push(AppConstants.surahDetailPath(lr.nomor)),
            child: DecoratedBox(
              decoration: _kCardGradient.copyWith(
                boxShadow: _kCardShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Nomor
                    DecoratedBox(
                      decoration: _kNomorDecoration,
                      child: SizedBox(
                        width: 56, height: 56,
                        child: Center(
                          child: Text('${lr.nomor}', style: _kNomorStyle),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lr.namaLatin, style: _kNameStyle),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.bookmark_rounded,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text('Terakhir di Ayat ${lr.nomorAyat}',
                                style: _kAyatStyle),
                          ]),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(lr.nama, style: AppTextStyles.arabicRiwayat),
                        const SizedBox(height: 8),
                        const DecoratedBox(
                          decoration: _kContinueBtnDecoration,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Lanjutkan', style: _kContinueStyle),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 12),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Detail card
          DecoratedBox(
            decoration: _kDetailCardDecoration,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail Riwayat', style: AppTextStyles.headline3),
                  const Divider(height: 20),
                  _InfoRow(icon: Icons.tag_rounded,
                      label: 'Nomor Surah', value: 'Surah ke-${lr.nomor}'),
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.menu_book_rounded,
                      label: 'Nama Surah', value: lr.namaLatin),
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.format_list_numbered_rounded,
                      label: 'Posisi Terakhir', value: 'Ayat ${lr.nomorAyat}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('Lanjutkan Membaca ${lr.namaLatin}'),
              onPressed: () =>
                  context.push(AppConstants.surahDetailPath(lr.nomor)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  static final _valueStyle =
      AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: _kInfoIconDecoration,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(value, style: _valueStyle),
          ],
        ),
      ],
    );
  }
}
