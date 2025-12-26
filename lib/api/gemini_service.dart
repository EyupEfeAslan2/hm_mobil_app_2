import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  // AYARLAR
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 1);

  // LİSTENDE KESİN OLARAK VAR OLAN MODEL:
  static const String _fixedModel = 'gemini-flash-latest';

  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  // API Key Okuyucu
  String? get _apiKey {
    // 1. Önce .env dosyasına bak
    String? key = dotenv.env['GEMINI_API_KEY'];

    // 2. Eğer env çalışmazsa, buraya manuel keyini yazabilirsin (Test için)
    // if (key == null || key.isEmpty) return "MANUEL_KEY_BURAYA";

    return key;
  }

  // URL Oluşturucu
  Uri _getChatUrl(String apiKey) {
    return Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_fixedModel:generateContent?key=$apiKey',
    );
  }

  Future<String> sendChat(String question) async {
    if (question.trim().isEmpty) return 'Lütfen bir soru yazın.';

    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('❌ API Key Hatası: Env dosyasını veya Keyi kontrol et.');
      return 'Hata: API anahtarı eksik.';
    }

    final url = _getChatUrl(apiKey);

    // Gemini 2.0 Flash İstek Formatı
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': question.trim()},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    });

    return await _retryRequest(url, body);
  }

  Future<String> _retryRequest(Uri url, String body) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        debugPrint("📡 İstek atılıyor: $_fixedModel (Deneme ${attempts + 1})");

        final response = await http
            .post(url, headers: _headers, body: body)
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          return _parseResponse(response.body);
        } else {
          debugPrint('❌ API Hatası: ${response.statusCode} - ${response.body}');

          if (response.statusCode == 404) {
            return "Model bulunamadı (404). Bu çok garip çünkü listede var.";
          }

          // Retryable hatalar
          if (response.statusCode == 429 || response.statusCode == 503) {
            attempts++;
            await Future.delayed(_baseDelay * pow(2, attempts - 1));
            continue;
          }
          return 'Sunucu Hatası: ${response.statusCode}';
        }
      } catch (e) {
        attempts++;
        debugPrint('🔌 Bağlantı Hatası: $e');
        await Future.delayed(_baseDelay);
      }
    }
    return 'İnternet bağlantını kontrol et.';
  }

  String _parseResponse(String responseBody) {
    try {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      return data['candidates']?[0]?['content']?['parts']?[0]?['text']
              ?.trim() ??
          'Cevap alınamadı.';
    } catch (e) {
      return 'Veri işleme hatası.';
    }
  }
}
