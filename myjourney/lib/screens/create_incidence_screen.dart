import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateIncidenceScreen extends StatefulWidget {
  @override
  _CreateIncidenceScreenState createState() => _CreateIncidenceScreenState();
}

class _CreateIncidenceScreenState extends State<CreateIncidenceScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'App'; 
  late String description;
  late String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Incidencia'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: <String>['App', 'Usuario'].map((String value) {
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
              if (_selectedCategory == 'Usuario') ...[
                TextFormField(
                  decoration: InputDecoration(hintText: 'ID de Usuario'),
                  onChanged: (value) {
                    userId = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el ID del usuario';
                    }
                    return null;
                  },
                ),
              ],
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

                      final incidenceId = _firestore.collection('incidences').doc().id;

                      await _firestore.collection('incidences').doc(incidenceId).set({
                        'id': incidenceId,
                        'category': _selectedCategory,
                        'description': description,
                        'reportedBy': user.email, 
                        'userId': _selectedCategory == 'Usuario' ? userId : null,
                        'status': 'Creada',
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('¡Incidencia creada con éxito!')),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear la incidencia: $e')),
                      );
                      print(e);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, 
                  foregroundColor: Colors.white, 
                ),
                child: Text('Crear Incidencia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
