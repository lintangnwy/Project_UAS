import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/surah_model.dart';
import '../services/surah_service.dart';
import '../widgets/loading_widget.dart' as lw;
import '../widgets/search_field.dart';
import '../widgets/surah_card.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  final SurahService _service = SurahService();
  final TextEditingController _searchController = TextEditingController();

  List<SurahModel> _allSurah = [];
  List<SurahModel> _filtered = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSurah();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSurah() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _service.fetchSurahList();
      if (mounted) {
        setState(() {
          _allSurah = data;
          _filtered = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = _allSurah.where((s) {
        return s.namaLatin.toLowerCase().contains(q) ||
            s.arti.toLowerCase().contains(q) ||
            s.nomor.toString().contains(q);
      }).toList();
    });
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
          AppConstants.appName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: SearchField(
              controller: _searchController,
              onChanged: _onSearch,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const lw.LoadingWidget(message: AppConstants.loadingText);
    }
    if (_errorMessage != null) {
      return lw.ErrorWidget(
        message: _errorMessage!,
        onRetry: _fetchSurah,
      );
    }
    if (_filtered.isEmpty) {
      return const lw.EmptyWidget(message: AppConstants.emptyData);
    }
    return ListView.separated(
      itemCount: _filtered.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final surah = _filtered[index];
        return SurahCard(
          surah: surah,
          onTap: () => context.push(
            AppConstants.surahDetailPath(surah.nomor),
            extra: surah,
          ),
        );
      },
    );
  }
}
