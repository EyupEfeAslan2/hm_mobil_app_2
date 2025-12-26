// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Turn 4'te oluşturduğumuz servis
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  // Eğer kullanıcı daha önce girdiyse direkt içeri al
  void _checkCurrentUser() {
    if (_authService.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/'); // Ana Sayfaya git
      });
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    // Servis üzerinden anonim giriş yap
    User? user = await _authService.signInAnonymously();

    if (mounted) {
      setState(() => _isLoading = false);
      if (user != null) {
        // Başarılı ise Ana Sayfaya yönlendir
        Navigator.pushReplacementNamed(context, '/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş yapılırken bir hata oluştu.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ÜST KISIM: LOGO VE METİN
              Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo Alanı (Şimdilik İkon)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_stories, // Kitap/Eğitim ikonu
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "HM Integral",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Yapay zeka destekli kişisel öğrenme asistanınla tanış. Konuları hikayeleştirerek öğren.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),

              // ALT KISIM: BUTONLAR
              Column(
                children: [
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleGuestLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Hemen Başla",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // İleride Google Login eklenecek
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Google Girişi Yakında!")),
                      );
                    },
                    child: const Text(
                      "Zaten hesabın var mı? Giriş Yap",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
