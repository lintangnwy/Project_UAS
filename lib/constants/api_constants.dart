class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://equran.id/api/v2';
  static const String surahEndpoint = '/surat';

  /// Mengembalikan URL detail surah berdasarkan nomor
  static String surahDetailUrl(int nomor) => '$baseUrl$surahEndpoint/$nomor';
}
