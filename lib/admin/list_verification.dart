import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yango_faso/admin/verification_details.dart';

class VerificationListPage extends StatefulWidget {
  @override
  _VerificationListPageState createState() => _VerificationListPageState();
}

class _VerificationListPageState extends State<VerificationListPage> {
  late Future<List<DocumentSnapshot>> _verificationList;

  @override
  void initState() {
    super.initState();
    _verificationList = _fetchVerificationList();
  }

  Future<List<DocumentSnapshot>> _fetchVerificationList() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('verification').get();

    return querySnapshot.docs;
  }

  Future<String> _fetchEmail(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['email'];
  }

  Future<void> _deleteVerification(String verificationId) async {
    await FirebaseFirestore.instance
        .collection('verification')
        .doc(verificationId)
        .delete();
  }

  Future<void> _verifyUser(String userId, String verificationId) async {
    // Show confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la vérification"),
          content:
              Text("Êtes-vous sûr de vouloir vérifier cet utilisateur ?"),
          actions: <Widget>[
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Confirmer"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm != null && confirm) {
      // Update user role to 'driver' (example update)
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'conducteur',
      });

      // Update verification status to true
      await FirebaseFirestore.instance
          .collection('verification')
          .doc(verificationId)
          .update({
        'status': true,
      });

      setState(() {
        _verificationList = _fetchVerificationList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Vérifications'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _verificationList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          List<DocumentSnapshot> verificationList = snapshot.data ?? [];

          if (verificationList.isEmpty) {
            return Center(child: Text('Aucune vérification trouvée'));
          }

          return ListView.builder(
            itemCount: verificationList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot verification = verificationList[index];
              String userId = verification['userId'];
              bool isVerified = verification['status'] ?? false; // Default to false if field doesn't exist

              return FutureBuilder<String>(
                future: _fetchEmail(userId),
                builder: (context, emailSnapshot) {
                  if (emailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Chargement...'),
                    );
                  }

                  if (emailSnapshot.hasError) {
                    return ListTile(
                      title: Text(
                          'Erreur lors du chargement de l\'email: ${emailSnapshot.error}'),
                    );
                  }

                  String email = emailSnapshot.data ?? 'Email non trouvé';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VerificationDetailPage(verification: verification),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(email),
                        subtitle: Text('Cliquez pour voir les détails'),
                        leading: Icon(
                          isVerified ? Icons.verified_user : Icons.person,
                          color: isVerified ? Colors.green : null,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _showDeleteDialog(verification.id),
                            ),
                            IconButton(
                              icon: Icon(Icons.verified,
                                  color: isVerified ? Colors.green : null),
                              onPressed: () => _verifyUser(userId, verification.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(String verificationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content:
              Text("Voulez-vous vraiment supprimer cette vérification ?"),
          actions: <Widget>[
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Supprimer"),
              onPressed: () {
                _deleteVerification(verificationId).then((_) {
                  Navigator.of(context).pop();
                  setState(() {
                    _verificationList = _fetchVerificationList();
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }
}
