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

  String _selectedCategory = 'App'; // Por defecto seleccionamos App
  late String description;
  late String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Incidence'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: <String>['App', 'User'].map((String value) {
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
                  labelText: 'Select Category',
                ),
              ),
              if (_selectedCategory == 'User') ...[
                TextFormField(
                  decoration: InputDecoration(hintText: 'User ID'),
                  onChanged: (value) {
                    userId = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a user ID';
                    }
                    return null;
                  },
                ),
              ],
              TextFormField(
                decoration: InputDecoration(hintText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
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
                          SnackBar(content: Text('No user is logged in')),
                        );
                        return;
                      }

                      final incidenceId = _firestore.collection('incidences').doc().id;

                      await _firestore.collection('incidences').doc(incidenceId).set({
                        'id': incidenceId,
                        'category': _selectedCategory,
                        'description': description,
                        'reportedBy': user.email, // Usa el email del usuario como nombre
                        'userId': _selectedCategory == 'User' ? userId : null,
                        'status': 'Created',
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Incidence Created Successfully!')),
                      );

                      Navigator.pop(context); // Regresa a la pantalla de configuración después de crear
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create incidence: $e')),
                      );
                      print(e);
                    }
                  }
                },
                child: Text('Create Incidence'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
