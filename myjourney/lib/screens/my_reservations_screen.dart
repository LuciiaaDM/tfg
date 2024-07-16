import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation_model.dart';
import 'reservation_detail_screen.dart';

class MyReservationsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mis Reservas'),
        ),
        body: Center(
          child: Text('Por favor, inicie sesión para ver sus reservas.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Reservas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('reservations')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final reservations = snapshot.data!.docs.map((doc) {
            return Reservation.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return ListTile(
                title: Text(reservation.activityTitle),
                subtitle: Text(
                  'Participantes: ${reservation.numberOfParticipants}, Precio Total: ${reservation.totalPrice.toStringAsFixed(2)}€',
                ),
                tileColor: reservation.status == 'cancelled' ? Colors.red.withOpacity(0.3) : null,
                trailing: reservation.status == 'cancelled'
                    ? Icon(Icons.cancel, color: Colors.red)
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationDetailScreen(reservation: reservation),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
