import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedType = 'Reseña'; 
  String _selectedCategory = 'Restaurante';

  // comunes
  late String title;
  late String location;
  late String description;

  // campos actividades
  DateTime? date;
  double? price;
  String? meetingPoint;
  int? capacity;
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  Future<String> _getUserName(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc['username'] ?? 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Actividad o Reseña'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: <String>['Reseña', 'Actividad'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Seleccionar Tipo',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: <String>['Restaurante', 'Mirador', 'Museo', 'Sitio Histórico'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Seleccionar Categoría',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Título'),
                onChanged: (value) {
                  title = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un título';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Ubicación'),
                onChanged: (value) {
                  location = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una ubicación';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Descripción'),
                onChanged: (value) {
                  description = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una descripción';
                  }
                  return null;
                },
                maxLines: 5, 
              ),
              if (_selectedType == 'Actividad') ...[
                TextFormField(
                  decoration: InputDecoration(hintText: 'Fecha (YYYY-MM-DD)'),
                  onChanged: (value) {
                    date = DateTime.parse(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese una fecha';
                    }
                    try {
                      DateTime.parse(value);
                    } catch (e) {
                      return 'Por favor, ingrese una fecha válida';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Precio'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    price = double.parse(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un precio';
                    }
                    try {
                      double.parse(value);
                    } catch (e) {
                      return 'Por favor, ingrese un precio válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Punto de Encuentro'),
                  onChanged: (value) {
                    meetingPoint = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un punto de encuentro';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Capacidad'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    capacity = int.parse(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese una capacidad';
                    }
                    try {
                      int.parse(value);
                    } catch (e) {
                      return 'Por favor, ingrese una capacidad válida';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Hora (HH:MM)'),
                  controller: _timeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese una hora';
                    }
                    return null;
                  },
                ),
              ],
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final user = _auth.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ningún usuario ha iniciado sesión')),
                        );
                        return;
                      }

                      final postId = _firestore.collection('posts').doc().id;
                      final userName = await _getUserName(user.uid); 

                      if (_selectedType == 'Actividad') {
                        Post activity = Post.activity(
                          id: postId,
                          title: title,
                          location: location,
                          description: description,
                          userId: user.uid,
                          userName: userName, 
                          date: date!,
                          price: price!,
                          meetingPoint: meetingPoint!,
                          capacity: capacity!,
                          time: _timeController.text,
                          category: _selectedCategory,
                          availableSeats: capacity!,
                        );

                        await _firestore.collection('posts').doc(postId).set(activity.toJson());
                      } else {
                        Post review = Post.review(
                          id: postId,
                          title: title,
                          location: location,
                          description: description,
                          userId: user.uid,
                          userName: userName,
                          category: _selectedCategory,
                        );

                        await _firestore.collection('posts').doc(postId).set(review.toJson());
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('¡Creación Exitosa!'))
                      );

                      Navigator.pushReplacementNamed(context, '/home');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear: $e')),
                      );
                      print(e);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, 
                  foregroundColor: Colors.white, 
                ),
                child: Text('Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
