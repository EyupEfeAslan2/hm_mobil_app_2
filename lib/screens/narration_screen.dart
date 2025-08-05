// lib/screens/narration_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Panoya kopyalama için
import '../api/gemini_service.dart'; // Gemini servisinizi import edin

class NarrationScreen extends StatefulWidget {
  final String topic;
  final String style;
  final String level;
  final String className;

  const NarrationScreen({
    super.key,
    required this.topic,
    required this.style,
    required this.level,
    required this.className,
  });

  @override
  State<NarrationScreen> createState() => _NarrationScreenState();
}

class _NarrationScreenState extends State<NarrationScreen> {
  final GeminiService _gemini = GeminiService();
  late Future<String> _narrationFuture;

  @override
  void initState() {
    super.initState();
    _narrationFuture = _generateNarration();
  }

  Future<String> _generateNarration() async {
    final prompt =
        '''
Sen, her seviyeden öğrenciye hitap edebilen bir yapay zeka öğretmenisin.
Aşağıdaki bilgilere göre bir anlatım hazırla:

Ders: "${widget.className}"
Seviye: "${widget.level}"
Konu: "${widget.topic}"
Anlatım Stili: "${widget.style}"

Lütfen bu bilgilere sadık kalarak, konuyu belirtilen stilde açıkla. 
Anlatımını başlıklar ve paragraflar halinde, akıcı ve anlaşılır bir dilde sun.
''';

    try {
      final narration = await _gemini.sendChat(prompt);
      if (narration.trim().isEmpty) {
        throw Exception('Oluşturulan anlatım boş.');
      }
      return narration.trim();
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      return 'Anlatım oluşturulurken bir hata oluştu. Lütfen geri dönüp tekrar deneyin.\n\nHata Detayı: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic),
        actions: [
          FutureBuilder<String>(
            future: _narrationFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  !snapshot.data!.startsWith('Anlatım oluşturulurken')) {
                return IconButton(
                  icon: const Icon(Icons.copy_all_outlined),
                  tooltip: 'Panoya Kopyala',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: snapshot.data!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anlatım panoya kopyalandı!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _narrationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Harika bir anlatım hazırlanıyor...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasError ||
              (snapshot.hasData &&
                  snapshot.data!.startsWith('Anlatım oluşturulurken'))) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Anlatım Oluşturulamadı',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      snapshot.hasError
                          ? snapshot.error.toString()
                          : snapshot.data!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _narrationFuture = _generateNarration();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            // **RENDERFLEX HATASINI ÇÖZEN YAPI**
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                snapshot.data!,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
            );
          }
          return const Center(child: Text('Bir şeyler ters gitti.'));
        },
      ),
    );
  }
}
