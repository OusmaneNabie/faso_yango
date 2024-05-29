import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String destination;
  final String date;
  final String depart;
  final int places;
  final String numero;
  final String heure;

  Trip(this.id, this.destination, this.date, this.depart, this.places,
      this.heure, this.numero);
}

class DriverTripsPage extends StatefulWidget {
  @override
  _DriverTripsPageState createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<DriverTripsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Trip> trips = [];

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('trajets')
            .where('userID', isEqualTo: user.uid)
            .get();
        setState(() {
          trips = querySnapshot.docs
              .map((doc) => Trip(
                    doc.id,
                    doc['destination'],
                    doc['date'],
                    doc['depart'],
                    doc['nombrePlaces'],
                    doc['heure'],
                    doc['numeroTelephone'],
                  ))
              .toList();
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des trajets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Trajets'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Action pour ajouter un nouveau trajet
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripCard(trip);
        },
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Depart: ${trip.depart}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(
              'Destination: ${trip.destination}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Date: ${trip.date}',
              style: TextStyle(fontSize: 16),
            ),
            
            SizedBox(height: 8.0),
            Text(
              'Heure: ${trip.heure}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Nombre de places: ${trip.places}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Numero de téléphone: ${trip.numero}',
              style: TextStyle(fontSize: 16),
            ),
           
            SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditTripDialog(trip);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.visibility, color: Colors.green),
                  onPressed: () {
                    // Action pour voir les informations du trajet
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(trip);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Trip trip) {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Supprimer le trajet'),
            content: Text('Êtes-vous sûr de vouloir supprimer ce trajet ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  _deleteTrip(trip.id);
                  Navigator.of(context).pop();
                },
                child: Text('Supprimer'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTrip(String tripId) async {
    try {
      await _firestore.collection('trajets').doc(tripId).delete();
      setState(() {
        trips.removeWhere((trip) => trip.id == tripId);
      });
    } catch (e) {
      print('Erreur lors de la suppression du trajet: $e');
    }
  }

  void _showEditTripDialog(Trip trip) {
    TextEditingController departController =
        TextEditingController(text: trip.depart);
    TextEditingController destinationController =
        TextEditingController(text: trip.destination);
    TextEditingController dateController =
        TextEditingController(text: trip.date);
    TextEditingController heureController =
        TextEditingController(text: trip.heure);
    TextEditingController placesController =
        TextEditingController(text: trip.places.toString());
    TextEditingController numeroController =
        TextEditingController(text: trip.numero);

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Modifier le trajet'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: departController,
                  decoration: InputDecoration(labelText: 'Départ'),
                ),
                TextFormField(
                  controller: destinationController,
                  decoration: InputDecoration(labelText: 'Destination'),
                ),
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
                ),
                TextFormField(
                  controller: heureController,
                  decoration: InputDecoration(labelText: 'Heure'),
                ),
                TextFormField(
                  controller: placesController,
                  decoration: InputDecoration(labelText: 'Nombre de places'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: numeroController,
                  decoration: InputDecoration(labelText: 'Numéro de téléphone'),
                  keyboardType: TextInputType.phone,
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
                  _updateTrip(
                      trip.id,
                      destinationController.text,
                      dateController.text,
                      departController.text,
                      heureController.text,
                      int.parse(placesController.text),
                      numeroController.text);
                  Navigator.of(context).pop();
                },
                child: Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateTrip(String tripId, String destination, String date,
      String depart, String heure, int places, String numero) async {
    try {
      await _firestore.collection('trajets').doc(tripId).update({
        'destination': destination,
        'date': date,
        'depart': depart,
        'heure': heure,
        'nombrePlaces': places,
        'numeroTelephone': numero,
      });
      _fetchTrips(); // Met à jour la liste des trajets
    } catch (e) {
      print('Erreur lors de la mise à jour du trajet: $e');
    }
  }
}
