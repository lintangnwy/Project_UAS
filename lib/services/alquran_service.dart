import 'package:http/http.dart' as http;
import 'package:uas_alquran/models/alquran.dart';
class AlquranService {
  static const String _baseUrl = 'https://equran.id/api/v2/surat';

  Future<List<Datum>> fetchSurah() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // Menggunakan fungsi alquranFromJson yang sudah ada di model kamu
        final Alquran result = alquranFromJson(response.body);
        return result.data;
      } else {
        throw Exception('Gagal memuat data surah (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}