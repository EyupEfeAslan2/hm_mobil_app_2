import 'package:flutter/material.dart';
import '../data/content_data.dart';

class TopicSelectionScreen extends StatefulWidget {
  final String level;
  final String className;

  const TopicSelectionScreen({
    super.key,
    required this.level,
    required this.className,
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

  @override
  void initState() {
    super.initState();

    // Konuları yükle
    _allTopics = contentData[widget.level]?[widget.className] ?? [];
    _filteredTopics = List.from(_allTopics);

    // Stagger animasyon kontrolcüsü
    _staggerController = AnimationController(
      duration: Duration(milliseconds: 600 + (_filteredTopics.length * 100)),
      vsync: this,
    );

    // Her kart için animasyon kontrolcüsü oluştur
    _initializeCardControllers();

    // Animasyonu başlat
    _staggerController.forward();
  }

  void _initializeCardControllers() {
    // Mevcut kontrolcüleri temizle
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    _cardControllers.clear();

    // Yeni kontrolcüler oluştur
    for (int i = 0; i < _filteredTopics.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      _cardControllers.add(controller);

      // Staggered animasyon
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Konu filtreleme
  void _filterTopics(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTopics = List.from(_allTopics);
      } else {
        _filteredTopics = _allTopics
            .where((topic) => topic.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });

    _initializeCardControllers();
  }

  /// Seviye rengini belirle
  MaterialColor _getLevelColor() {
    return widget.level == 'Lise' ? Colors.deepPurple : Colors.blue;
  }

  /// Konu kategorisini belirle (konuya göre ikon seçimi için)
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

    return Icons.topic; // Varsayılan ikon
  }

  /// Konu kategorisi rengini belirle
  MaterialColor _getTopicCategoryColor(String topic) {
    final lowerTopic = topic.toLowerCase();

    if (lowerTopic.contains('matematik')) return Colors.orange;
    if (lowerTopic.contains('fizik')) return Colors.blue;
    if (lowerTopic.contains('kimya')) return Colors.green;
    if (lowerTopic.contains('biyoloji')) return Colors.teal;
    if (lowerTopic.contains('tarih')) return Colors.brown;
    if (lowerTopic.contains('coğrafya')) return Colors.indigo;
    if (lowerTopic.contains('edebiyat')) return Colors.purple;
    if (lowerTopic.contains('dil')) return Colors.pink;
    if (lowerTopic.contains('sanat')) return Colors.deepOrange;
    if (lowerTopic.contains('felsefe')) return Colors.grey;

    return _getLevelColor(); // Varsayılan renk
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konu Seçimi',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${widget.level} • ${widget.className}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: levelColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [levelColor.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Üst bilgi kartı
            Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: levelColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.level == 'Lise'
                              ? Icons.school
                              : Icons.account_balance,
                          color: levelColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Arama kutusu
                  Container(
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
                  ),
                ],
              ),
            ),

            // Konu listesi
            Expanded(
              child: _filteredTopics.isEmpty
                  ? _buildEmptyState()
                  : _buildTopicList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Boş durum widget'ı
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

  /// Konu listesi widget'ı
  Widget _buildTopicList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _filteredTopics.length,
      itemBuilder: (context, index) {
        if (index >= _cardControllers.length) return const SizedBox.shrink();

        final topic = _filteredTopics[index];
        final topicIcon = _getTopicIcon(topic);
        final categoryColor = _getTopicCategoryColor(topic);

        return AnimatedBuilder(
          animation: _cardControllers[index],
          builder: (context, child) {
            final slideAnimation =
                Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _cardControllers[index],
                    curve: Curves.easeOutCubic,
                  ),
                );

            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _cardControllers[index],
                curve: Curves.easeInOut,
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Container(
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
                      onTap: () => _navigateToStyle(topic),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Sol taraf - İkon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    categoryColor.shade300,
                                    categoryColor.shade500,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                topicIcon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Orta - Konu adı
                            Expanded(
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
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Sağ taraf - Ok ikonu
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Stil seçimi ekranına yönlendir
  void _navigateToStyle(String topic) {
    Navigator.pushNamed(
      context,
      '/style',
      arguments: {
        'level': widget.level,
        'class': widget.className,
        'topic': topic,
      },
    );
  }
}
