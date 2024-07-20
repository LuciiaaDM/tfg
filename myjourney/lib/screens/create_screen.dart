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
        backgroundColor: Colors.orange,
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
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  _buildDropdown(
                    labelText: 'Seleccionar Tipo',
                    value: _selectedType,
                    items: <String>['Reseña', 'Actividad'],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                  ),
                  _buildDropdown(
                    labelText: 'Seleccionar Categoría',
                    value: _selectedCategory,
                    items: <String>['Restaurante', 'Mirador', 'Museo', 'Sitio Histórico'],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                  _buildTextField(
                    hintText: 'Título',
                    onChanged: (value) => title = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese un título';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    hintText: 'Ubicación',
                    onChanged: (value) => location = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese una ubicación';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    hintText: 'Descripción',
                    onChanged: (value) => description = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese una descripción';
                      }
                      return null;
                    },
                    maxLines: 5,
                  ),
                  if (_selectedType == 'Actividad') ...[
                    _buildTextField(
                      hintText: 'Fecha (YYYY-MM-DD)',
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
                    _buildTextField(
                      hintText: 'Precio',
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
                    _buildTextField(
                      hintText: 'Punto de Encuentro',
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
                    _buildTextField(
                      hintText: 'Capacidad',
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
                    _buildTextField(
                      hintText: 'Hora (HH:MM)',
                      controller: _timeController,
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese una hora';
                        }
                        return null;
                      },
                    ),
                  ],
                  SizedBox(height: 20.0),
                  Center(
                    child: ElevatedButton(
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
                              SnackBar(content: Text('¡Creación Exitosa!')),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String labelText,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.orange),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: onChanged,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
}
