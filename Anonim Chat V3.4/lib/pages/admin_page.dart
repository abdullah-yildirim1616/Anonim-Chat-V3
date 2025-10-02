import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final requestsRef = FirebaseFirestore.instance.collection('match_requests');

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestsRef.orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("Eşleştirme talebi yok."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final user1 = requests[index];
              final user2 = index + 1 < requests.length ? requests[index + 1] : null;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color: Colors.blue.shade100,
                child: ListTile(
                  title: Text(
                    "Talep: ${user1['uid']}" +
                        (user2 != null ? " ve ${user2['uid']}" : ""),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Eşleştirmek için butona basın."),
                  trailing: user2 != null
                      ? ElevatedButton(
                    onPressed: () async {
                      final chatsRef =
                      FirebaseFirestore.instance.collection('chats');

                      // Yeni chat odası aç
                      final chatDoc = chatsRef.doc();
                      await chatDoc.set({
                        'users': [user1['uid'], user2['uid']],
                        'lastMessage': '',
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Talep koleksiyonundan sil
                      await requestsRef.doc(user1.id).delete();
                      await requestsRef.doc(user2.id).delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Eşleşme oluşturuldu!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Eşleştir"),
                  )
                      : const Text(
                    "Beklemede",
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
