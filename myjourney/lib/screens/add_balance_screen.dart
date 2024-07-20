import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AddBalanceScreen extends StatefulWidget {
  @override
  _AddBalanceScreenState createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late String cardNumber;
  late String cardHolder;
  late String expiryDate;
  late String cvv;
  double amountToAdd = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Saldo'),
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
                  _buildTextField(
                    hintText: 'Número de Tarjeta',
                    onChanged: (value) => cardNumber = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce el número de tarjeta';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    hintText: 'Nombre del Titular de la Tarjeta',
                    onChanged: (value) => cardHolder = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce el nombre del titular de la tarjeta';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    hintText: 'Fecha de Caducidad (MM/AA)',
                    onChanged: (value) => expiryDate = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce la fecha de caducidad';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    hintText: 'CVV',
                    onChanged: (value) => cvv = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce el CVV';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    hintText: 'Cantidad a Añadir',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => amountToAdd = double.parse(value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce una cantidad';
                      }
                      try {
                        double.parse(value);
                      } catch (e) {
                        return 'Por favor, introduce una cantidad válida';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final user = _auth.currentUser;
                          if (user != null) {
                            final rand = Random();
                            if (rand.nextInt(100) < 95) {
                              await _firestore.runTransaction((transaction) async {
                                final userRef = _firestore.collection('users').doc(user.uid);
                                final userDoc = await transaction.get(userRef);

                                if (userDoc.exists) {
                                  final currentBalance = (userDoc['balance'] ?? 0.0) as double;
                                  final newBalance = currentBalance + amountToAdd;
                                  transaction.update(userRef, {'balance': newBalance});

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('¡Saldo añadido exitosamente!')),
                                  );

                                  Navigator.pop(context);
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Transacción fallida. Por favor, intenta nuevamente.')),
                              );
                            }
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
                      child: Text('Añadir Saldo', style: TextStyle(fontSize: 18)),
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

  Widget _buildTextField({
    required String hintText,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
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
        onChanged: onChanged,
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }
}
