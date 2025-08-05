// lib/screens/style_chat_screen.dart

import 'package:flutter/material.dart';
import '../widgets/chat_box.dart';
import '../api/gemini_service.dart'; // Gemini servisinizi import edin

class StyleChatScreen extends StatefulWidget {
  final String level;
  final String className;
  final String topic;

  const StyleChatScreen({
    super.key,
    required this.level,
    required this.className,
    required this.topic,
  });

  @override
  State<StyleChatScreen> createState() => _StyleChatScreenState();
}

class _StyleChatScreenState extends State<StyleChatScreen>
    with TickerProviderStateMixin {
  final GeminiService _gemini = GeminiService();
  String? _chosenStyle;
  String? _customStyle; // Kullanıcının ChatBox'tan girdiği stil
  bool _waiting = false;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _slideController.forward();
    _askStyle();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _askStyle() async {
    setState(() => _waiting = true);
    _pulseController.repeat(reverse: true);

    try {
      final stylePrompt =
          '''
"${widget.topic}" konusu için en uygun anlatım stilini öner.

Sadece stil adını söyle, açıklama yapma. Örnekler:
- Hikaye anlatımı
- Bilimsel yaklaşım  
- Şiirsel anlatım
- Mizahi yaklaşım
- Masal tarzı
- Dramatik anlatım
- Sade açıklama

Stil:''';

      final style = await _gemini.sendChat(stylePrompt);

      if (mounted) {
        final cleanedStyle = style
            .trim()
            .replaceAll(RegExp(r'^Stil:\s*'), '')
            .replaceAll(RegExp(r'^-\s*'), '')
            .trim();

        if (cleanedStyle.isNotEmpty && cleanedStyle.length < 100) {
          setState(() {
            _chosenStyle = cleanedStyle;
          });
        } else {
          throw Exception('Geçersiz stil yanıtı');
        }
      }
    } catch (e) {
      if (mounted) {
        _showDefaultStyles();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('AI stil önerisi alınamadı. Aşağıdan seçin.'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: _askStyle,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        _pulseController.stop();
        _pulseController.reset();
        setState(() => _waiting = false);
      }
    }
  }

  void _showDefaultStyles() {
    const defaultStyles = [
      'Hikaye anlatımı',
      'Bilimsel yaklaşım',
      'Şiirsel anlatım',
      'Mizahi yaklaşım',
      'Masal tarzı',
    ];

    setState(() {
      _chosenStyle =
          defaultStyles[DateTime.now().millisecond % defaultStyles.length];
    });
  }

  void _onCustomStyleSelected(String customStyle) {
    if (customStyle.trim().isNotEmpty) {
      setState(() {
        _customStyle = customStyle.trim();
        _chosenStyle = customStyle.trim();
      });
    }
  }

  void _continue() {
    final finalStyle = _customStyle?.isNotEmpty == true
        ? _customStyle!
        : _chosenStyle;

    if (finalStyle == null || finalStyle.isEmpty) {
      _showStyleRequiredDialog();
      return;
    }

    if (finalStyle.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen daha açıklayıcı bir stil belirtin.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // **ÖNEMLİ:** Gerekli tüm parametreler /narration rotasına gönderiliyor.
    Navigator.pushNamed(
      context,
      '/narration',
      arguments: {
        'topic': widget.topic,
        'style': finalStyle,
        'level': widget.level,
        'className': widget.className,
      },
    );
  }

  void _showStyleRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Stil Gerekli'),
          ],
        ),
        content: const Text(
          'Kaliteli bir anlatım için lütfen önce bir anlatım stili seçin veya belirtin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  MaterialColor _getStyleColor(String? style) {
    if (style == null) return Colors.indigo;
    final lowerStyle = style.toLowerCase();
    if (lowerStyle.contains('hikaye')) return Colors.purple;
    if (lowerStyle.contains('şiir')) return Colors.pink;
    if (lowerStyle.contains('bilimsel')) return Colors.blue;
    if (lowerStyle.contains('komedi') || lowerStyle.contains('mizah'))
      return Colors.orange;
    if (lowerStyle.contains('masal')) return Colors.green;
    if (lowerStyle.contains('drama')) return Colors.red;
    return Colors.indigo;
  }

  IconData _getStyleIcon(String? style) {
    if (style == null) return Icons.auto_awesome;
    final lowerStyle = style.toLowerCase();
    if (lowerStyle.contains('hikaye')) return Icons.auto_stories;
    if (lowerStyle.contains('şiir')) return Icons.lyrics;
    if (lowerStyle.contains('bilimsel')) return Icons.science;
    if (lowerStyle.contains('komedi') || lowerStyle.contains('mizah'))
      return Icons.sentiment_very_satisfied;
    if (lowerStyle.contains('masal')) return Icons.castle;
    if (lowerStyle.contains('drama')) return Icons.theater_comedy;
    return Icons.auto_awesome;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Anlatım Stili Belirleniyor',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Üst bölüm - AI Önerisi
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            _buildTopicChip(),
                            const SizedBox(height: 20),
                            _buildAiSuggestionSection(),
                          ],
                        ),
                      ),
                      if (_chosenStyle != null && !_waiting) ...[
                        const SizedBox(height: 16),
                        _buildDivider(),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Alt bölüm - ChatBox
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ChatBox(onStyleSelected: _onCustomStyleSelected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.topic, size: 20, color: Colors.indigo),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.topic,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'veya kendi stilinizi belirtin',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildAiSuggestionSection() {
    if (_waiting) {
      return Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) =>
                Transform.scale(scale: _pulseAnimation.value, child: child),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade300, Colors.indigo.shade500],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI Stil Öneriyor...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Size en uygun anlatım stilini belirliyoruz',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_chosenStyle != null && _chosenStyle!.isNotEmpty) {
      final styleColor = _getStyleColor(_chosenStyle);
      final styleIcon = _getStyleIcon(_chosenStyle);

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [styleColor.shade300, styleColor.shade500],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(styleIcon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: styleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: styleColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.smart_toy, color: styleColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AI Önerisi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: styleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '"$_chosenStyle"',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildContinueButton(),
        ],
      );
    }

    return Column(
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
        const SizedBox(height: 16),
        Text(
          'Stil önerisi alınamadı',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _askStyle,
          icon: const Icon(Icons.refresh),
          label: const Text('Tekrar Dene'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    final hasValidStyle =
        (_chosenStyle?.isNotEmpty ?? false) ||
        (_customStyle?.isNotEmpty ?? false);
    final finalStyle = _customStyle?.isNotEmpty == true
        ? _customStyle!
        : _chosenStyle;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: hasValidStyle ? _continue : null,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(
          hasValidStyle ? 'Bu Stille Anlatımı Başlat' : 'Önce Stil Seçin',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasValidStyle
              ? _getStyleColor(finalStyle)
              : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: hasValidStyle ? 4 : 0,
          shadowColor: hasValidStyle
              ? _getStyleColor(finalStyle).withOpacity(0.4)
              : null,
        ),
      ),
    );
  }
}
