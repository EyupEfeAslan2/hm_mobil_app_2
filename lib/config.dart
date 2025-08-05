// lib/config.dart

class Config {
  // Backend’inizin ana URL’sini buraya yazın:
  static const String apiBaseUrl = 'https://api.yourdomain.com';

  // Endpoint path’leri
  static const String chatPath = '/chat';
  static const String stylePath = '/style';
  static const String narrationPath = '/generateStory';

  // Eğer auth token kullanıyorsanız:
  static const String authToken = 'Bearer eyJ...';
}
