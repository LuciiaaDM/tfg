import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/chat_model.dart';
import 'chat_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  PostDetailScreen({required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Title: ${post.title}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Location: ${post.location}'),
            Text('Category: ${post.category}'),
            Text('Type: ${post.type}'),
            Text('Created by: ${post.userName}'),
            SizedBox(height: 20),
            if (currentUser?.uid != post.userId)  // Asegúrate de que el usuario actual no puede contactar consigo mismo
              ElevatedButton(
                onPressed: () async {
                  // Obtén o crea el chat
                  final chatId = await _getOrCreateChat(currentUser!.uid, post.userId);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatId,
                        recipientName: post.userName, // Asegúrate de pasar el nombre de usuario
                      ),
                    ),
                  );
                },
                child: Text('Contact User'),
              ),
          ],
        ),
      ),
    );
  }

  Future<String> _getOrCreateChat(String currentUserId, String otherUserId) async {
    final firestore = FirebaseFirestore.instance;
    final chatCollection = firestore.collection('chats');

    final chatQuery = await chatCollection
      .where('participants', arrayContains: currentUserId)
      .get();

    for (var doc in chatQuery.docs) {
      final chat = Chat.fromJson(doc.data() as Map<String, dynamic>);
      if (chat.participants.contains(otherUserId)) {
        return chat.id;
      }
    }

    final newChatDoc = chatCollection.doc();
    await newChatDoc.set({
      'id': newChatDoc.id,
      'participants': [currentUserId, otherUserId],
    });

    return newChatDoc.id;
  }
}
