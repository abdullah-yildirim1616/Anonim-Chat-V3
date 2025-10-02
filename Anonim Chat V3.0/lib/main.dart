import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anonim Chat',
      home: Scaffold(
        appBar: AppBar(title: const Text("Anonim Chat")),
        body: const Center(child: Text("Firebase bağlantısı başarılı!")),
      ),
    );
  }
}
