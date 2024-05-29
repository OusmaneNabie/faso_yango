import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yango_faso/firebase/authentification.dart';
import 'package:yango_faso/passenger/passenger_historique.dart';

class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isLoading = false;
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  String bio = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      setState(() {
        firstName = userDoc['firstName'];
        lastName = userDoc['lastName'];
        email = userDoc['email'];
        phoneNumber = userDoc['numero'];
      });

      DocumentSnapshot<Map<String, dynamic>> bioDoc = await FirebaseFirestore.instance.collection('bios').doc(user.uid).get();

      if (bioDoc.exists) {
        setState(() {
          bio = bioDoc['bio'];
        });
      }
    }
  }

  void _saveBio(String newBio) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('bios').doc(user.uid).set({
        'userId': user.uid,
        'bio': newBio,
      });

      setState(() {
        bio = newBio;
      });
    }
  }

  void _showBioDialog() {
    TextEditingController _bioController = TextEditingController(text: bio);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editer votre Bio'),
          content: TextFormField(
            controller: _bioController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Entrez votre bio ici',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveBio(_bioController.text);
                Navigator.of(context).pop();
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthentificationService.signOut(context);
    } catch (e) {
      print("Erreur lors de la déconnexion : $e");
    }

    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.grey),
                      onPressed: () {
                        // Action pour changer la photo de profil
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    '$firstName $lastName',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildCard(
              title: 'Vérifications',
              child: _buildVerificationSection(),
            ),
            SizedBox(height: 16),
            _buildCard(
              title: 'Bio',
              child: _buildBioSection(),
            ),
            SizedBox(height: 16),
            _buildCard(
              title: 'Historique de Covoiturage',
              child: _buildCarpoolingHistory(),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReservedRidesPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Voir l\'historique',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Déconnexion',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0),
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
                color: Colors.teal[800],
              ),
            ),
            SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSection() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.email, color: Colors.green),
          title: Text('$email'),
        ),
        ListTile(
          leading: Icon(Icons.phone, color: Colors.green),
          title: Text('$phoneNumber'),
        ),
        ListTile(
          leading: Icon(Icons.credit_card, color: Colors.green),
          title: Text('Carte d\'identité vérifiée'),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bio.isNotEmpty ? bio : 'Cliquez pour ajouter une bio',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _showBioDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
          child: Text(
            'Editer la bio',
            style: TextStyle(color:Colors.white)
            ),
        ),
      ],
    );
  }

  Widget _buildCarpoolingHistory() {
    return Column(
      children: [
        ListTile(
          title: Text('Trajet du 01/05/2023'),
          subtitle: Text('Paris - Lyon'),
        ),
        ListTile(
          title: Text('Trajet du 15/04/2023'),
          subtitle: Text('Lyon - Marseille'),
        ),
      ],
    );
  }
}
