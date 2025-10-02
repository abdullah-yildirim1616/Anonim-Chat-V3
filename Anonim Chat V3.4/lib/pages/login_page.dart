import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/home_page.dart';
import '../pages/admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _loginUser() async {
    setState(() {
      _loading = true;
    });
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Giriş başarılıysa HomePage'e yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${e.message}")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Admin giriş popup
  void _adminLogin() {
    final TextEditingController adminPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Admin Girişi"),
          content: TextField(
            controller: adminPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Admin şifresi",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (adminPasswordController.text == "123123") {
                  Navigator.pop(context); // dialogu kapat
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Yanlış şifre!")),
                  );
                }
              },
              child: const Text("Giriş"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anonim Chat Giriş"),
        actions: [
          TextButton(
            onPressed: _adminLogin,
            child: const Text(
              "Admin Girişi",
              style: TextStyle(
                color: Colors.white, // artık beyaz yazı görünür
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Şifre",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _loginUser,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Giriş Yap"),
            ),
          ],
        ),
      ),
    );
  }
}
