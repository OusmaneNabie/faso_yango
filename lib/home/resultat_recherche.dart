import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yango_faso/home/detail_result.dart';
import 'package:yango_faso/trajet/detail_trajet.dart'; // Import de la classe ResultDetails pour la navigation

class SearchResultsPage extends StatefulWidget {
  final List<Map<String, dynamic>> results;

  const SearchResultsPage({Key? key, required this.results}) : super(key: key);

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<Map<String, dynamic>> trajets = [];

  @override
  void initState() {
    super.initState();
    fetchPublishedTrajets();
  }

  Future<void> fetchPublishedTrajets() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('trajets').get();

      setState(() {
        trajets = querySnapshot.docs.map((doc) {
          Map<String, dynamic> trajetData = doc.data() as Map<String, dynamic>;
          trajetData['id'] = doc.id; // Ajouter l'ID du document Firestore
          return trajetData;
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des trajets: $e');
    }
  }

  void _navigateToTrajetDetails(BuildContext context, Map<String, dynamic> trajet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultDetails(trajet: trajet),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Résultats de la recherche',
          style: TextStyle(color:Colors.white),
          ),
      ),
      body: widget.results.isEmpty
          ? Center(
              child: Text(
                'Aucun trajet trouvé',
                style: TextStyle(fontSize: 20.0),
              ),
            )
          : ListView.builder(
              itemCount: widget.results.length,
              itemBuilder: (context, index) {
                final result = widget.results[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 2.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Départ: ${result['depart'] ?? 'N/A'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Destination: ${result['destination'] ?? 'N/A'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Date: ${result['date'] ?? 'N/A'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Heure: ${result['heure'] ?? 'N/A'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.airline_seat_recline_normal, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Places: ${result['nombrePlaces'] ?? 'N/A'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Numéro: ${result['numeroTelephone'] ?? 'N/A'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Action pour réserver le trajet
                          _showReservationDialog(context, result['id'], result['nombrePlaces']);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                        child: Text(
                          'Réserver',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onTap: () => _navigateToTrajetDetails(context, result), // Ajoutez cette ligne pour naviguer vers les détails du trajet
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showReservationDialog(BuildContext context, String? trajetId, int? nombrePlacesDisponibles) {
    TextEditingController placesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Réserver des places'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: placesController,
                decoration: InputDecoration(labelText: 'Nombre de places'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                int placesReservees = int.tryParse(placesController.text) ?? 0;
                if (placesReservees <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez saisir un nombre de places valide.')),
                  );
                } else if (nombrePlacesDisponibles != null && placesReservees > nombrePlacesDisponibles) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Le nombre de places réservées dépasse le nombre de places disponibles.')),
                  );
                } else {
                  if (trajetId != null && nombrePlacesDisponibles != null) {
                    _reservePlaces(context, trajetId, placesReservees, nombrePlacesDisponibles);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Détails du trajet non disponibles.')),
                    );
                  }
                }
              },
              child: Text('Réserver'),
            ),
          ],
        );
      },
    );
  }

  void _reservePlaces(BuildContext context, String trajetId, int placesReservees, int nombrePlacesDisponibles) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String passengerId = user.uid;

        // Obtenir le trajet pour avoir les détails
        DocumentSnapshot trajetSnapshot = await FirebaseFirestore.instance.collection('trajets').doc(trajetId).get();
        if (trajetSnapshot.exists) {
          Map<String, dynamic> trajetData = trajetSnapshot.data() as Map<String, dynamic>;
          String? driverId = trajetData['userID'] as String?;
          // Récupérer directement l'ID du conducteur depuis le document du trajet

          if (driverId != null) {
            String depart = trajetData['depart'] ?? 'N/A';
            String destination = trajetData['destination'] ?? 'N/A';
            String date = trajetData['date'] ?? 'N/A';
            String heure = trajetData['heure'] ?? 'N/A';
            String numeroTelephone = trajetData['numeroTelephone'] ?? 'N/A';

            // Mettre à jour le nombre de places disponibles dans la base de données Firestore
            await FirebaseFirestore.instance.collection('trajets').doc(trajetId).update({
              'nombrePlaces': nombrePlacesDisponibles - placesReservees,
            });

            // Enregistrer le trajet réservé dans la collection 'trajetreserver'
            await FirebaseFirestore.instance.collection('trajetreserver').add({
              'trajetId': trajetId,
              'userId': user.uid,
              'driverId': driverId,
              'depart': depart,
              'destination': destination,
              'date': date,
              'heure': heure,
              'placesReservees': placesReservees,
              'numeroTelephone': numeroTelephone,
              'timestamp': FieldValue.serverTimestamp(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Places réservées avec succès.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ID du conducteur non trouvé. Veuillez réessayer.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Trajet introuvable. Veuillez réessayer.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non connecté.')),
        );
      }
    } catch (e) {
      print('Erreur lors de la réservation des places: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la réservation des places. Veuillez réessayer.')),
      );
    }
  }
}
