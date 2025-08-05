import 'package:flutter/material.dart';

class ClassSelectionScreen extends StatelessWidget {
  final String level;

  const ClassSelectionScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // Seviyeye göre sınıf listesini oluştur
    final classes = level == 'Lise'
        ? ['9. Sınıf', '10. Sınıf', '11. Sınıf', '12. Sınıf']
        : ['1. Sınıf', '2. Sınıf', '3. Sınıf', '4. Sınıf'];

    // Sınıf ikonlarını tanımla
    final classIcons = level == 'Lise'
        ? [Icons.school, Icons.science, Icons.calculate, Icons.emoji_events]
        : [Icons.looks_one, Icons.looks_two, Icons.looks_3, Icons.looks_4];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '$level — Sınıf Seçimi',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: level == 'Lise' ? Colors.deepPurple : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: level == 'Lise'
                ? [Colors.deepPurple.shade50, Colors.white]
                : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık kartı
              Container(
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
                    Icon(
                      level == 'Lise' ? Icons.school : Icons.child_care,
                      size: 48,
                      color: level == 'Lise' ? Colors.deepPurple : Colors.blue,
                    ),
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
              ),

              const SizedBox(height: 24),

              // Sınıf listesi
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final className = classes[index];
                    final classIcon = classIcons[index];

                    return _buildClassCard(
                      context: context,
                      className: className,
                      classIcon: classIcon,
                      level: level,
                      index: index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sınıf kartı widget'ı oluşturur
  Widget _buildClassCard({
    required BuildContext context,
    required String className,
    required IconData classIcon,
    required String level,
    required int index,
  }) {
    final cardColor = level == 'Lise' ? Colors.deepPurple : Colors.blue;

    return InkWell(
      onTap: () {
        // Haptic feedback ekle
        _navigateToTopics(context, level, className);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor.shade400, cardColor.shade600],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _navigateToTopics(context, level, className),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sınıf ikonu
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(classIcon, size: 32, color: Colors.white),
                  ),

                  const SizedBox(height: 12),

                  // Sınıf adı
                  Text(
                    className,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // Alt metin
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
      ),
    );
  }

  /// Konular ekranına yönlendir
  void _navigateToTopics(BuildContext context, String level, String className) {
    Navigator.pushNamed(
      context,
      '/topic',
      arguments: {'level': level, 'class': className},
    );
  }
}
