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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildDetailRow('Actividad', widget.post.title),
                  _buildDetailRow('Plazas Disponibles', widget.post.availableSeats?.toString() ?? '0'),
                  SizedBox(height: 20),
                  Text(
                    'Número de Participantes:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
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
                  _buildDetailRow('Precio Total', '${(widget.post.price! * _numberOfParticipants).toStringAsFixed(2)}€'),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _makeReservation(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Reservar', style: TextStyle(fontSize: 18)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
      status: 'Confirmada',
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
