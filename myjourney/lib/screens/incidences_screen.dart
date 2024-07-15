import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/incidence_model.dart';

class IncidencesScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incidences'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('incidences').snapshots(),
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
                    Text('Category: ${incidence.category}'),
                    Text('Reported by: ${incidence.reportedBy}'),
                    Text('Status: ${incidence.status}'),
                    if (incidence.userId != null) Text('User ID: ${incidence.userId}'),
                    Text('Timestamp: ${incidence.timestamp.toDate()}'),
                  ],
                ),
                trailing: _auth.currentUser!.email == 'admin@example.com'
                    ? DropdownButton<String>(
                        value: incidence.status,
                        items: <String>['Created', 'In Progress', 'Resolved'].map((String value) {
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
