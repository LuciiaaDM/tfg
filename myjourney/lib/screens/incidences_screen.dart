import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/incidence_model.dart';

class IncidencesScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Incidencias'),
        ),
        body: Center(
          child: Text('Por favor, inicie sesión para ver sus incidencias.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Incidencias'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('incidences')
            .where('reportedBy', isEqualTo: currentUser.email)
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

          final incidences = snapshot.data!.docs.map((doc) {
            return Incidence.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: incidences.length,
            itemBuilder: (context, index) {
              final incidence = incidences[index];
              return ListTile(
                title: Text(incidence.description),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoría: ${incidence.category}'),
                    Text('Reportado por: ${incidence.reportedBy}'),
                    Text('Estado: ${incidence.status}'),
                    if (incidence.userId != null) Text('ID de Usuario: ${incidence.userId}'),
                    Text('Fecha y Hora: ${incidence.timestamp.toDate()}'),
                  ],
                ),
                trailing: currentUser.email == 'admin@admin.com'
                    ? DropdownButton<String>(
                        value: incidence.status,
                        items: <String>['Creado', 'En Proceso', 'Resuelto'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          _firestore.collection('incidences').doc(incidence.id).update({'status': newValue});
                        },
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
