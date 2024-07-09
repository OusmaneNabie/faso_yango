import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yango_faso/passenger/passenger_verification.dart';

class ProfileManagementPage extends StatefulWidget {
  @override
  State<ProfileManagementPage> createState() => _ProfileManagementPageState();
}

class _ProfileManagementPageState extends State<ProfileManagementPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserData();
  }

  void _loadUserData() async {
    if (user != null) {
      var userData = await _firestore.collection('users').doc(user!.uid).get();
      _nameController.text = userData['firstName'] ?? '';
      _surnameController.text = userData['lastName'] ?? '';
      _emailController.text = user!.email ?? '';
      _phoneController.text = userData['numero'] ?? '';
    }
  }

  void _updateName() async {
    await _firestore.collection('users').doc(user!.uid).update({
      'firstName': _nameController.text,
    });
  }

  void _updateSurname() async {
    await _firestore.collection('users').doc(user!.uid).update({
      'lastName': _surnameController.text,
    });
  }

  void _updateEmail() async {
    try {
      await user!.updateEmail(_emailController.text);
      // Envoie un e-mail de vérification pour le nouvel e-mail
      await user!.sendEmailVerification();
      await _firestore.collection('users').doc(user!.uid).update({
        'email': _emailController.text,
      });
    } catch (e) {
      print('Failed to update email: $e');
    }
  }

  void _updatePhone() async {
    await _firestore.collection('users').doc(user!.uid).update({
      'numero': _phoneController.text,
    });
  }

  void _updatePassword() async {
    try {
      await user!.updatePassword(_passwordController.text);
    } catch (e) {
      print('Echec de modification du mot de passe: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Profil'),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.teal),
                        onPressed: () {
                          // Action pour changer la photo de profil
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildCard(
              title: 'Informations Personnelles',
              child: _buildPersonalInfoSection(),
            ),
            SizedBox(height: 16),
            _buildCard(
              title: 'Coordonnées',
              child: _buildContactInfoSection(),
            ),
            SizedBox(height: 16),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.verified, color: Colors.teal,),
                title: Text('Vérifiez votre compte'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountVerificationPage()),
                  );
                },
              ),
            ),

            // Ajoutez les autres sections de votre profil ici
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        _buildEditableListTile('Nom', Icons.person, _nameController),
        _buildEditableListTile('Prenom', Icons.person, _surnameController),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      children: [
        _buildEditableListTile('Adresse E-mail', Icons.email, _emailController),
        _buildEditableListTile(
            'Numéro de Téléphone', Icons.phone, _phoneController),
        _buildEditableListTile('Mot de passe', Icons.lock, _passwordController),
      ],
    );
  }

  // Ajoutez les autres sections de votre profil ici

  Widget _buildEditableListTile(
      String title, IconData icon, TextEditingController controller) {
    return ListTile(
      title: Text(title),
      trailing: Icon(icon, color: Colors.teal),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter your $title',
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    // Enregistrer les modifications
                    Navigator.of(context).pop();
                  },
                  child: Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
