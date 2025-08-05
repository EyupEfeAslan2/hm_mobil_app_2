// lib/api/story_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class StoryService {
  static const String _baseUrl = 'https://api.mycompany.com'; // ← Gerçek host
  static const String _endpoint = '/api/generateStory'; // ← Gerçek endpoint
  static const String _apiToken = 'Bearer eyJhbGciOi...'; // Eğer varsa

  Future<String> fetchNarration({
    required String topic,
    required String style,
  }) async {
    final uri = Uri.parse('$_baseUrl$_endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (_apiToken.isNotEmpty) 'Authorization': _apiToken,
    };
    final body = jsonEncode({'topic': topic, 'style': style});

    final response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception('API hata ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['text'] as String;
  }
}
