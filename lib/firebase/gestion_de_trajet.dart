import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//*********************************PUBLICATION DE TRAJETS******************************** */
class TrajetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> publierTrajet({
    required String depart,
    required String destination,
    required String date,
    required String heure,
    required int nombrePlaces,
    required String telephone,
    required BuildContext context, // Ajout de BuildContext pour afficher la boîte de dialogue
  }) async {
    try {
      // Récupérer l'utilisateur actuellement connecté
      User? user = _auth.currentUser;
      if (user != null) {
        // Récupérer les informations de l'utilisateur
        DocumentSnapshot<Map<String, dynamic>> userData =
            await _firestore.collection('users').doc(user.uid).get();

        // Créer un document pour le trajet
        await _firestore.collection('trajets').add({
          'depart': depart,
          'destination': destination,
          'date': date,
          'heure': heure,
          'nombrePlaces': nombrePlaces,
          'numeroTelephone': telephone,
          'userID': user.uid, // ID de l'utilisateur
          'userNom': userData.data()?['firstName'], // Nom de l'utilisateur
          'userPrenom': userData.data()?['lastName'],
          'userEmail': userData.data()?['email'],
           // Email de l'utilisateur
          // Ajoutez d'autres champs utilisateur si nécessaire
        });

        // Afficher une boîte de dialogue de succès
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor:  Colors.blue, // Couleur jaunâtre
              content: Text(
                'Votre trajet a été publié avec succès !',
                style: TextStyle(color: Colors.white),
                ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Gérer les erreurs
      print('Erreur lors de la publication du trajet: $e');
      throw Exception('Une erreur s\'est produite lors de la publication du trajet');
    }
  }
  Future<List<String>> fetchPublishedTrajetIds() async {
  List<String> trajetIds = [];

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('trajets').get();

    querySnapshot.docs.forEach((doc) {
      trajetIds.add(doc.id);
    });
  } catch (e) {
    print('Erreur lors de la récupération des IDs des trajets publiés: $e');
  }

  return trajetIds;
}

}
//*********************************PUBLICATION DE TRAJETS******************************** */


//*********************************RECHERCHE DE TRAJETS******************************** */

class RechercheTrajet {
  Future<void> searchTrajets(String depart, String destination) async {
    try {
      // Convertir les valeurs de départ et de destination en minuscules
      String departLowercase = depart.toLowerCase();
      String destinationLowercase = destination.toLowerCase();

      // Effectuer une requête Firestore pour récupérer les trajets
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('trajets')
          .where('departLowerCase', isEqualTo: departLowercase)
          .where('destinationLowerCase', isEqualTo: destinationLowercase)
          .get();

      // Transformer les résultats en une liste de Map<String, dynamic>
      List<Map<String, dynamic>> searchResults = querySnapshot.docs.map((doc) {
        Map<String, dynamic> trajetData = doc.data() as Map<String, dynamic>;
        trajetData['id'] = doc.id; // Ajouter l'ID du document Firestore
        return trajetData;
      }).toList();

      // Utiliser les résultats de la recherche selon vos besoins
      print('Résultats de recherche : $searchResults');
    } catch (e) {
      print('Erreur lors de la recherche de trajets : $e');
    }
  }
}

//*********************************RECHERCHE DE TRAJETS******************************** */

