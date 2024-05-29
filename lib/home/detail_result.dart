import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultDetails extends StatelessWidget {
  final Map<String, dynamic> trajet;

  const ResultDetails({Key? key, required this.trajet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Détails du trajet',
          style: TextStyle(color:Colors.white),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoRow(Icons.location_on, 'Départ', trajet['depart'] ?? 'N/A'),
            _buildInfoRow(Icons.location_on, 'Destination', trajet['destination'] ?? 'N/A'),
            _buildInfoRow(Icons.calendar_today, 'Date', trajet['date'] ?? 'N/A'),
            _buildInfoRow(Icons.access_time, 'Heure', trajet['heure'] ?? 'N/A'),
            _buildInfoRow(Icons.airline_seat_recline_normal, 'Places disponibles', trajet['nombrePlaces']?.toString() ?? 'N/A'),
            _buildInfoRow(Icons.phone, 'Numéro de téléphone', trajet['numeroTelephone'] ?? 'N/A'),
            _buildInfoRow(Icons.person, 'Conducteur', '${trajet['userNom']} ${trajet['userPrenom']}'),
            _buildInfoRow(Icons.directions_car, 'Véhicule', 'Peugeot 208, Rouge'), // Exemple de détails de véhicule
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showReservationDialog(context, trajet['id'], trajet['nombrePlaces']);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
              child: Text(
                'Réserver ce trajet',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          SizedBox(width: 16.0),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
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
      // Mettre à jour le nombre de places disponibles dans la base de données Firestore
      await FirebaseFirestore.instance.collection('trajets').doc(trajetId).update({
        'nombrePlaces': nombrePlacesDisponibles - placesReservees,
      });

      // Enregistrer le trajet réservé dans la collection 'trajetreserver'
      await FirebaseFirestore.instance.collection('trajetreserver').add({
        'trajetId': trajetId,
        'placesReservees': placesReservees,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Places réservées avec succès.')),
      );
    } catch (e) {
      print('Erreur lors de la réservation des places: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la réservation des places. Veuillez réessayer.')),
      );
    }
  }
}
