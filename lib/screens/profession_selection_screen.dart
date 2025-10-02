// lib/screens/profession_selection_screen.dart

import 'package:flutter/material.dart';

/// Professional field selection screen for 11th and 12th grade students
///
/// Allows students to choose between different academic tracks:
/// - Sayısal (Science/Math focus)
/// - Sözel (Literature/Social Sciences focus)
/// - Eşit Ağırlık (Balanced)
class ProfessionSelectionScreen extends StatefulWidget {
  final String level;
  final String className;

  const ProfessionSelectionScreen({
    super.key,
    required this.level,
    required this.className,
  });

  @override
  State<ProfessionSelectionScreen> createState() =>
      _ProfessionSelectionScreenState();
}

class _ProfessionSelectionScreenState extends State<ProfessionSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _selectedProfession;
  bool _isNavigating = false;

  // Profession configuration constants
  static const Duration _animationDuration = Duration(milliseconds: 800);
  static const Duration _cardAnimationDelay = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initializes fade-in animations for smooth entrance
  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: FadeTransition(opacity: _fadeAnimation, child: _buildBody()),
      ),
    );
  }

  /// Builds app bar with back navigation and title
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Alan Seçimi',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  /// Builds main body with profession cards
  Widget _buildBody() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildProfessionList()),
        _buildContinueButton(),
      ],
    );
  }

  /// Builds header section with information
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 48,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.className} - Alan Seçimi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hangi alanda çalışmak istiyorsun?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds scrollable list of profession cards
  Widget _buildProfessionList() {
    final professions = _getProfessions();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: professions.length,
      itemBuilder: (context, index) {
        return _buildAnimatedProfessionCard(
          profession: professions[index],
          index: index,
        );
      },
    );
  }

  /// Builds individual profession card with animation
  Widget _buildAnimatedProfessionCard({
    required ProfessionData profession,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: _animationDuration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildProfessionCard(profession),
      ),
    );
  }

  /// Builds profession selection card
  Widget _buildProfessionCard(ProfessionData profession) {
    final isSelected = _selectedProfession == profession.id;

    return Card(
      elevation: isSelected ? 12 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _onProfessionSelected(profession.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Row(
            children: [
              _buildProfessionIcon(profession, isSelected),
              const SizedBox(width: 16),
              Expanded(child: _buildProfessionInfo(profession)),
              if (isSelected) _buildSelectionIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds profession icon with background
  Widget _buildProfessionIcon(ProfessionData profession, bool isSelected) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : profession.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        profession.icon,
        size: 32,
        color: isSelected ? Colors.white : profession.color,
      ),
    );
  }

  /// Builds profession title and description
  Widget _buildProfessionInfo(ProfessionData profession) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profession.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          profession.description,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        _buildSubjectChips(profession.subjects),
      ],
    );
  }

  /// Builds subject chips to show main subjects
  Widget _buildSubjectChips(List<String> subjects) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: subjects.map((subject) {
        return Chip(
          label: Text(subject, style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  /// Builds checkmark indicator for selected profession
  Widget _buildSelectionIndicator() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 20),
    );
  }

  /// Builds continue button at the bottom
  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _selectedProfession != null && !_isNavigating
              ? _navigateToTopicSelection
              : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: _selectedProfession != null ? 4 : 0,
          ),
          child: _isNavigating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Devam Et',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
        ),
      ),
    );
  }

  /// Handles profession selection
  void _onProfessionSelected(String professionId) {
    if (_isNavigating) return;

    setState(() {
      _selectedProfession = professionId;
    });

    // Haptic feedback
    // HapticFeedback.mediumImpact(); // Uncomment if you want haptic feedback
  }

  /// Navigates to topic selection with selected profession
  void _navigateToTopicSelection() {
    if (_selectedProfession == null || _isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    Navigator.pushNamed(
      context,
      '/topic',
      arguments: {
        'level': widget.level,
        'class': widget.className,
        'profession': _selectedProfession,
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    });
  }

  /// Returns list of available professions
  List<ProfessionData> _getProfessions() {
    return [
      ProfessionData(
        id: 'sayisal',
        title: 'Sayısal',
        description: 'Matematik, Fizik, Kimya, Biyoloji ağırlıklı',
        icon: Icons.calculate_outlined,
        color: Colors.blue,
        subjects: ['Matematik', 'Fizik', 'Kimya', 'Biyoloji'],
      ),
      ProfessionData(
        id: 'sozel',
        title: 'Sözel',
        description: 'Edebiyat, Tarih, Coğrafya ağırlıklı',
        icon: Icons.menu_book_outlined,
        color: Colors.orange,
        subjects: ['Edebiyat', 'Tarih', 'Coğrafya', 'Felsefe'],
      ),
      ProfessionData(
        id: 'esit_agirlik',
        title: 'Eşit Ağırlık',
        description: 'Dengeli bir ders dağılımı',
        icon: Icons.balance_outlined,
        color: Colors.green,
        subjects: ['Matematik', 'Edebiyat', 'Tarih', 'Coğrafya'],
      ),
    ];
  }
}

/// Data class for profession information
class ProfessionData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> subjects;

  const ProfessionData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.subjects,
  });
}
