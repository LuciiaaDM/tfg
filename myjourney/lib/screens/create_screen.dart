import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedType = 'Review'; // Por defecto seleccionamos review
  String _selectedCategory = 'restaurant'; // Por defecto seleccionamos restaurant

  // Campos comunes
  late String title;
  late String location;
  late String description;

  // Campos adicionales para actividades
  DateTime? date;
  double? price;
  String? meetingPoint;
  int? capacity;
  TimeOfDay? time; // Hora para actividades

  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Activity or Review'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: <String>['Review', 'Activity'].map((String value) {
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
                  labelText: 'Select Type',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: <String>[
                  'restaurant',
                  'viewpoint',
                  'museum',
                  'historic_place'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_capitalize(value)),
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
              TextFormField(
                decoration: InputDecoration(hintText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Location'),
                onChanged: (value) {
                  location = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
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
                maxLines: 5, // Aumenta el tamaño del campo de descripción
              ),
              if (_selectedType == 'Activity') ...[
                TextFormField(
                  decoration: InputDecoration(hintText: 'Date (YYYY-MM-DD)'),
                  onChanged: (value) {
                    date = DateTime.parse(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a date';
                    }
                    try {
                      DateTime.parse(value);
                    } catch (e) {
                      return 'Please enter a valid date';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _timeController,
                  decoration: InputDecoration(hintText: 'Time (HH:MM)'),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        time = picked;
                        _timeController.text = picked.format(context);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a time';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    price = double.parse(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    try {
                      double.parse(value);
                    } catch (e) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Meeting Point'),
                  onChanged: (value) {
                    meetingPoint = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a meeting point';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Capacity'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    capacity = int.parse(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a capacity';
                    }
                    try {
                      int.parse(value);
                    } catch (e) {
                      return 'Please enter a valid capacity';
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
                          SnackBar(content: Text('No user is logged in')),
                        );
                        return;
                      }

                      if (_selectedType == 'Activity') {
                        Post activity = Post.activity(
                          title: title,
                          location: location,
                          description: description,
                          userId: user.uid,
                          date: date!,
                          price: price!,
                          meetingPoint: meetingPoint!,
                          capacity: capacity!,
                          time: _timeController.text,
                          category: _selectedCategory,
                        );

                        await _firestore.collection('posts').add(activity.toJson());
                      } else {
                        Post review = Post.review(
                          title: title,
                          location: location,
                          description: description,
                          userId: user.uid,
                          category: _selectedCategory,
                        );

                        await _firestore.collection('posts').add(review.toJson());
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Creation Successful!'))
                      );

                      Navigator.pushReplacementNamed(context, '/home'); // Redirigir a la página de inicio después de crear
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create: $e')),
                      );
                      print(e);
                    }
                  }
                },
                child: Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }
}
