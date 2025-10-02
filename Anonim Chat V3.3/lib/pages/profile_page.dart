import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
