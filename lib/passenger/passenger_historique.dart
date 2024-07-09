import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservedRidesPage extends StatefulWidget {
  @override
  _ReservedRidesPageState createState() => _ReservedRidesPageState();
}

class _ReservedRidesPageState extends State<ReservedRidesPage> {
  List<Map<String, dynamic>> reservedTrajets = [];

  @override
  void initState() {
    super.initState();
    fetchReservedTrajets();
  }

  Future<void> fetchReservedTrajets() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('trajetreserver')
            .where('userId', isEqualTo: userId)
            .get();

        setState(() {
          reservedTrajets = querySnapshot.docs.map((doc) {
            Map<String, dynamic> trajetData =
                doc.data() as Map<String, dynamic>;
            trajetData['id'] = doc.id; // Ajouter l'ID du document Firestore
            return trajetData;
          }).toList();
        });
      } else {
        print('Utilisateur non connecté.');
      }
    } catch (e) {
      print('Erreur lors de la récupération des trajets réservés: $e');
    }
  }

  Future<void> cancelReservation(String trajetId, int placesReservees) async {
    try {
      bool confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Annuler la réservation'),
            content:
                Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Annuler
                },
                child: Text('Non'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirmer
                },
                child: Text('Oui'),
              ),
            ],
          );
        },
      );

      if (confirmation != null && confirmation) {
        // Récupérer l'ID du trajet d'origine de la réservation
        DocumentSnapshot trajetReserveSnapshot = await FirebaseFirestore
            .instance
            .collection('trajetreserver')
            .doc(trajetId)
            .get();
        if (trajetReserveSnapshot.exists) {
          String trajetOriginalId = trajetReserveSnapshot['trajetId'];

          // Mettre à jour le nombre de places disponibles pour le trajet d'origine
          await FirebaseFirestore.instance
              .collection('trajets')
              .doc(trajetOriginalId)
              .update({
            'nombrePlaces': FieldValue.increment(placesReservees),
          });

          // Supprimer la réservation de la collection des trajets réservés
          await FirebaseFirestore.instance
              .collection('trajetreserver')
              .doc(trajetId)
              .delete();

          // Mettre à jour l'affichage
          fetchReservedTrajets();

          // Afficher un message de succès
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Réservation annulée'),
                content: Text('La réservation a été annulée avec succès.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Afficher un message d'erreur si le document de la réservation n'existe pas
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Erreur'),
                content: Text(
                    'La réservation que vous essayez d\'annuler n\'existe pas.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Erreur lors de l\'annulation de la réservation: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text(
                'Une erreur est survenue lors de l\'annulation de la réservation. Veuillez réessayer plus tard.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Mes trajets réservés',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: reservedTrajets.isEmpty
          ? Center(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Vous n\'avez réservé aucun trajet pour l\'instant.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: reservedTrajets.length,
              itemBuilder: (context, index) {
                final trajet = reservedTrajets[index];
                final trajetId = trajet['id'];
                final depart = trajet['depart'];
                final destination = trajet['destination'];
                final heure = trajet['heure'];
                final date = trajet['date'];
                final placesReservees = trajet['placesReservees'];
                final numeroTelephone = trajet['numeroTelephone'];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Départ: $depart',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Destination: $destination',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Date: $date',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Heure: $heure',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Places réservées: $placesReservees',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Numéro du conducteur: $numeroTelephone',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Annuler la réservation et libérer les places réservées
                          cancelReservation(trajetId, placesReservees);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .red, // Couleur rouge pour le bouton annuler
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
