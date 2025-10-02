import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Giriş Yap")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Şifre"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() => _loading = true);
                String? res = await _authService.loginUser(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );
                setState(() => _loading = false);

                if (res == "success") {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res!)));
                }
              },
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Giriş Yap"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
              },
              child: const Text("Hesabın yok mu? Kayıt Ol"),
            )
          ],
        ),
      ),
    );
  }
}
