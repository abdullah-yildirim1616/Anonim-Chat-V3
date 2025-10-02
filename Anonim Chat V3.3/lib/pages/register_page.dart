import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: "Ad")),
              TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: "Soyad")),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: "Telefon")),
              TextFormField(controller: _userIdController, decoration: const InputDecoration(labelText: "Kullanıcı ID")),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
              TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: "Şifre"), obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() => _loading = true);

                  // Form validation
                  if (_firstNameController.text.isEmpty ||
                      _lastNameController.text.isEmpty ||
                      _phoneController.text.isEmpty ||
                      _emailController.text.isEmpty ||
                      _passwordController.text.isEmpty ||
                      _userIdController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lütfen tüm alanları doldurun!"))
                    );
                    setState(() => _loading = false);
                    return;
                  }

                  // Kayıt işlemi
                  String? res = await _authService.registerUser(
                    firstName: _firstNameController.text.trim(),
                    lastName: _lastNameController.text.trim(),
                    phone: _phoneController.text.trim(),
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                    userId: _userIdController.text.trim(),
                  );

                  setState(() => _loading = false);

                  // Sonuç
                  if (res == "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Kayıt başarılı! Mailinizi doğrulayın."))
                    );
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage())
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res!))
                    );
                  }
                },
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Kayıt Ol"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
