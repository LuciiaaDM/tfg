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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(hintText: 'Número de Tarjeta'),
                onChanged: (value) {
                  cardNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el número de tarjeta';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Nombre del Titular de la Tarjeta'),
                onChanged: (value) {
                  cardHolder = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el nombre del titular de la tarjeta';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Fecha de Caducidad (MM/AA)'),
                onChanged: (value) {
                  expiryDate = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce la fecha de caducidad';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'CVV'),
                onChanged: (value) {
                  cvv = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el CVV';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Cantidad a Añadir'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amountToAdd = double.parse(value);
                },
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
              ElevatedButton(
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
                ),
                child: Text('Añadir Saldo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
