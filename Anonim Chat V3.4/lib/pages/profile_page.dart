// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // giriş sayfası

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Çıkış fonksiyonu build dışında olmalı
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build metodu sınıfın içinde ama _signOut dışında
    return Scaffold(
      appBar: AppBar(title: const Text("Profilim")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade100,
              child: ListTile(
                leading: const Icon(Icons.person, size: 40, color: Colors.blue),
                title: const Text("Ad Soyad"),
                subtitle: const Text("Kullanıcı ID"),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Email: user@email.com"),
            const Text("Telefon: 05xx xxx xx xx"),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _signOut(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Çıkış Yap"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
