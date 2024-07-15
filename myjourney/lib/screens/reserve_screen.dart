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
        title: Text('Reserve Activity'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Activity: ${widget.post.title}'),
            Text('Available Seats: ${widget.post.availableSeats ?? 0}'),
            SizedBox(height: 20),
            Text('Number of Participants:'),
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
            Text('Total Price: \$${(widget.post.price! * _numberOfParticipants).toStringAsFixed(2)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _makeReservation(context);
              },
              child: Text('Reserve'),
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
        SnackBar(content: Text('No user is logged in')),
      );
      return;
    }

    final totalPrice = widget.post.price! * _numberOfParticipants;

    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    final userData = userDoc.data();
    final userBalance = userData?['balance'] ?? 0.0;

    if (userBalance < totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient balance. Please recharge.')),
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
      SnackBar(content: Text('Reservation successful!')),
    );

    Navigator.pop(context);
  }
}
