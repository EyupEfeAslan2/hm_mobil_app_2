// lib/screens/class_selection_screen.dart

import 'package:flutter/material.dart';

/// Class selection screen for different education levels
///
/// Displays available classes based on the selected education level
/// (Elementary, Middle School, or High School) and navigates to
/// appropriate next screen based on grade level
class ClassSelectionScreen extends StatelessWidget {
  final String level;

  const ClassSelectionScreen({super.key, required this.level});

  // UI Configuration Constants
  static const double _gridCrossAxisSpacing = 16.0;
  static const double _gridMainAxisSpacing = 16.0;
  static const double _gridChildAspectRatio = 1.2;
  static const int _gridCrossAxisCount = 2;

  // Color Configuration
  static const Color _primaryColor = Color(0xFF7C3AED);
  static const Color _secondaryColor = Color(0xFF6B21A8);
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _gradientStart = Color(0xFFF3E8FF);
  static const Color _gradientEnd = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Builds app bar with level-specific title
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '$level — Sınıf Seçimi',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  /// Builds main body with gradient background
  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_gradientStart, _gradientEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildClassGrid(),
          ],
        ),
      ),
    );
  }

  /// Builds header card with level icon and description
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(_getLevelIcon(), size: 48, color: _primaryColor),
          const SizedBox(height: 12),
          Text(
            'Hangi sınıftasın?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sınıfını seçerek konulara erişebilirsin',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds grid of class selection cards
  Widget _buildClassGrid() {
    final classes = _getClassesForLevel();
    final classIcons = _getClassIcons();

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridCrossAxisCount,
          childAspectRatio: _gridChildAspectRatio,
          crossAxisSpacing: _gridCrossAxisSpacing,
          mainAxisSpacing: _gridMainAxisSpacing,
        ),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          return _buildClassCard(
            context: context,
            className: classes[index],
            classIcon: classIcons[index],
            index: index,
          );
        },
      ),
    );
  }

  /// Builds individual class selection card with gradient
  Widget _buildClassCard({
    required BuildContext context,
    required String className,
    required IconData classIcon,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, _secondaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _handleClassSelection(context, className),
          child: _buildCardContent(className, classIcon),
        ),
      ),
    );
  }

  /// Builds content inside class card
  Widget _buildCardContent(String className, IconData classIcon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildClassIconContainer(classIcon),
          const SizedBox(height: 12),
          _buildClassName(className),
          const SizedBox(height: 4),
          _buildClassSubtitle(),
        ],
      ),
    );
  }

  /// Builds class icon with background
  Widget _buildClassIconContainer(IconData classIcon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(classIcon, size: 32, color: Colors.white),
    );
  }

  /// Builds class name text
  Widget _buildClassName(String className) {
    return Text(
      className,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds subtitle text
  Widget _buildClassSubtitle() {
    return Text(
      'Konulara Git',
      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
    );
  }

  /// Handles class selection and navigation
  ///
  /// For 11th and 12th grade, navigates to profession selection
  /// For other grades, navigates directly to topic selection
  void _handleClassSelection(BuildContext context, String className) {
    final isHighSchoolSenior =
        className == '11. Sınıf' || className == '12. Sınıf';

    if (isHighSchoolSenior) {
      _navigateToProfessionSelection(context, className);
    } else {
      _navigateToTopicSelection(context, className);
    }
  }

  /// Navigates to profession selection screen (for 11th and 12th grade)
  void _navigateToProfessionSelection(BuildContext context, String className) {
    Navigator.pushNamed(
      context,
      '/profession',
      arguments: {'level': level, 'class': className},
    );
  }

  /// Navigates to topic selection screen (for other grades)
  void _navigateToTopicSelection(BuildContext context, String className) {
    Navigator.pushNamed(
      context,
      '/topic',
      arguments: {'level': level, 'class': className},
    );
  }

  /// Returns appropriate icon based on education level
  IconData _getLevelIcon() {
    switch (level) {
      case 'Lise':
        return Icons.school;
      case 'Ortaokul':
        return Icons.auto_stories;
      case 'İlkokul':
        return Icons.child_care;
      default:
        return Icons.school;
    }
  }

  /// Returns list of classes based on education level
  List<String> _getClassesForLevel() {
    switch (level) {
      case 'İlkokul':
        return ['1. Sınıf', '2. Sınıf', '3. Sınıf', '4. Sınıf'];
      case 'Ortaokul':
        return ['5. Sınıf', '6. Sınıf', '7. Sınıf', '8. Sınıf'];
      case 'Lise':
        return ['9. Sınıf', '10. Sınıf', '11. Sınıf', '12. Sınıf'];
      default:
        return [];
    }
  }

  /// Returns appropriate icons for classes based on education level
  List<IconData> _getClassIcons() {
    switch (level) {
      case 'İlkokul':
        return [Icons.looks_one, Icons.looks_two, Icons.looks_3, Icons.looks_4];
      case 'Ortaokul':
        return [Icons.looks_5, Icons.looks_6, Icons.auto_stories, Icons.school];
      case 'Lise':
        return [
          Icons.school,
          Icons.science,
          Icons.calculate,
          Icons.emoji_events,
        ];
      default:
        return [];
    }
  }
}
