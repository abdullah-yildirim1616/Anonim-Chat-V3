import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ChatPage: Ortadaki sekme — kullanıcı eşleştirme talebi gönderir
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anonim Chat")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.send),
          label: const Text("Eşleştirme Talebi Gönder"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Giriş yapılmamış.")),
              );
              return;
            }

            final requestsRef = FirebaseFirestore.instance.collection('match_requests');

            try {
              await requestsRef.doc(user.uid).set({
                'uid': user.uid,
                'timestamp': FieldValue.serverTimestamp(),
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Eşleştirme talebiniz admin onayını bekliyor.")),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Talep gönderilemedi: $e")),
              );
            }
          },
        ),
      ),
    );
  }
}

/// ChatScreen: Mesajlaşma + "Sohbeti Devam Ettir" kutucukları
class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _currentUser == null) return;

    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');

    try {
      await messagesRef.add({
        'text': text,
        'senderId': _currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mesaj gönderilemedi: $e")));
    }
  }

  // Kullanıcının "devam ettir" isteğini güncelle
  Future<void> _pressContinue(List<String> users, List<bool> continueList) async {
    final uid = _currentUser!.uid;
    final idx = users.indexOf(uid);
    if (idx == -1) return;

    // Güvenli güncelleme: eğer continueList yoksa oluştur, uzunluğu users ile eşleştir
    final newList = List<bool>.from(continueList);
    if (newList.length < users.length) {
      final fill = List<bool>.filled(users.length - newList.length, false);
      newList.addAll(fill);
    }

    newList[idx] = true;

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'continue': newList,
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Sohbet")),
        body: const Center(child: Text("Giriş yapılmamış.")),
      );
    }

    final chatDocStream = FirebaseFirestore.instance.collection('chats').doc(widget.chatId).snapshots();
    final messagesStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sohbet"),
        actions: [
          // StreamBuilder ile chat dokümanını dinleyip continue kutucuklarını gösteriyoruz
          StreamBuilder<DocumentSnapshot>(
            stream: chatDocStream,
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox(width: 48);
              final doc = snap.data!;
              final data = doc.data() as Map<String, dynamic>? ?? {};

              // users ve continue alanlarını güvenli al
              final users = <String>[];
              if (data['users'] is List) {
                try {
                  users.addAll(List<String>.from(data['users']));
                } catch (_) {}
              }

              List<bool> continueList = [];
              if (data['continue'] is List) {
                try {
                  continueList = List<bool>.from(data['continue'].map((e) => e == true));
                } catch (_) {
                  continueList = [];
                }
              }

              // Eğer users yok veya length < 2 gösterme
              if (users.isEmpty) return const SizedBox(width: 48);

              final currentIndex = users.indexOf(user.uid);
              final bothTrue = continueList.length >= users.length && continueList.take(users.length).every((v) => v == true);

              return Row(
                children: [
                  // Dikdörtgen içinde iki kutucuk
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: bothTrue ? Colors.green.shade100 : Colors.transparent,
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: List.generate(users.length, (i) {
                        final filled = i < continueList.length ? continueList[i] : false;
                        return Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: filled ? Colors.green : Colors.white,
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Buton: eğer zaten tıklamışsa disabled, değilse aktif
                  IconButton(
                    tooltip: "Sohbeti Devam Ettir",
                    icon: const Icon(Icons.repeat, color: Colors.green),
                    onPressed: (currentIndex == -1 || (continueList.length > currentIndex && continueList[currentIndex] == true))
                        ? null
                        : () => _pressContinue(users, continueList),
                  ),
                ],
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream,
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snap.data!.docs;
                if (messages.isEmpty) return const Center(child: Text("Henüz mesaj yok."));

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgDoc = messages[index];
                    final msg = msgDoc.data() as Map<String, dynamic>? ?? {};
                    final text = msg['text'] ?? '';
                    final sender = msg['senderId'] ?? msg['sender'] ?? '';
                    final isMe = sender == user.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue.shade400 : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          text.toString(),
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Mesaj yazma alanı
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: medya seçme
                    },
                    icon: const Icon(Icons.photo, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: emoji picker
                    },
                    icon: const Icon(Icons.emoji_emotions, color: Colors.blue),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Mesaj yaz...",
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
