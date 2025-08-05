// lib/widgets/chat_box.dart - BASIT VE ETKİLİ OVERFLOW DÜZELTMESI

import 'package:flutter/material.dart';
import '../api/gemini_service.dart';

class ChatBox extends StatefulWidget {
  final Function(String)? onStyleSelected;

  const ChatBox({super.key, this.onStyleSelected});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _geminiService = GeminiService();
  final _focusNode = FocusNode();

  String _reply = '';
  String _userMessage = '';
  bool _isLoading = false;
  bool _isExpanded = false;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animasyon kontrolcüleri
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Mesaj gönder
  Future<void> _sendMessage() async {
    final question = _textController.text.trim();
    if (question.isEmpty || _isLoading) return;

    // Keyboard'ı kapat
    _focusNode.unfocus();

    setState(() {
      _isLoading = true;
      _userMessage = question;
      _reply = '';
      _isExpanded = true;
    });

    // Input'u temizle
    _textController.clear();

    // Pulse animasyonunu başlat
    _pulseController.repeat(reverse: true);
    _slideController.forward();

    // Stil önerisi callback'ini çağır
    if (widget.onStyleSelected != null) {
      widget.onStyleSelected!(question);
    }

    try {
      // AI'ya stil belirleme konusunda yardım etmesini söyle
      final stylePrompt =
          '''
Kullanıcı anlatım stili için şunu belirtti: "$question"

Bu isteğe göre en uygun anlatım stilini öner. Sadece stil adını söyle, açıklama yapma.

Örnekler:
- Hikaye anlatımı
- Bilimsel yaklaşım
- Şiirsel anlatım
- Mizahi yaklaşım
- Masal tarzı
- Dramatik anlatım
- Sade açıklama

Eğer kullanıcının isteği belirsizse, ona nasıl stil belirleyebileceği konusunda kısa bir öneri ver.

Yanıt:''';

      final response = await _geminiService.sendChat(stylePrompt);

      if (mounted) {
        setState(() {
          _reply = response;
        });

        // Eğer cevap bir stil önerisi gibi görünüyorsa, callback'i tekrar çağır
        if (_isValidStyleResponse(response)) {
          final cleanedStyle = _extractStyleFromResponse(response);
          if (cleanedStyle.isNotEmpty && widget.onStyleSelected != null) {
            widget.onStyleSelected!(cleanedStyle);
          }
        }

        // Otomatik scroll
        _scrollToBottom();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _reply = 'Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.';
        });

        // Error snackbar
        _showErrorSnackBar(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  /// Yanıtın geçerli bir stil önerisi olup olmadığını kontrol et
  bool _isValidStyleResponse(String response) {
    final lowerResponse = response.toLowerCase();
    final styleKeywords = [
      'hikaye',
      'bilimsel',
      'şiir',
      'mizah',
      'masal',
      'drama',
      'sade',
      'anlatım',
      'yaklaşım',
      'tarz',
      'stil',
    ];

    return styleKeywords.any((keyword) => lowerResponse.contains(keyword)) &&
        response.length < 200; // Çok uzun olmasın
  }

  /// Yanıttan stil adını çıkar
  String _extractStyleFromResponse(String response) {
    // Basit temizleme
    String cleaned = response
        .trim()
        .replaceAll(RegExp(r'^Yanıt:\s*'), '')
        .replaceAll(RegExp(r'^-\s*'), '')
        .split('\n')
        .first // İlk satırı al
        .trim();

    // Eğer çok uzunsa, ilk kısmını al
    if (cleaned.length > 50) {
      cleaned = cleaned.split('.').first.trim();
    }

    return cleaned;
  }

  /// Scroll to bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Error snackbar göster
  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Bağlantı hatası oluştu',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Tekrar Dene',
          textColor: Colors.white,
          onPressed: _sendMessage,
        ),
      ),
    );
  }

  /// ChatBox'ı kapat/aç
  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ ÖNEMLİ: min boyut kullan
        children: [
          // Başlık çubuğu
          _buildHeader(),

          // Yanıt alanı (sadece expand olduğunda)
          if (_isExpanded) _buildResponseArea(),

          // Input alanı
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Başlık çubuğu
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.smart_toy, color: Colors.indigo, size: 20),
          const SizedBox(width: 8),
          Text(
            'AI Asistan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.indigo,
            ),
          ),
          const Spacer(),
          if (_reply.isNotEmpty || _isLoading)
            IconButton(
              icon: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: Colors.indigo,
                size: 20,
              ),
              onPressed: _toggleExpansion,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  /// ✅ OVERFLOW SORUNU ÇÖZÜLDİ - Sabit boyut yerine LimitedBox
  Widget _buildResponseArea() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: LimitedBox(
        // ✅ FIX: LimitedBox kullan
        maxHeight: 180, // Maksimum yükseklik
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? _buildLoadingWidget()
              : _reply.isNotEmpty
              ? _buildReplyWidget()
              : _buildEmptyStateWidget(),
        ),
      ),
    );
  }

  /// Loading widget
  Widget _buildLoadingWidget() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            'AI düşünüyor...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Reply widget - OVERFLOW SORUNU ÇÖZÜLDİ
  Widget _buildReplyWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity, // ✅ FIX: Full height kullan (LimitedBox içinde)
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SelectableText(
          _reply,
          style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey[800]),
        ),
      ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Sorunuzu yazın, size yardımcı olayım!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Input alanı
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Nasıl bir anlatım stili istiyorsunuz?',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isLoading
                      ? [Colors.grey.shade300, Colors.grey.shade400]
                      : [Colors.indigo.shade400, Colors.indigo.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _isLoading ? null : _sendMessage,
                tooltip: 'Gönder',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
