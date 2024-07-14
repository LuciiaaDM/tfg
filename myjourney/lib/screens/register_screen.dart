import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String username;
  late String email;
  late String password;
  late String residence;
  late String phoneNumber;
  String? additionalInfo; // Hacemos que este campo sea opcional

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(hintText: 'Username'),
                onChanged: (value) {
                  username = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Email'),
                onChanged: (value) {
                  email = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Place of Residence'),
                onChanged: (value) {
                  residence = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Phone Number'),
                onChanged: (value) {
                  phoneNumber = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Additional Information'),
                onChanged: (value) {
                  additionalInfo = value;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      // Verificar unicidad del nombre de usuario
                      final usernameSnapshot = await _firestore
                          .collection('users')
                          .where('username', isEqualTo: username)
                          .get();

                      if (usernameSnapshot.docs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Username already exists')),
                        );
                        return;
                      }

                      final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      if (newUser != null) {
                        UserModel userModel = UserModel(
                          uid: newUser.user!.uid,
                          username: username,
                          email: email,
                          residence: residence,
                          phoneNumber: phoneNumber,
                          additionalInfo: additionalInfo ?? '', // Guardar cadena vacía si es null
                        );

                        await _firestore
                            .collection('users')
                            .doc(newUser.user!.uid)
                            .set(userModel.toJson());

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('User Registered Successfully! Please login.'))
                        );

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        ); // Navega a la página de inicio de sesión y elimina todas las rutas anteriores
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to register user: $e')),
                      );
                      print(e);
                    }
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
