import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;

  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[100], // Cambia el color de fondo a naranja claro
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              post.title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
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
                backgroundColor: Colors.orange, // Cambia el color del botón a naranja
                foregroundColor: Colors.white, // Cambia el color del texto del botón a blanco
              ),
              child: Text('Ver Detalles'),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }
}
