import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation_model.dart';

class ReservationDetailScreen extends StatelessWidget {
  final Reservation reservation;

  ReservationDetailScreen({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity: ${reservation.activityTitle}'),
            Text('Participants: ${reservation.numberOfParticipants}'),
            Text('Total Price: \$${reservation.totalPrice.toStringAsFixed(2)}'),
            Text('Status: ${reservation.status}'),
            Text('Date: ${reservation.activityDate.toLocal().toString().split(' ')[0]}'),
            Text('Time: ${reservation.activityTime}'),
            SizedBox(height: 20),
            if (reservation.status != 'cancelled')
              ElevatedButton.icon(
                  onPressed: () async {
                    bool confirm = await _showCancelConfirmationDialog(context);
                    if (confirm) {
                      await _cancelReservation(context);
                    }
                  },
                  icon: Icon(Icons.delete),
                  label: Text('Cancel Reservation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showCancelConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Cancellation'),
          content: Text('Are you sure you want to cancel this reservation? You will be refunded the total price minus \$1.50 per participant.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _cancelReservation(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is logged in')),
      );
      return;
    }

    final refundAmount = reservation.totalPrice - (1.5 * reservation.numberOfParticipants);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final userDoc = await transaction.get(userRef);

      if (userDoc.exists) {
        final userData = userDoc.data();
        final newBalance = (userData?['balance'] ?? 0.0) + refundAmount;

        transaction.update(userRef, {'balance': newBalance});
        transaction.update(
          FirebaseFirestore.instance.collection('reservations').doc(reservation.id),
          {'status': 'cancelled'},
        );
        transaction.update(
          FirebaseFirestore.instance.collection('posts').doc(reservation.postId),
          {
            'availableSeats': FieldValue.increment(reservation.numberOfParticipants),
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation cancelled and refunded!')),
        );

        Navigator.pop(context);
      }
    });
  }
}
