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
        title: Text('Detalles de la Reserva'),
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
                children: [
                  _buildDetailRow('Actividad', reservation.activityTitle),
                  _buildDetailRow('Participantes', reservation.numberOfParticipants.toString()),
                  _buildDetailRow('Precio Total', '${reservation.totalPrice.toStringAsFixed(2)}€'),
                  _buildDetailRow('Estado', reservation.status),
                  _buildDetailRow('Fecha', reservation.activityDate.toLocal().toString().split(' ')[0]),
                  _buildDetailRow('Hora', reservation.activityTime),
                  SizedBox(height: 20),
                  if (reservation.status != 'Cancelada')
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          bool confirm = await _showCancelConfirmationDialog(context);
                          if (confirm) {
                            await _cancelReservation(context);
                          }
                        },
                        icon: Icon(Icons.delete),
                        label: Text('Cancelar Reserva'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
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

  Future<bool> _showCancelConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirmar Cancelación'),
              content: Text(
                  '¿Estás seguro de que deseas cancelar esta reserva? Se te reembolsará el total menos 1.50€ por participante.'),
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
                  child: Text('Sí'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _cancelReservation(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay usuario conectado')),
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
          {'status': 'Cancelada'},
        );
        transaction.update(
          FirebaseFirestore.instance.collection('posts').doc(reservation.postId),
          {
            'availableSeats': FieldValue.increment(reservation.numberOfParticipants),
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Reserva cancelada y reembolsada!')),
        );

        Navigator.pop(context);
      }
    });
  }
}
