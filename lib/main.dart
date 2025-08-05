// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ Sadece bu satır eklendi
import 'screens/level_selection_screen.dart';
import 'screens/class_selection_screen.dart';
import 'screens/topic_selection_screen.dart';
import 'screens/style_chat_screen.dart';
import 'screens/narration_screen.dart';

void main() async {
  // System UI konfigürasyonu
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ apisecure.env dosyasını yükle - hata kontrolü ile
  try {
    await dotenv.load(fileName: "apisecure.env");
  } catch (e) {
    debugPrint("⚠️ apisecure.env dosyası yüklenemedi: $e");
  }

  // Status bar ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Desteklenen orientasyonlar
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const HMIntegralApp());
}

class HMIntegralApp extends StatelessWidget {
  const HMIntegralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HM Integral - Akıllı Öğrenme Asistanı',
      debugShowCheckedModeBanner: false,

      // Modern tema konfigürasyonu
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,

      // Performans optimizasyonları
      builder: (context, child) {
        return MediaQuery(
          // Text scaling sınırla
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },

      // Navigation ayarları
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      onUnknownRoute: AppRoutes.unknownRoute,

      // Scroll davranışı
      scrollBehavior: CustomScrollBehavior(),
    );
  }

  /// Light tema konfigürasyonu
  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // AppBar tema
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Card tema
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ElevatedButton tema
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input decoration tema
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),

      // Text tema
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
        ),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Dark tema konfigürasyonu
  ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),

      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Uygulama route'ları
class AppRoutes {
  static const String home = '/';
  static const String classSelection = '/class';
  static const String topicSelection = '/topic';
  static const String styleChat = '/style';
  static const String narration = '/narration';

  /// Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case home:
          return _createRoute(const LevelSelectionScreen());

        case classSelection:
          final args = settings.arguments as Map<String, String>?;
          if (args?['level'] == null) throw ArgumentError('Level is required');

          return _createRoute(ClassSelectionScreen(level: args!['level']!));

        case topicSelection:
          final args = settings.arguments as Map<String, String>?;
          if (args?['level'] == null || args?['class'] == null) {
            throw ArgumentError('Level and class are required');
          }

          return _createRoute(
            TopicSelectionScreen(
              level: args!['level']!,
              className: args['class']!,
            ),
          );

        case styleChat:
          final args = settings.arguments as Map<String, String>?;
          if (args?['level'] == null ||
              args?['class'] == null ||
              args?['topic'] == null) {
            throw ArgumentError('Level, class and topic are required');
          }

          return _createRoute(
            StyleChatScreen(
              level: args!['level']!,
              className: args['class']!,
              topic: args['topic']!,
            ),
          );

        case narration:
          final args = settings.arguments as Map<String, String>?;
          // **DÜZELTME:** Gerekli tüm parametreler kontrol ediliyor.
          if (args?['topic'] == null ||
              args?['style'] == null ||
              args?['level'] == null ||
              args?['className'] == null) {
            throw ArgumentError(
              'Topic, style, level and className are required',
            );
          }
          // **DÜZELTME:** Tüm parametreler NarrationScreen'e aktarılıyor.
          return _createRoute(
            NarrationScreen(
              topic: args!['topic']!,
              style: args['style']!,
              level: args['level']!,
              className: args['className']!,
            ),
          );

        default:
          return unknownRoute(settings);
      }
    } catch (e) {
      debugPrint('Route generation error: $e');
      return unknownRoute(settings);
    }
  }

  /// Bilinmeyen route handler
  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return _createRoute(
      Scaffold(
        appBar: AppBar(
          title: const Text('Sayfa Bulunamadı'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Sayfa bulunamadı: ${settings.name}',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Bu kısım bir context gerektirdiği için doğrudan çalışmaz.
                  // Global bir navigatorKey kullanmak daha doğru bir yaklaşım olurdu.
                  // Şimdilik basit bir print ile bırakıyorum.
                  debugPrint("Ana sayfaya dönülmeye çalışıldı.");
                },
                icon: const Icon(Icons.home),
                label: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom route transition
  static PageRoute _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Custom scroll behavior
class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Platform-specific scrollbar
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return Scrollbar(controller: details.controller, child: child);
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
    }
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };
}
