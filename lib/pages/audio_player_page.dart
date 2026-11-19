import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';
import '../widgets/custom_app_bar.dart';

class AudioPlayerPage extends StatefulWidget {
  final String surahName;
  final String audioUrl;

  const AudioPlayerPage({
    super.key,
    required this.surahName,
    required this.audioUrl,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late final AudioPlayer _player;
  bool _isLoading = true;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setUrl(widget.audioUrl);
      _player.durationStream.listen((d) {
        if (mounted) setState(() => _duration = d ?? Duration.zero);
      });
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
        }
      });
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat audio: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Murottal ${widget.surahName}'),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.body1
                          .copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  )
                : _buildPlayer(),
      ),
    );
  }

  Widget _buildPlayer() {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cover art
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: const Icon(
            Icons.headset_rounded,
            size: 100,
            color: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(height: 32),
        // Surah name
        Text(widget.surahName, style: AppTextStyles.headline2),
        const SizedBox(height: 8),
        Text('Murottal Al-Qur\'an', style: AppTextStyles.body2),
        const SizedBox(height: 32),
        // Progress bar
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primaryLighter,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              final seek = Duration(
                milliseconds: (value * _duration.inMilliseconds).round(),
              );
              _player.seek(seek);
            },
          ),
        ),
        // Duration labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position), style: AppTextStyles.caption),
              Text(_formatDuration(_duration), style: AppTextStyles.caption),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10_rounded),
              iconSize: 36,
              color: AppColors.primary,
              onPressed: () => _player.seek(
                Duration(seconds: _position.inSeconds - 10),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 40,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.forward_10_rounded),
              iconSize: 36,
              color: AppColors.primary,
              onPressed: () => _player.seek(
                Duration(seconds: _position.inSeconds + 10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
