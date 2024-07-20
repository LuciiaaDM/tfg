import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _residenceController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    _residenceController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _additionalInfoController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _residenceController.dispose();
    _phoneNumberController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _residenceController.text = data!['residence'] ?? '';
          _phoneNumberController.text = data!['phoneNumber'] ?? '';
          _additionalInfoController.text = data!['additionalInfo'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
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
                      controller: _residenceController,
                      hintText: 'Lugar de Residencia',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese su lugar de residencia';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _phoneNumberController,
                      hintText: 'Número de Teléfono',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese su número de teléfono';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _additionalInfoController,
                      hintText: 'Información Adicional',
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

                            await _firestore.collection('users').doc(user.uid).update({
                              'residence': _residenceController.text,
                              'phoneNumber': _phoneNumberController.text,
                              'additionalInfo': _additionalInfoController.text,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('¡Perfil actualizado exitosamente!'))
                            );

                            Navigator.pop(context); 
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al actualizar el perfil: $e'))
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
                      child: Text('Guardar', style: TextStyle(fontSize: 18)),
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
    required TextEditingController controller,
    required String hintText,
    FormFieldValidator<String>? validator,
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
        validator: validator,
      ),
    );
  }
}
