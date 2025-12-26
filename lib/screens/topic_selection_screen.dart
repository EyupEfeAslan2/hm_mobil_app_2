// lib/screens/topic_selection_screen.dart

import 'package:flutter/material.dart';
import '../data/content_data.dart';

/// Topic selection screen with profession-based filtering
///
/// Displays available topics based on selected level, class, and profession
/// (for 11th and 12th grade students). Includes search functionality and
/// animated topic cards.
class TopicSelectionScreen extends StatefulWidget {
  final String level;
  final String className;
  final String? profession;

  const TopicSelectionScreen({
    super.key,
    required this.level,
    required this.className,
    this.profession,
  });

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  final List<AnimationController> _cardControllers = [];

  String _searchQuery = '';
  List<String> _filteredTopics = [];
  List<String> _allTopics = [];

  // Animation configuration
  static const Duration _staggerBaseDuration = Duration(milliseconds: 600);
  static const Duration _cardAnimationDuration = Duration(milliseconds: 400);
  static const int _cardDelayMilliseconds = 100;

  @override
  void initState() {
    super.initState();
    _loadTopics();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  /// Loads topics based on level, class, and profession
  void _loadTopics() {
    _allTopics = _getTopicsForSelection();
    _filteredTopics = List.from(_allTopics);
  }

  /// Gets topics based on selection criteria
  List<String> _getTopicsForSelection() {
    // Get base topics for level and class
    final baseTopic = '${widget.level}-${widget.className}';

    // If profession is specified (11th or 12th grade)
    if (widget.profession != null) {
      final professionKey = '$baseTopic-${widget.profession}';
      final professionTopics = contentData[professionKey];

      if (professionTopics != null && professionTopics.isNotEmpty) {
        return professionTopics;
      }
    }

    // Fallback to standard topics
    return contentData[widget.level]?[widget.className] ?? [];
  }

  /// Initializes stagger animation controller
  void _initializeAnimations() {
    final totalDuration =
        _staggerBaseDuration.inMilliseconds +
        (_filteredTopics.length * _cardDelayMilliseconds);

    _staggerController = AnimationController(
      duration: Duration(milliseconds: totalDuration),
      vsync: this,
    );

    _initializeCardControllers();
    _staggerController.forward();
  }

  /// Initializes animation controllers for each card
  void _initializeCardControllers() {
    _disposeCardControllers();

    for (int i = 0; i < _filteredTopics.length; i++) {
      final controller = AnimationController(
        duration: _cardAnimationDuration,
        vsync: this,
      );
      _cardControllers.add(controller);

      _scheduleCardAnimation(controller, i);
    }
  }

  /// Schedules animation for a card with delay
  void _scheduleCardAnimation(AnimationController controller, int index) {
    Future.delayed(Duration(milliseconds: index * _cardDelayMilliseconds), () {
      if (mounted) controller.forward();
    });
  }

  /// Disposes all card animation controllers
  void _disposeCardControllers() {
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    _cardControllers.clear();
  }

  /// Disposes all animation controllers
  void _disposeAnimations() {
    _staggerController.dispose();
    _disposeCardControllers();
  }

  /// Filters topics based on search query
  void _filterTopics(String query) {
    setState(() {
      _searchQuery = query;
      _filteredTopics = query.isEmpty
          ? List.from(_allTopics)
          : _allTopics
                .where(
                  (topic) => topic.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
    });

    _initializeCardControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Builds app bar with level and class information
  PreferredSizeWidget _buildAppBar() {
    final levelColor = _getLevelColor();

    return AppBar(
      title: _buildAppBarTitle(),
      backgroundColor: levelColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  /// Builds app bar title with subtitle
  Widget _buildAppBarTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Konu Seçimi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          _buildSubtitleText(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Builds subtitle text with profession info if available
  String _buildSubtitleText() {
    final parts = [widget.level, widget.className];

    if (widget.profession != null) {
      parts.add(_getProfessionDisplayName(widget.profession!));
    }

    return parts.join(' • ');
  }

  /// Gets display name for profession
  String _getProfessionDisplayName(String profession) {
    switch (profession) {
      case 'sayisal':
        return 'Sayısal';
      case 'sozel':
        return 'Sözel';
      case 'esit_agirlik':
        return 'Eşit Ağırlık';
      default:
        return profession;
    }
  }

  /// Builds main body with gradient background
  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3E8FF), Color(0xFFFFFFFF)],
        ),
      ),
      child: Column(
        children: [
          _buildHeaderCard(),
          Expanded(
            child: _filteredTopics.isEmpty
                ? _buildEmptyState()
                : _buildTopicList(),
          ),
        ],
      ),
    );
  }

