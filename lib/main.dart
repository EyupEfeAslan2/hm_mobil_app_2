// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/level_selection_screen.dart';
import 'screens/class_selection_screen.dart';
import 'screens/topic_selection_screen.dart';
import 'screens/style_chat_screen.dart';
import 'screens/narration_screen.dart';

/// Application entry point
///
/// Initializes the app with proper configuration including:
/// - Environment variables loading
/// - System UI customization
/// - Screen orientation settings
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeApp();
  _configureSystemUI();
  _setPreferredOrientations();

  runApp(const HMIntegralApp());
}

/// Initializes application environment and configuration
Future<void> _initializeApp() async {
  try {
    await dotenv.load(fileName: "apisecure.env");
    debugPrint("✅ Environment configuration loaded successfully");
  } catch (e) {
    debugPrint("⚠️ Failed to load apisecure.env: $e");
  }
}

/// Configures system UI appearance
void _configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

/// Sets preferred device orientations to portrait only
void _setPreferredOrientations() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// Main application widget
///
/// HM Integral - AI-powered learning assistant application
/// Provides intelligent tutoring with adaptive learning styles
class HMIntegralApp extends StatelessWidget {
  const HMIntegralApp({super.key});

  // Theme configuration constants
  static const double _maxTextScaleFactor = 1.2;
  static const double _minTextScaleFactor = 0.8;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HM Integral - Akıllı Öğrenme Asistanı',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppThemeBuilder.buildTheme(),

      // Performance and accessibility optimizations
      builder: _buildAppWithOptimizations,

      // Navigation configuration
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      onUnknownRoute: AppRoutes.unknownRoute,

      // Enhanced scroll behavior
      scrollBehavior: CustomScrollBehavior(),
    );
  }

  /// Builds app with performance and accessibility optimizations
  Widget _buildAppWithOptimizations(BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(
            context,
          ).textScaleFactor.clamp(_minTextScaleFactor, _maxTextScaleFactor),
        ),
      ),
      child: child!,
    );
  }
}

/// Application theme builder utility class
///
/// Centralizes theme configuration for consistent styling
/// throughout the application
class AppThemeBuilder {
  // Private constructor to prevent instantiation
  AppThemeBuilder._();

  // Theme configuration constants
  static const double _cardElevation = 8.0;
  static const double _borderRadius = 16.0;
  static const double _inputBorderRadius = 12.0;
  static const double _buttonBorderRadius = 12.0;

  /// Builds comprehensive application theme configuration
  static ThemeData buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      textTheme: _buildTextTheme(),
      pageTransitionsTheme: _buildPageTransitionsTheme(),
    );
  }

  /// Builds AppBar theme configuration
  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Builds Card theme configuration
  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      elevation: _cardElevation,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    );
  }

  /// Builds ElevatedButton theme configuration
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
        ),
      ),
    );
  }

  /// Builds input decoration theme configuration
  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    );
  }

  /// Builds text theme configuration
  static TextTheme _buildTextTheme() {
    return const TextTheme(
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
    );
  }

  /// Builds page transitions theme
  static PageTransitionsTheme _buildPageTransitionsTheme() {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    );
  }
}

/// Application routing configuration
///
/// Manages navigation between screens with proper parameter validation
/// and error handling
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route path constants
  static const String home = '/';
  static const String classSelection = '/class';
  static const String topicSelection = '/topic';
  static const String styleChat = '/style';
  static const String narration = '/narration';

  // Route transition configuration
  static const Duration _transitionDuration = Duration(milliseconds: 300);
  static const Offset _slideBegin = Offset(1.0, 0.0);
  static const Offset _slideEnd = Offset.zero;
  static const Curve _transitionCurve = Curves.easeInOutCubic;

  /// Generates routes based on settings with comprehensive error handling
  static Route<dynamic> generateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case home:
          return _createRoute(const LevelSelectionScreen());

        case classSelection:
          return _buildClassSelectionRoute(settings);

        case topicSelection:
          return _buildTopicSelectionRoute(settings);

        case styleChat:
          return _buildStyleChatRoute(settings);

        case narration:
          return _buildNarrationRoute(settings);

        default:
          return unknownRoute(settings);
      }
    } catch (e) {
      debugPrint('Route generation error: $e');
      return unknownRoute(settings);
    }
  }

  /// Builds class selection route with parameter validation
  static Route<dynamic> _buildClassSelectionRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, String>?;
    final level = args?['level'];

    if (level == null) {
      throw ArgumentError('Level parameter is required for class selection');
    }

    return _createRoute(ClassSelectionScreen(level: level));
  }

  /// Builds topic selection route with parameter validation
  static Route<dynamic> _buildTopicSelectionRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, String>?;
    final level = args?['level'];
    final className = args?['class'];

    if (level == null || className == null) {
      throw ArgumentError(
        'Level and class parameters are required for topic selection',
      );
    }

    return _createRoute(
      TopicSelectionScreen(level: level, className: className),
    );
  }

  /// Builds style chat route with parameter validation
  static Route<dynamic> _buildStyleChatRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, String>?;
    final level = args?['level'];
    final className = args?['class'];
    final topic = args?['topic'];

    if (level == null || className == null || topic == null) {
      throw ArgumentError(
        'Level, class, and topic parameters are required for style chat',
      );
    }

    return _createRoute(
      StyleChatScreen(level: level, className: className, topic: topic),
    );
  }

  /// Builds narration route with comprehensive parameter validation
  static Route<dynamic> _buildNarrationRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, String>?;
    final topic = args?['topic'];
    final style = args?['style'];
    final level = args?['level'];
    final className = args?['className'];

    if (topic == null || style == null || level == null || className == null) {
      throw ArgumentError(
        'Topic, style, level, and className parameters are required for narration',
      );
    }

    return _createRoute(
      NarrationScreen(
        topic: topic,
        style: style,
        level: level,
        className: className,
      ),
    );
  }

  /// Handles unknown routes with user-friendly error page
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
                onPressed: () =>
                    debugPrint("Navigation to home page requested"),
                icon: const Icon(Icons.home),
                label: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates custom route with slide transition animation
  static PageRoute<dynamic> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: _slideBegin,
          end: _slideEnd,
        ).chain(CurveTween(curve: _transitionCurve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: _transitionDuration,
    );
  }
}

/// Custom scroll behavior for enhanced user experience
///
/// Provides platform-specific scrollbar behavior and supports
/// multiple input devices (touch, mouse, stylus)
class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Show scrollbar only on desktop platforms
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
