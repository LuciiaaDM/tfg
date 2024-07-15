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
        title: Text('Add Balance'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(hintText: 'Card Number'),
                onChanged: (value) {
                  cardNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Card Holder Name'),
                onChanged: (value) {
                  cardHolder = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the card holder name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Expiry Date (MM/YY)'),
                onChanged: (value) {
                  expiryDate = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expiry date';
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
                    return 'Please enter the CVV';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Amount to Add'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amountToAdd = double.parse(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Please enter a valid amount';
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
                        // Simula una transacción exitosa el 95% de las veces
                        await _firestore.runTransaction((transaction) async {
                          final userRef = _firestore.collection('users').doc(user.uid);
                          final userDoc = await transaction.get(userRef);

                          if (userDoc.exists) {
                            final currentBalance = (userDoc['balance'] ?? 0.0) as double;
                            final newBalance = currentBalance + amountToAdd;
                            transaction.update(userRef, {'balance': newBalance});

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Balance added successfully!')),
                            );

                            Navigator.pop(context);
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Transaction failed. Please try again.')),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Cambia el color del botón a naranja
                  foregroundColor: Colors.white, // Cambia el color del texto del botón a blanco
                ),
                child: Text('Add Balance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