  /// Builds header card with search functionality
  Widget _buildHeaderCard() {
    final levelColor = _getLevelColor();

    return Container(
      margin: const EdgeInsets.all(16),
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
          _buildHeaderInfo(levelColor),
          const SizedBox(height: 16),
          _buildSearchField(),
        ],
      ),
    );
  }

  /// Builds header information row
  Widget _buildHeaderInfo(Color levelColor) {
    return Row(
      children: [
        _buildHeaderIcon(levelColor),
        const SizedBox(width: 16),
        _buildHeaderText(),
      ],
    );
  }

  /// Builds header icon container
  Widget _buildHeaderIcon(Color levelColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        widget.level == 'Lise'
            ? Icons.school
            : widget.level == 'Ortaokul'
            ? Icons.auto_stories
            : Icons.child_care,
        color: levelColor,
        size: 28,
      ),
    );
  }

  /// Builds header text information
  Widget _buildHeaderText() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hangi konuyu öğrenmek istiyorsun?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_filteredTopics.length} konu mevcut',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Builds search text field
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: _filterTopics,
        decoration: InputDecoration(
          hintText: 'Konu ara...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Builds empty state when no topics found
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Konu bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı bir arama terimi deneyebilirsiniz',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Builds animated topic list
  Widget _buildTopicList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _filteredTopics.length,
      itemBuilder: (context, index) {
        if (index >= _cardControllers.length) {
          return const SizedBox.shrink();
        }

        return _buildAnimatedTopicCard(index);
      },
    );
  }

  /// Builds individual animated topic card
  Widget _buildAnimatedTopicCard(int index) {
    final topic = _filteredTopics[index];
    final topicIcon = _getTopicIcon(topic);
    final categoryColor = _getTopicCategoryColor(topic);

    return AnimatedBuilder(
      animation: _cardControllers[index],
      builder: (context, child) {
        return SlideTransition(
          position: _buildSlideAnimation(index),
          child: FadeTransition(
            opacity: _buildFadeAnimation(index),
            child: _buildTopicCard(topic, topicIcon, categoryColor),
          ),
        );
      },
    );
  }

  /// Builds slide animation for card
  Animation<Offset> _buildSlideAnimation(int index) {
    return Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _cardControllers[index],
        curve: Curves.easeOutCubic,
      ),
    );
  }

  /// Builds fade animation for card
  Animation<double> _buildFadeAnimation(int index) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardControllers[index], curve: Curves.easeInOut),
    );
  }

  /// Builds topic card widget
  Widget _buildTopicCard(
    String topic,
    IconData topicIcon,
    Color categoryColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToStyleSelection(topic),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTopicIconContainer(topicIcon, categoryColor),
                const SizedBox(width: 16),
                _buildTopicInfo(topic),
                _buildArrowIcon(categoryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds topic icon container with gradient
  Widget _buildTopicIconContainer(IconData topicIcon, Color categoryColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [categoryColor.withOpacity(0.7), categoryColor],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(topicIcon, color: Colors.white, size: 24),
    );
  }

  /// Builds topic information column
  Widget _buildTopicInfo(String topic) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anlatım stilini seçin',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Builds arrow icon container
  Widget _buildArrowIcon(Color categoryColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.arrow_forward_ios, size: 16, color: categoryColor),
    );
  }

  /// Navigates to style selection screen
  void _navigateToStyleSelection(String topic) {
    Navigator.pushNamed(
      context,
      '/style',
      arguments: {
        'level': widget.level,
        'class': widget.className,
        'topic': topic,
        if (widget.profession != null) 'profession': widget.profession,
      },
    );
  }

  /// Returns level-specific color
  Color _getLevelColor() {
    if (widget.level == 'İlkokul') {
      return const Color(0xFFA855F7);
    } else if (widget.level == 'Ortaokul') {
      return const Color(0xFF8B5CF6);
    } else {
      return const Color(0xFF7C3AED);
    }
  }

  /// Returns icon based on topic content
  IconData _getTopicIcon(String topic) {
    final lowerTopic = topic.toLowerCase();

    if (lowerTopic.contains('matematik') || lowerTopic.contains('sayı')) {
      return Icons.calculate;
    }
    if (lowerTopic.contains('fizik') || lowerTopic.contains('hareket')) {
      return Icons.science;
    }
    if (lowerTopic.contains('kimya') || lowerTopic.contains('element')) {
      return Icons.biotech;
    }
    if (lowerTopic.contains('biyoloji') || lowerTopic.contains('hücre')) {
      return Icons.nature;
    }
    if (lowerTopic.contains('tarih') || lowerTopic.contains('savaş')) {
      return Icons.history_edu;
    }
    if (lowerTopic.contains('coğrafya') || lowerTopic.contains('harita')) {
      return Icons.public;
    }
    if (lowerTopic.contains('edebiyat') || lowerTopic.contains('şiir')) {
      return Icons.menu_book;
    }
    if (lowerTopic.contains('dil') || lowerTopic.contains('gramer')) {
      return Icons.translate;
    }
    if (lowerTopic.contains('sanat') || lowerTopic.contains('müzik')) {
      return Icons.palette;
    }
    if (lowerTopic.contains('felsefe') || lowerTopic.contains('düşünce')) {
      return Icons.psychology;
    }

    return Icons.topic;
  }

  /// Returns color based on topic category - MOR PALETİ
  Color _getTopicCategoryColor(String topic) {
    final lowerTopic = topic.toLowerCase();

    if (lowerTopic.contains('matematik')) return const Color(0xFFA855F7);
    if (lowerTopic.contains('fizik')) return const Color(0xFF8B5CF6);
    if (lowerTopic.contains('kimya')) return const Color(0xFF7C3AED);
    if (lowerTopic.contains('biyoloji')) return const Color(0xFF9333EA);
    if (lowerTopic.contains('tarih')) return const Color(0xFF6B21A8);
    if (lowerTopic.contains('coğrafya')) return const Color(0xFFA855F7);
    if (lowerTopic.contains('edebiyat')) return const Color(0xFF9333EA);
    if (lowerTopic.contains('dil')) return const Color(0xFF8B5CF6);
    if (lowerTopic.contains('sanat')) return const Color(0xFFA855F7);
    if (lowerTopic.contains('felsefe')) return const Color(0xFF7C3AED);

    return _getLevelColor();
  }
}
