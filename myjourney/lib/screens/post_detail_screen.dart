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
  int? _currentRating;

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

  void _ratePost(int rating) {
    setState(() {
      _currentRating = rating;
    });
  }

  Future<void> _saveRating() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || _currentRating == null) return;

    List<int> newRatings = List.from(widget.post.ratings)..add(_currentRating!);
    double newAverageRating = newRatings.reduce((a, b) => a + b) / newRatings.length;

    await _firestore.collection('posts').doc(widget.post.id).update({
      'ratings': newRatings,
      'averageRating': newAverageRating,
    });

    setState(() {
      widget.post.ratings = newRatings;
      widget.post.averageRating = newAverageRating;
      _currentRating = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Puntuación guardada exitosamente!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Post'),
        backgroundColor: Colors.orange,
        actions: currentUser?.uid == widget.post.userId
            ? [
                if (widget.post.type == 'Reseña')
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
                      SnackBar(content: Text('¡Post eliminado exitosamente!')),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          color: Colors.grey[100],
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.post.title,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 10),
                _buildDetailRow(Icons.location_on, 'Ubicación', widget.post.location),
                _buildDetailRow(Icons.category, 'Categoría', widget.post.category),
                _buildDetailRow(Icons.info, 'Tipo', widget.post.type),
                _buildDetailRow(Icons.person, 'Creado por', widget.post.userName),
                if (widget.post.type == 'Actividad') ...[
                  _buildDetailRow(Icons.calendar_today, 'Fecha', widget.post.date?.toLocal().toString().split(' ')[0] ?? ''),
                  _buildDetailRow(Icons.access_time, 'Hora', widget.post.time ?? ''),
                  _buildDetailRow(Icons.monetization_on, 'Precio', '${widget.post.price}€'),
                  _buildDetailRow(Icons.place, 'Punto de Encuentro', widget.post.meetingPoint ?? ''),
                  _buildDetailRow(Icons.group, 'Capacidad', widget.post.capacity?.toString() ?? ''),
                  _buildDetailRow(Icons.event_seat, 'Plazas Disponibles', widget.post.availableSeats?.toString() ?? ''),
                ],
                SizedBox(height: 20),
                Text(widget.post.description, style: TextStyle(fontSize: 18, color: Colors.black87)),
                SizedBox(height: 20),
                if (currentUser?.uid != widget.post.userId) ...[
                  Center(
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Contactar Usuario', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isPostSaved) {
                          await _unsavePost(currentUser!.uid, widget.post.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('¡Post eliminado de guardados!')),
                          );
                        } else {
                          await _savePost(currentUser!.uid, widget.post.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('¡Post guardado exitosamente!')),
                          );
                        }
                        setState(() {
                          isPostSaved = !isPostSaved;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isPostSaved ? 'Olvidar Post' : 'Guardar Post', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  if (widget.post.type == 'Actividad')
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReserveScreen(post: widget.post),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: Icon(Icons.shopping_cart, color: Colors.white),
                      ),
                    ),
                  Center(
                    child: RatingBar(post: widget.post, onRated: _ratePost, currentRating: _currentRating),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: _buildRatingStar(widget.post.averageRating),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: _currentRating != null ? _saveRating : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Valorar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStar(double averageRating) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.star,
          color: Colors.orange,
          size: 40.0,
        ),
        Text(
          averageRating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
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

class RatingBar extends StatelessWidget {
  final Post post;
  final Function(int) onRated;
  final int? currentRating;

  RatingBar({required this.post, required this.onRated, this.currentRating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < (currentRating ?? 0)
                ? Icons.star
                : Icons.star_border,
          ),
          color: Colors.orange,
          onPressed: () => onRated(index + 1),
        );
      }),
    );
  }
}
