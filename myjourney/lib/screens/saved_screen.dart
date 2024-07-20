import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../widgets/post_card.dart';

class SavedScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Publicaciones Guardadas'),
        ),
        body: Center(
          child: Text('Por favor, inicia sesión para ver tus publicaciones guardadas.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Publicaciones Guardadas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('saved_posts')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final savedPosts = snapshot.data!.docs.map((doc) {
            return doc['postId'] as String;  
          }).toList();

          if (savedPosts.isEmpty) {
            return Center(
              child: Text('No hay publicaciones guardadas'),
            );
          }

          return FutureBuilder<List<Post>>(
            future: _fetchSavedPosts(savedPosts),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final posts = snapshot.data ?? [];

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Dismissible(
                    key: Key(post.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: AlignmentDirectional.centerEnd,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) async {
                      await _unsavePost(currentUser.uid, post.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Publicación eliminada de guardados!')),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      child: PostCard(post: post),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
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

  Future<List<Post>> _fetchSavedPosts(List<String> postIds) async {
    final postSnapshots = await Future.wait(
      postIds.map((postId) => _firestore.collection('posts').doc(postId).get())
    );

    return postSnapshots.map((snap) {
      if (snap.exists) {
        return Post.fromJson(snap.data()!);
      } else {
        return null;
      }
    }).where((post) => post != null).cast<Post>().toList();
  }
}
