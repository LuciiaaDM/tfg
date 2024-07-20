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
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: <Widget>[
          _buildSettingsTile(
            context: context,
            icon: Icons.edit,
            title: 'Editar Perfil',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.account_balance_wallet,
            title: 'Añadir Saldo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBalanceScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.report_problem,
            title: 'Crear Incidencia',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateIncidenceScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.list,
            title: 'Ver Incidencias',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IncidencesScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
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

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
