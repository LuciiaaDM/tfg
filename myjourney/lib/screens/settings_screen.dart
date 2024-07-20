import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_incidence_screen.dart';
import 'incidences_screen.dart';
import 'profile_edit_screen.dart';
import 'add_balance_screen.dart'; 

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Editar Perfil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Añadir Saldo'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBalanceScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.report_problem),
            title: Text('Crear Incidencia'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateIncidenceScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Ver Incidencias'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IncidencesScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
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
