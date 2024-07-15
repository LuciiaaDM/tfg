import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_incidence_screen.dart';
import 'incidences_screen.dart';
import 'profile_edit_screen.dart';
import 'add_balance_screen.dart'; // Importa la pantalla de añadir saldo

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Add Balance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBalanceScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.report_problem),
            title: Text('Create Incidence'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateIncidenceScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('View Incidences'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IncidencesScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
