// lib/screens/subject_selection_screen.dart

import 'package:flutter/material.dart';
import 'topic_selection_screen.dart';

/// Subject (Ders) selection screen
/// Shows available subjects for the selected class
class SubjectSelectionScreen extends StatelessWidget {
  final String level;
  final String className;

  const SubjectSelectionScreen({
    super.key,
    required this.level,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = _getSubjectsForClass();
    final primaryColor = _getLevelColor();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Ders Seçimi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '$level • $className',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E8FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            _buildHeaderCard(primaryColor),
            Expanded(child: _buildSubjectGrid(context, subjects, primaryColor)),
          ],
        ),
      ),
    );
  }

  /// Başlık kartı
  Widget _buildHeaderCard(Color primaryColor) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.menu_book, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hangi dersi çalışmak istiyorsun?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ders seçerek konulara ulaşabilirsin',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ders grid listesi
  Widget _buildSubjectGrid(
    BuildContext context,
    List<SubjectData> subjects,
    Color primaryColor,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(context, subjects[index]);
      },
    );
  }

  /// Ders kartı
  Widget _buildSubjectCard(BuildContext context, SubjectData subject) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: subject.colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: subject.colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToTopics(context, subject.name),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(subject.icon, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Konulara Git',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Konular ekranına git
  void _navigateToTopics(BuildContext context, String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicSelectionScreen(
          level: level,
          className: className,
          profession: subject, // Ders adını profession olarak kullan
        ),
      ),
    );
  }

  /// Seviyeye göre renk
  Color _getLevelColor() {
    if (level == 'İlkokul') {
      return const Color(0xFFA855F7);
    } else if (level == 'Ortaokul') {
      return const Color(0xFF8B5CF6);
    } else {
      return const Color(0xFF7C3AED);
    }
  }

  /// Sınıfa göre dersleri döndür
  List<SubjectData> _getSubjectsForClass() {
    // Temel dersler
    return [
      const SubjectData(
        name: 'Matematik',
        icon: Icons.calculate,
        colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
      ),
      const SubjectData(
        name: 'Türkçe',
        icon: Icons.menu_book,
        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      ),
      const SubjectData(
        name: 'Fen Bilgisi',
        icon: Icons.science,
        colors: [Color(0xFF7C3AED), Color(0xFF6B21A8)],
      ),
      const SubjectData(
        name: 'Sosyal Bilgiler',
        icon: Icons.public,
        colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      ),
      if (level != 'İlkokul') ...[
        const SubjectData(
          name: 'İngilizce',
          icon: Icons.translate,
          colors: [Color(0xFFA855F7), Color(0xFF8B5CF6)],
        ),
      ],
      if (level == 'Lise') ...[
        const SubjectData(
          name: 'Fizik',
          icon: Icons.science_outlined,
          colors: [Color(0xFF8B5CF6), Color(0xFF6B21A8)],
        ),
        const SubjectData(
          name: 'Kimya',
          icon: Icons.biotech,
          colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
        ),
        const SubjectData(
          name: 'Biyoloji',
          icon: Icons.nature,
          colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
        ),
      ],
    ];
  }
}

/// Ders verisi
class SubjectData {
  final String name;
  final IconData icon;
  final List<Color> colors;

  const SubjectData({
    required this.name,
    required this.icon,
    required this.colors,
  });
}
