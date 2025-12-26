// lib/main.dart

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Eğer bu hata verirse: flutterfire configure komutunu tekrar çalıştır

// Ekran Importları
import 'screens/welcome_screen.dart'; // Yeni ekranımız
import 'screens/level_selection_screen.dart';
import 'screens/class_selection_screen.dart';
import 'screens/topic_selection_screen.dart';
import 'screens/style_chat_screen.dart';
import 'screens/narration_screen.dart';
import 'screens/profession_selection_screen.dart';
import 'screens/subject_selection_screen.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // --- TANI TESTİ ---
      print("\n🔍 --- TANI TESTİ ---");
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('✅ [1/3] DNS Başarılı');
        }
      } catch (e) {
        print('❌ [1/3] DNS HATASI: $e');
      }
      // ------------------

      // 1. Environment
      try {
        await dotenv.load(fileName: "apisecure.env");
      } catch (e) {
        debugPrint("⚠️ Env hatası: $e");
      }

      // 2. Firebase Başlat
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint("✅ Firebase Başlatıldı");
      } catch (e) {
        debugPrint("🔴 Firebase Hatası: $e");
      }

      // 3. UI Ayarları
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      runApp(const HMIntegralApp());
    },
    (error, stack) {
      debugPrint("🔴 CRITICAL APP ERROR: $error");
    },
  );
}

class HMIntegralApp extends StatelessWidget {
  const HMIntegralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HM Integral',
      debugShowCheckedModeBanner: false,
      theme: AppThemeBuilder.buildTheme(),
      // BAŞLANGIÇ ROTASI ARTIK WELCOME SCREEN
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRoutes.generateRoute,
      onUnknownRoute: AppRoutes.unknownRoute,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.1,
        );
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: scale),
          child: child!,
        );
      },
    );
  }
}

class AppThemeBuilder {
  static ThemeData buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C3AED),
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
    );
  }
}

class AppRoutes {
  // --- DEĞİŞKENLER BURADA TANIMLI OLMALI ---
  static const String welcome = '/welcome'; // Yeni rota
  static const String home = '/';
  static const String classSelection = '/class';
  static const String topicSelection = '/topic';
  static const String style = '/style';
  static const String narration = '/narration';
  static const String professionSelection = '/profession';
  static const String subjectSelection = '/subject';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const LevelSelectionScreen());

      case classSelection:
        return MaterialPageRoute(
          builder: (_) => ClassSelectionScreen(level: args?['level'] ?? ''),
        );

      case topicSelection:
        return MaterialPageRoute(
          builder: (_) => TopicSelectionScreen(
            level: args?['level'] ?? '',
            className: args?['class'] ?? '',
            profession: args?['profession'],
          ),
        );

      case style:
        return MaterialPageRoute(
          builder: (_) => StyleChatScreen(
            level: args?['level'] ?? '',
            className: args?['class'] ?? '',
            topic: args?['topic'] ?? '',
          ),
        );

      case narration:
        if (args == null) return unknownRoute(settings);
        return MaterialPageRoute(
          builder: (_) => NarrationScreen(
            topic: args['topic'] ?? '',
            style: args['style'] ?? '',
            level: args['level'] ?? '',
            className: args['className'] ?? '',
          ),
        );

      case professionSelection:
        return MaterialPageRoute(
          builder: (_) => ProfessionSelectionScreen(
            level: args?['level'] ?? '',
            className: args?['class'] ?? '',
          ),
        );

      case subjectSelection:
        return MaterialPageRoute(
          builder: (_) => SubjectSelectionScreen(
            level: args?['level'] ?? '',
            className: args?['class'] ?? '',
          ),
        );

      default:
        return unknownRoute(settings);
    }
  }

  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(child: Text("Sayfa bulunamadı: ${settings.name}")),
      ),
    );
  }
}
