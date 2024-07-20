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
  late String confirmPassword;
  late String residence;
  late String phoneNumber;
  String? additionalInfo; 

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(hintText: 'Nombre de usuario'),
                onChanged: (value) {
                  username = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su nombre de usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Correo electrónico'),
                onChanged: (value) {
                  email = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su correo electrónico';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Contraseña'),
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su contraseña';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Confirmar contraseña'),
                obscureText: true,
                onChanged: (value) {
                  confirmPassword = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme su contraseña';
                  }
                  if (value != password) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Lugar de residencia'),
                onChanged: (value) {
                  residence = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Número de teléfono'),
                onChanged: (value) {
                  phoneNumber = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Información adicional'),
                onChanged: (value) {
                  additionalInfo = value;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      
                      final usernameSnapshot = await _firestore
                          .collection('users')
                          .where('username', isEqualTo: username)
                          .get();

                      if (usernameSnapshot.docs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('El nombre de usuario ya existe')),
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
                          additionalInfo: additionalInfo ?? '', 
                        );

                        await _firestore
                            .collection('users')
                            .doc(newUser.user!.uid)
                            .set(userModel.toJson());

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Usuario registrado con éxito. Por favor, inicie sesión.'))
                        );

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        ); 
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al registrar el usuario: $e')),
                      );
                      print(e);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, 
                  foregroundColor: Colors.white,  
                ),
                child: Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
