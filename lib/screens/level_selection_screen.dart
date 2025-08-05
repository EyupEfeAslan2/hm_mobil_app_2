// lib/screens/level_selection_screen.dart - OVERFLOW SORUNU ÇÖZÜLDİ

import 'package:flutter/material.dart';
import '../widgets/chat_box.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // ✅ FIX 1: Keyboard gelince resize etme
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Seviye Seçimi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      // ✅ FIX 2: SingleChildScrollView ile sar
      body: SingleChildScrollView(
        child: Container(
          // ✅ FIX 3: Minimum yükseklik belirle
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.indigo.shade50, Colors.white],
            ),
          ),
          child: Column(
            children: [
              // ✅ FIX 4: Ana içerik - Expanded kaldırıldı
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hoş geldin kartı
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Ana ikon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.indigo.shade400,
                                  Colors.indigo.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.school_outlined,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Hoş Geldin!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Öğrenim seviyeni seçerek başlayalım',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ✅ FIX 5: Seviye seçenekleri - Expanded kaldırıldı
                    Column(
                      children: [
                        // Lise kartı
                        _buildLevelCard(
                          context: context,
                          title: 'Lise',
                          subtitle: '9-12. Sınıflar',
                          description: 'Lise müfredatına uygun konular',
                          icon: Icons.school,
                          gradient: [
                            Colors.deepPurple.shade400,
                            Colors.deepPurple.shade600,
                          ],
                          level: 'Lise',
                        ),

                        const SizedBox(height: 20),

                        // Üniversite kartı
                        _buildLevelCard(
                          context: context,
                          title: 'Üniversite',
                          subtitle: '1-4. Sınıflar',
                          description: 'Üniversite düzeyinde konular',
                          icon: Icons.account_balance,
                          gradient: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                          ],
                          level: 'Üniversite',
                        ),

                        // ✅ FIX 6: ChatBox için boşluk ekle
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),

              // ✅ FIX 7: Alt bölüm - ChatBox (artık overflow olmayacak)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ Önemli: min boyut
                  children: [
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.grey.shade300,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ChatBox(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToClassSelection(context, level),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Sol taraf - İkon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, size: 36, color: Colors.white),
                ),

                const SizedBox(width: 20),

                // Sağ taraf - Metinler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Ok ikonu
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sınıf seçimi ekranına yönlendir
  void _navigateToClassSelection(BuildContext context, String level) {
    Navigator.pushNamed(context, '/class', arguments: {'level': level});
  }
}
