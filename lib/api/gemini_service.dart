// lib/api/gemini_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  // Singleton pattern için
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  // Cache için
  String? _cachedApiKey;
  String? _cachedModel;
  Uri? _cachedChatUrl;

  // API anahtarını güvenli bir şekilde al - lazy loading ile
  String? get _apiKey {
    if (_cachedApiKey != null) return _cachedApiKey;

    try {
      final key = dotenv.env['GEMINI_API_KEY'];
      if (key == null || key.isEmpty) {
        debugPrint('HATA: GEMINI_API_KEY bulunamadı veya boş!');
        debugPrint('Mevcut env keys: ${dotenv.env.keys.toList()}');
        return null;
      }
      _cachedApiKey = key;
      return key;
    } catch (e) {
      debugPrint('API key okuma hatası: $e');
      debugPrint('dotenv initialized: ${dotenv.isInitialized}');
      return null;
    }
  }

  // Model bilgilerini güvenli bir şekilde al
  String get _model {
    if (_cachedModel != null) return _cachedModel!;

    try {
      _cachedModel = dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash';
      return _cachedModel!;
    } catch (e) {
      debugPrint('Model okuma hatası: $e');
      return 'gemini-1.5-flash'; // fallback
    }
  }

  // URL'yi lazy olarak oluştur
  Uri? get _chatUrl {
    if (_cachedChatUrl != null) return _cachedChatUrl;

    final apiKey = _apiKey;
    if (apiKey == null) return null;

    try {
      _cachedChatUrl = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/$_model:generateContent'
        '?key=$apiKey',
      );
      return _cachedChatUrl;
    } catch (e) {
      debugPrint('URL oluşturma hatası: $e');
      return null;
    }
  }

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'User-Agent': 'HMIntegral/1.0',
  };

  /// Environment dosyasının yüklenip yüklenmediğini kontrol et
  bool get _isEnvLoaded {
    try {
      return dotenv.isInitialized && dotenv.env.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Chat mesajı gönder ve yanıt al
  Future<String> sendChat(String question) async {
    // Boş mesaj kontrolü
    if (question.trim().isEmpty) {
      return 'Hata: Mesaj boş olamaz.';
    }

    // Environment kontrolü
    if (!_isEnvLoaded) {
      debugPrint('Environment dosyası yüklenmemiş!');
      try {
        debugPrint('dotenv.isInitialized: ${dotenv.isInitialized}');
        debugPrint('dotenv.env.isEmpty: ${dotenv.env.isEmpty}');
      } catch (e) {
        debugPrint('dotenv durumu kontrol edilemedi: $e');
      }
      return 'Hata: Yapılandırma dosyası yüklenemedi. Uygulamayı yeniden başlatın.';
    }

    // API key kontrolü
    final apiKey = _apiKey;
    if (apiKey == null) {
      return 'Hata: API anahtarı bulunamadı. Lütfen apisecure.env dosyasını kontrol edin.';
    }

    // URL kontrolü
    final chatUrl = _chatUrl;
    if (chatUrl == null) {
      return 'Hata: API URL\'si oluşturulamadı.';
    }

    // API isteği için body
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
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
      ],
    });

    try {
      debugPrint('Gemini API\'ye istek gönderiliyor...');
      debugPrint('URL: $chatUrl');
      debugPrint('Model: $_model');

      final response = await http
          .post(chatUrl, headers: _headers, body: body)
          .timeout(const Duration(seconds: 30));

      debugPrint('API Durum Kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // API yanıtını parse et
        if (data.containsKey('candidates') &&
            data['candidates'] is List &&
            (data['candidates'] as List).isNotEmpty) {
          final candidate = data['candidates'][0] as Map<String, dynamic>;

          if (candidate.containsKey('content') &&
              candidate['content'] is Map<String, dynamic>) {
            final content = candidate['content'] as Map<String, dynamic>;

            if (content.containsKey('parts') &&
                content['parts'] is List &&
                (content['parts'] as List).isNotEmpty) {
              final parts = content['parts'] as List;
              final firstPart = parts[0] as Map<String, dynamic>;

              if (firstPart.containsKey('text')) {
                final text = firstPart['text'] as String;
                return text.trim();
              }
            }
          }
        }

        // Yanıt formatı beklenenden farklıysa
        debugPrint('Beklenmeyen API yanıt formatı: ${response.body}');
        return 'Hata: API\'den beklenmeyen yanıt formatı alındı.';
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          debugPrint('API Hata 400: ${response.body}');
          return 'Hata: Geçersiz istek. ${errorData['error']?['message'] ?? 'Lütfen sorunuzu yeniden formüle edin.'}';
        } catch (e) {
          return 'Hata: Geçersiz istek formatı.';
        }
      } else if (response.statusCode == 401) {
        debugPrint('API Hata 401: Yetkisiz erişim');
        return 'Hata: API anahtarı geçersiz. Lütfen apisecure.env dosyasını kontrol edin.';
      } else if (response.statusCode == 403) {
        debugPrint('API Hata 403: Erişim reddedildi');
        return 'Hata: API erişimi reddedildi. Kotanızı kontrol edin.';
      } else if (response.statusCode == 429) {
        debugPrint('API Hata 429: Çok fazla istek');
        return 'Hata: Çok fazla istek gönderdiniz. Lütfen biraz bekleyin.';
      } else if (response.statusCode >= 500) {
        debugPrint('API Hata ${response.statusCode}: Sunucu hatası');
        return 'Hata: Sunucu geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
      } else {
        debugPrint(
          'Bilinmeyen API Hatası ${response.statusCode}: ${response.body}',
        );
        return 'Hata: Beklenmeyen bir hata oluştu. (Kod: ${response.statusCode})';
      }
    } on http.ClientException catch (e) {
      debugPrint('HTTP İstemci Hatası: $e');
      return 'Hata: İnternet bağlantınızı kontrol edin.';
    } on FormatException catch (e) {
      debugPrint('JSON Parse Hatası: $e');
      return 'Hata: Sunucudan geçersiz yanıt alındı.';
    } catch (e) {
      debugPrint('Genel Hata: $e');
      return 'Hata: Bilinmeyen bir sorun oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// Cache'i temizle ve yeniden yükle
  void refreshConfig() {
    _cachedApiKey = null;
    _cachedModel = null;
    _cachedChatUrl = null;
    debugPrint('GeminiService cache temizlendi');
  }

  /// API bağlantısını test et
  Future<bool> testConnection() async {
    try {
      final result = await sendChat('Test');
      return !result.startsWith('Hata:');
    } catch (e) {
      debugPrint('Bağlantı testi başarısız: $e');
      return false;
    }
  }

  /// Mevcut konfigürasyonu kontrol et
  bool get isConfigured {
    return _isEnvLoaded && _apiKey != null && _chatUrl != null;
  }

  /// Debug bilgilerini yazdır (sadece debug modda)
  void printDebugInfo() {
    if (kDebugMode) {
      debugPrint('=== Gemini Service Debug Info ===');
      debugPrint('Env loaded: $_isEnvLoaded');
      try {
        debugPrint('dotenv.isInitialized: ${dotenv.isInitialized}');
        debugPrint('dotenv.env.keys: ${dotenv.env.keys.toList()}');
      } catch (e) {
        debugPrint('dotenv durumu okunamadı: $e');
      }
      debugPrint('API Key var: ${_apiKey != null}');
      debugPrint('Model: $_model');
      debugPrint('URL oluşturulabilir: ${_chatUrl != null}');
      debugPrint('Configured: $isConfigured');
      debugPrint('================================');
    }
  }
}
