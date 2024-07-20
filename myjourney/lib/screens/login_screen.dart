import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String username;
  late String password;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(hintText: 'Nombre de Usuario'),
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
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      // Buscar el usuario en Firestore por nombre de usuario
                      final userSnapshot = await _firestore
                          .collection('users')
                          .where('username', isEqualTo: username)
                          .get();

                      if (userSnapshot.docs.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Usuario no encontrado')),
                        );
                        return;
                      }

                      final user = userSnapshot.docs.first;
                      final email = user['email'];

                      // Iniciar sesión con correo electrónico y contraseña
                      await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('¡Inicio de sesión exitoso!')),
                      );

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      ); 
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al iniciar sesión: $e')),
                      );
                      print(e);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,  
                  foregroundColor: Colors.white, 
                ),
                child: Text('Iniciar Sesión'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                child: Text('¿No tienes una cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
