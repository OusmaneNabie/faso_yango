import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yango_faso/home/accueil.dart';
import 'package:yango_faso/trajet/detail_trajet.dart';

class PublishedRidesPage extends StatefulWidget {
  @override
  _PublishedRidesPageState createState() => _PublishedRidesPageState();
}

class _PublishedRidesPageState extends State<PublishedRidesPage> {
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

  void _showReservationDialog(String trajetId, int nombrePlacesDisponibles) {
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
                  // Afficher une erreur si le nombre de places est invalide
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez saisir un nombre de places valide.')));
                } else if (placesReservees > nombrePlacesDisponibles) {
                  // Afficher une erreur si le nombre de places réservées dépasse le nombre de places disponibles
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le nombre de places réservées dépasse le nombre de places disponibles.')));
                } else {
                  // Effectuer l'action de réservation
                  _reservePlaces(trajetId, placesReservees, nombrePlacesDisponibles);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Réserver'),
            ),
          ],
        );
      },
    );
  }

  void _reservePlaces(String trajetId, int placesReservees, int nombrePlacesDisponibles) async {
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
            String depart = trajetData['depart'];
            String destination = trajetData['destination'];
            String date = trajetData['date'];
            String heure = trajetData['heure'];
            String numeroTelephone = trajetData['numeroTelephone'];

            // Mettre à jour le nombre de places disponibles dans la base de données Firestore
            await FirebaseFirestore.instance.collection('trajets').doc(trajetId).update({
              'nombrePlaces': nombrePlacesDisponibles - placesReservees,
            });

            // Enregistrer le trajet réservé dans la collection 'trajetreserver'
            await FirebaseFirestore.instance.collection('trajetreserver').add({
              'trajetId': trajetId,
              'userId': user.uid, // ID de l'utilisateur qui réserve
              'driverId': driverId, // ID du conducteur récupéré directement du document du trajet
              'depart': depart,
              'destination': destination,
              'date': date,
              'heure': heure,
              'placesReservees': placesReservees,
              'numeroTelephone': numeroTelephone,
              'timestamp': FieldValue.serverTimestamp(),
              // Optionnel : ajoute la date et l'heure de la réservation
            });

            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Places réservées avec succès.')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ID du conducteur non trouvé. Veuillez réessayer.')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Trajet introuvable. Veuillez réessayer.')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Utilisateur non connecté.')));
      }
    } catch (e) {
      print('Erreur lors de la réservation des places: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la réservation des places. Veuillez réessayer.')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        itemCount: trajets.length,
        itemBuilder: (context, index) {
          final trajet = trajets[index];
          final depart = trajet['depart'];
          final destination = trajet['destination'];
          final heure = trajet['heure'];
          final nombrePlaces = trajet['nombrePlaces'];
          final date = trajet['date'];
          final numeroTelephone = trajet['numeroTelephone'];
          final id = trajet['id']; // Récupérer l'ID du trajet
      
          // Vérifier si le nombre de places est supérieur à zéro avant d'afficher le trajet
          if (nombrePlaces > 0) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  // Action à effectuer lorsqu'une carte est cliquée
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrajetDetailsPage(trajet: trajet),
                    ),
                  );
                },
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
                              'Depart: $depart',
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
                              'Destination: $destination',
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
                              'Date: $date',
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
                              'Heure: $heure',
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
                              'Places: $nombrePlaces',
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
                              'Numero: $numeroTelephone',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Action pour réserver le trajet
                        _showReservationDialog(trajet['id'], trajet['nombrePlaces']);
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
                  ),
                ),
              ),
            );
          } else {
            // Si le nombre de places est égal à zéro, retourner un widget vide
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
