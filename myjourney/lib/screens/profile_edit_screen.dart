import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _residenceController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    _residenceController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _additionalInfoController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _residenceController.dispose();
    _phoneNumberController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _residenceController.text = data['residence'] ?? '';
          _phoneNumberController.text = data['phoneNumber'] ?? '';
          _additionalInfoController.text = data['additionalInfo'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _residenceController,
                decoration: InputDecoration(hintText: 'Place of Residence'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your place of residence';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(hintText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _additionalInfoController,
                decoration: InputDecoration(hintText: 'Additional Information'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final user = _auth.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No user is logged in')),
                        );
                        return;
                      }

                      await _firestore.collection('users').doc(user.uid).update({
                        'residence': _residenceController.text,
                        'phoneNumber': _phoneNumberController.text,
                        'additionalInfo': _additionalInfoController.text,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile updated successfully!'))
                      );

                      Navigator.pop(context); // Regresar a la pantalla anterior
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update profile: $e'))
                      );
                      print(e);
                    }
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
