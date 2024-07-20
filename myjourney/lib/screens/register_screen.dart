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
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
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
                  shrinkWrap: true,
                  children: <Widget>[
                    _buildTextField(
                      hintText: 'Nombre de usuario',
                      onChanged: (value) => username = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese su nombre de usuario';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      hintText: 'Correo electrónico',
                      onChanged: (value) => email = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese su correo electrónico';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      hintText: 'Contraseña',
                      obscureText: true,
                      onChanged: (value) => password = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese su contraseña';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      hintText: 'Confirmar contraseña',
                      obscureText: true,
                      onChanged: (value) => confirmPassword = value,
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
                    _buildTextField(
                      hintText: 'Lugar de residencia',
                      onChanged: (value) => residence = value,
                    ),
                    _buildTextField(
                      hintText: 'Número de teléfono',
                      onChanged: (value) => phoneNumber = value,
                    ),
                    _buildTextField(
                      hintText: 'Información adicional',
                      onChanged: (value) => additionalInfo = value,
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            // Verificar si el nombre de usuario ya existe
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

                            // Crear usuario con correo electrónico y contraseña
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
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Registrar', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
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
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
