import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  Future<String?> registerUser({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String userId,
  }) async {
    try {
      // Firebase Auth ile kullanıcı oluştur
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Firestore'a kullanıcı bilgilerini kaydet
        await _firestore.collection("users").doc(user.uid).set({
          "firstName": firstName,
          "lastName": lastName,
          "phone": phone,
          "email": email,
          "userId": userId,
          "verified": false,
        });

        // Doğrulama maili gönder
        try {
          //await user.sendEmailVerification();
          print("Doğrulama maili gönderildi!");
        } catch (e) {
          print("Mail gönderilemedi: $e");
        }

        return "success";
      }
      return "Kullanıcı oluşturulamadı";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Login User
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        if (user != null) {
          return "success";
        }

      }
      return "Kullanıcı bulunamadı";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
