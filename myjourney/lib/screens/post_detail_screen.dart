import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/chat_model.dart';
import 'chat_screen.dart';
import 'edit_review_screen.dart';
import 'reserve_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  PostDetailScreen({required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isPostSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfPostIsSaved();
  }

  Future<void> _checkIfPostIsSaved() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final savedPostQuery = await _firestore.collection('saved_posts')
          .where('userId', isEqualTo: currentUser.uid)
          .where('postId', isEqualTo: widget.post.id)
          .get();
      
      if (savedPostQuery.docs.isNotEmpty) {
        setState(() {
          isPostSaved = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: currentUser?.uid == widget.post.userId
            ? [
                if (widget.post.type == 'review')
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditReviewScreen(post: widget.post),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.post.id)
                        .delete();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Post deleted successfully!')),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Title: ${widget.post.title}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Location: ${widget.post.location}'),
            Text('Category: ${widget.post.category}'),
            Text('Type: ${widget.post.type}'),
            Text('Created by: ${widget.post.userName}'),
            if (widget.post.type == 'activity') ...[
              Text('Date: ${widget.post.date?.toLocal().toString().split(' ')[0]}'),
              Text('Time: ${widget.post.time}'),
              Text('Price: ${widget.post.price}€'),
              Text('Meeting Point: ${widget.post.meetingPoint}'),
              Text('Capacity: ${widget.post.capacity}'),
              Text('Available Seats: ${widget.post.availableSeats}'), // Mostrar plazas disponibles
            ],
            SizedBox(height: 20),
            Text(widget.post.description),
            SizedBox(height: 20),
            if (currentUser?.uid != widget.post.userId) ...[
              ElevatedButton(
                onPressed: () async {
                  final chatId = await _getOrCreateChat(currentUser!.uid, widget.post.userId);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatId,
                        recipientName: widget.post.userName,
                      ),
                    ),
                  );
                },
                child: Text('Contact User'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (isPostSaved) {
                    await _unsavePost(currentUser!.uid, widget.post.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Post removed from saved!')),
                    );
                  } else {
                    await _savePost(currentUser!.uid, widget.post.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Post saved successfully!')),
                    );
                  }
                  setState(() {
                    isPostSaved = !isPostSaved;
                  });
                },
                child: Text(isPostSaved ? 'Unsave Post' : 'Save Post'),
              ),
              if (widget.post.type == 'activity')
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReserveScreen(post: widget.post),
                      ),
                    );
                  },
                  child: Icon(Icons.shopping_cart),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _savePost(String userId, String postId) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('saved_posts').add({
      'userId': userId,
      'postId': postId,
    });
  }

  Future<void> _unsavePost(String userId, String postId) async {
    final firestore = FirebaseFirestore.instance;
    final savedPostQuery = await firestore.collection('saved_posts')
        .where('userId', isEqualTo: userId)
        .where('postId', isEqualTo: postId)
        .get();
    
    for (var doc in savedPostQuery.docs) {
      await firestore.collection('saved_posts').doc(doc.id).delete();
    }
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
