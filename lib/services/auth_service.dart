// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcıyı getir
  User? get currentUser => _auth.currentUser;

  // Kullanıcı durumunu dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // MİSAFİR GİRİŞİ
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;

      if (user != null) {
        await _updateUserData(user);
      }
      return user;
    } catch (e) {
      debugPrint("Anonim giriş hatası: $e");
      return null;
    }
  }

  // Firestore'a veri yaz
  Future<void> _updateUserData(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);

    await userRef.set({
      'uid': user.uid,
      'lastActive': FieldValue.serverTimestamp(),
      'role': 'student',
      'platform': defaultTargetPlatform.toString(),
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
