class AppConstants {
  AppConstants._();

  static const String appName = 'Al-Qur\'an';
  static const String appTagline = 'Baca & Dengarkan Al-Qur\'an';

  // Padding & spacing
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 20.0;

  // Surah info labels
  static const String labelMekah = 'Mekah';
  static const String labelMadinah = 'Madinah';
  static const String labelAyat = 'Ayat';
  static const String labelTempatTurun = 'Tempat Turun';
  static const String labelJumlahAyat = 'Jumlah Ayat';

  // Error & state messages
  static const String errorGeneric = 'Terjadi kesalahan. Coba lagi.';
  static const String errorNetwork = 'Gagal terhubung ke server.';
  static const String emptyData = 'Data tidak ditemukan.';
  static const String loadingText = 'Memuat data...';

  // Route paths (used in GoRouter definition)
  static const String routeHome = '/';
  static const String routeSurahList = '/surah';

  // Helper: full path untuk navigasi ke detail dan audio
  static String surahDetailPath(int nomor) => '/surah/$nomor';
  static String audioPlayerPath(int nomor) => '/surah/$nomor/audio';
}
