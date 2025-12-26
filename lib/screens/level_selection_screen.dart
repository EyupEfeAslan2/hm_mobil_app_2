// lib/screens/level_selection_screen.dart - DÜZELTME VERSİYON

import 'package:flutter/material.dart';
import '../widgets/chat_box.dart';
import 'class_selection_screen.dart'; // Eklendi

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Seviye Seçimi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF6B21A8),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF3E8FF), Color(0xFFFFFFFF)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seviye seçenekleri
                    Column(
                      children: [
                        // İlkokul kartı
                        _buildLevelCard(
                          context: context,
                          title: 'İlkokul',
                          subtitle: '1-4. Sınıflar',
                          description:
                              'Temel matematik ve okuma yazma becerileri',
                          icon: Icons.child_care_rounded,
                          gradient: const [
                            Color(0xFFA855F7),
                            Color(0xFF9333EA),
                          ],
                          level: 'İlkokul',
                        ),

                        const SizedBox(height: 16),

                        // Ortaokul kartı
                        _buildLevelCard(
                          context: context,
                          title: 'Ortaokul',
                          subtitle: '5-8. Sınıflar',
                          description:
                              'Orta düzey matematik, fen ve sosyal bilimler',
                          icon: Icons.auto_stories_rounded,
                          gradient: const [
                            Color(0xFF8B5CF6),
                            Color(0xFF7C3AED),
                          ],
                          level: 'Ortaokul',
                        ),

                        const SizedBox(height: 16),

                        // Lise kartı
                        _buildLevelCard(
                          context: context,
                          title: 'Lise',
                          subtitle: '9-12. Sınıflar',
                          description:
                              'Lise müfredatına uygun ileri düzey konular',
                          icon: Icons.school_rounded,
                          gradient: const [
                            Color(0xFF7C3AED),
                            Color(0xFF6B21A8),
                          ],
                          level: 'Lise',
                        ),

                        const SizedBox(height: 16),

                        const SizedBox(height: 100), // AI butonuna yer bırak
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Yuvarlak AI Yardım butonu - sabit pozisyon
          Positioned(
            bottom: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9333EA).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => _showAIHelp(context),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI Yardım',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Seviye kartı widget'ı oluşturur
  Widget _buildLevelCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required List<Color> gradient,
    required String level,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToClassSelection(context, level),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Sol taraf - İkon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, size: 36, color: Colors.white),
                ),

                const SizedBox(width: 24),

                // Sağ taraf - Metinler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Ok ikonu
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// AI yardım diyalogu göster
  void _showAIHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'AI Yardımcı',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B21A8),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Merhaba! Size hangi konuda yardımcı olabilirim? Herhangi bir sorunuz varsa çekinmeden sorabilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const ChatBox(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Kapat',
                    style: TextStyle(
                      color: Color(0xFF9333EA),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Sınıf seçimi ekranına yönlendir
  void _navigateToClassSelection(BuildContext context, String level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassSelectionScreen(level: level),
      ),
    );
  }
}
