import '../constants/api_constants.dart';
import '../models/surah_model.dart';
import 'api_service.dart';

class SurahService {
  final ApiService _api;

  SurahService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  /// Mengambil daftar 114 surah.
  Future<List<SurahModel>> fetchSurahList() async {
    final body = await _api.get(
      '${ApiConstants.baseUrl}${ApiConstants.surahEndpoint}',
    );
    return surahListFromJson(body);
  }

  /// Mengambil detail surah beserta daftar ayat.
  Future<SurahDetailModel> fetchSurahDetail(int nomor) async {
    final body = await _api.get(ApiConstants.surahDetailUrl(nomor));
    return surahDetailFromJson(body);
  }
}
