import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/reservation_model.dart';

class ReserveScreen extends StatefulWidget {
  final Post post;

  ReserveScreen({required this.post});

  @override
  _ReserveScreenState createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _numberOfParticipants = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar Actividad'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Actividad: ${widget.post.title}'),
            Text('Plazas Disponibles: ${widget.post.availableSeats ?? 0}'),
            SizedBox(height: 20),
            Text('Número de Participantes:'),
            DropdownButton<int>(
              value: _numberOfParticipants,
              items: List.generate(widget.post.availableSeats ?? 0, (index) => index + 1)
                  .map((value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _numberOfParticipants = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Precio Total: ${(widget.post.price! * _numberOfParticipants).toStringAsFixed(2)}€'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _makeReservation(context);
              },
              child: Text('Reservar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Cambia el color del botón a naranja
                foregroundColor: Colors.white, // Cambia el color del texto del botón a blanco
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeReservation(BuildContext context) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay usuario conectado')),
      );
      return;
    }

    final totalPrice = widget.post.price! * _numberOfParticipants;

    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    final userData = userDoc.data();
    final userBalance = userData?['balance'] ?? 0.0;

    if (userBalance < totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saldo insuficiente. Por favor, recargue.')),
      );
      return;
    }

    final reservationId = _firestore.collection('reservations').doc().id;

    final reservation = Reservation(
      id: reservationId,
      postId: widget.post.id,
      userId: currentUser.uid,
      userName: userData?['username'],
      numberOfParticipants: _numberOfParticipants,
      totalPrice: totalPrice,
      status: 'confirmed',
      activityDate: widget.post.date!,
      activityTime: widget.post.time!,
      activityTitle: widget.post.title,
    );

    await _firestore.runTransaction((transaction) async {
      final newBalance = userBalance - totalPrice;

      transaction.update(
        _firestore.collection('users').doc(currentUser.uid),
        {'balance': newBalance},
      );

      transaction.update(
        _firestore.collection('posts').doc(widget.post.id),
        {
          'availableSeats': FieldValue.increment(-_numberOfParticipants),
        },
      );

      transaction.set(
        _firestore.collection('reservations').doc(reservationId),
        reservation.toJson(),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Reserva exitosa!')),
    );

    Navigator.pop(context);
  }
}
