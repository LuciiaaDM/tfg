import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;

  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[100],
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildRatingStar(post.averageRating),
              ],
            ),
            SizedBox(height: 5.0),
            Text('Ubicación: ${post.location}'),
            Text('Categoría: ${_capitalize(post.category)}'),
            Text('Tipo: ${_capitalize(post.type)}'),
            Text('Creado por: ${post.userName}'),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/postDetail',
                  arguments: post,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Ver Detalles'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStar(double averageRating) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
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

  String _capitalize(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }
}
