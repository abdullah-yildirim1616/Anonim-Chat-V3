import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/chat_page.dart';
import '../pages/chats_page.dart';
import '../pages/profile_page.dart';
import '../pages/admin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1; // Chat sayfasını ana sayfa yapıyoruz

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ChatsPage(), // Sol sekme: önceki sohbetler
      const ChatPage(),  // Ortada: eşleştirme talebi / chat ekranı
      const ProfilePage(), // Sağ sekme: profil bilgileri
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anonim Chat"),
        actions: [
          // Admin login butonu
          TextButton(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();
                  return AlertDialog(
                    title: const Text("Admin Girişi"),
                    content: TextField(
                      controller: controller,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: "Şifre giriniz"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(controller.text),
                        child: const Text("Giriş"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: const Text("İptal"),
                      ),
                    ],
                  );
                },
              );

              if (result == "1") {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminPage()),
                );
              } else if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hatalı şifre")),
                );
              }
            },
            child: const Text("Admin", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.blue.shade600,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Sohbetler",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
