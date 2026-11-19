import 'package:http/http.dart' as http;

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// GET request; throws [Exception] jika status bukan 200.
  Future<String> get(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      }
      throw Exception(
        'Request gagal — status ${response.statusCode}: $url',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}
