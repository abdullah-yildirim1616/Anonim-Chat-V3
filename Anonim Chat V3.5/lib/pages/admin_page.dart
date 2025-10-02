import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/login_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsStream = FirebaseFirestore.instance.collection("requests").snapshots();
    final usersStream = FirebaseFirestore.instance.collection("users").snapshots();
    final matchesStream = FirebaseFirestore.instance.collection("matches").snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Paneli"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => signOut(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Talepler
            StreamBuilder<QuerySnapshot>(
              stream: requestsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                return ExpansionTile(
                  title: const Text("Eşleşme Talepleri"),
                  children: docs.map((d) => ListTile(title: Text(d.id))).toList(),
                );
              },
            ),

            // Eşleşmemiş kullanıcılar
            StreamBuilder<QuerySnapshot>(
              stream: usersStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                return ExpansionTile(
                  title: const Text("Eşleşmemiş Kullanıcılar"),
                  children: docs.map((d) {
                    final matched = d["matched"] ?? false;
                    if (!matched) {
                      return ListTile(title: Text(d.id));
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                );
              },
            ),

            // Eşleşmiş kullanıcılar
            StreamBuilder<QuerySnapshot>(
              stream: matchesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                return ExpansionTile(
                  title: const Text("Eşleşmiş Kullanıcılar"),
                  children: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final u1 = data["user1"];
                    final u2 = data["user2"];
                    return ListTile(title: Text("$u1 - $u2"));
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
