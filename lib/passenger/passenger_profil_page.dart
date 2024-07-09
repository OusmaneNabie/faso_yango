import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yango_faso/firebase/authentification.dart';
import 'package:yango_faso/passenger/manage_profil.dart';
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
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        firstName = userDoc['firstName'];
        lastName = userDoc['lastName'];
        email = userDoc['email'];
        phoneNumber = userDoc['numero'];
      });

      DocumentSnapshot<Map<String, dynamic>> bioDoc = await FirebaseFirestore
          .instance
          .collection('bios')
          .doc(user.uid)
          .get();

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('URL_DE_VOTRE_IMAGE'),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$firstName $lastName',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$email',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text('Biographie'),
                      subtitle: Text('Votre bio ici...'),
                      trailing: Icon(Icons.edit),
                      onTap: _showBioDialog,
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text('Numéro de téléphone'),
                      subtitle: Text('$phoneNumber'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text('Biographie'),
                      subtitle: Text('$bio'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text('Mon historique de trajets'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReservedRidesPage()),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Déconnexion'),
                      onTap: _isLoading ? null : () => _logout(context),
                      trailing: _isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : null,
                    ),
                  ),
                  Divider(),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
