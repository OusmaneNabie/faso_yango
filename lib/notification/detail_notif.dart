import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yango_faso/notification/notification.dart';

class PassengerDetailsPage extends StatelessWidget {
  final Passenger passenger;

  const PassengerDetailsPage({required this.passenger});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails du Passager',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile_placeholder.png'), // Placeholder image
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  '${passenger.firstName} ${passenger.lastName}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildDetailCard(
                context,
                icon: Icons.email,
                label: 'Email',
                value: passenger.email,
              ),
              SizedBox(height: 10),
              _buildDetailCard(
                context,
                icon: Icons.phone,
                label: 'Numéro de téléphone',
                value: passenger.phoneNumber,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Action de confirmation
                      _showConfirmationDialog(context, true, passenger);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: Text('Confirmer'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Action de rejet
                      _showConfirmationDialog(context, false, passenger);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: Text('Rejeter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, bool isConfirmed, Passenger passenger) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isConfirmed ? 'Confirmer la Réservation' : 'Rejeter la Réservation'),
          content: Text(
            isConfirmed
                ? 'Êtes-vous sûr de vouloir confirmer cette réservation?'
                : 'Êtes-vous sûr de vouloir rejeter cette réservation?',
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
                Navigator.of(context).pop();
                if (isConfirmed) {
                  _confirmReservation(passenger);
                } else {
                  _rejectReservation(passenger);
                }
              },
              child: Text('Oui'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmReservation(Passenger passenger) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Récupérer les détails de la réservation
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('trajetreserver')
        .where('driverId', isEqualTo: user.uid)
        .where('userId', isEqualTo: passenger.id)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var reservation = snapshot.docs.first;
      var data = reservation.data() as Map<String, dynamic>;

      String driverId = data['driverId'];
      String passengerId = data['userId'];
      int placesReservees = data['placesReservees'];
      String depart = data['depart'];
      String destination = data['destination'];
      DocumentSnapshot<Map<String, dynamic>> driverSnapshot = await FirebaseFirestore.instance.collection('users').doc(driverId).get();
      if (driverSnapshot.exists) {
        Map<String, dynamic>? driverData = driverSnapshot.data();
        String driverFirstName = driverData?['firstName'];
        String driverLastName = driverData?['lastName'];
        String driverPhoneNumber = driverData?['numero'];

        // Ajouter une entrée dans la collection responsnotif
        await FirebaseFirestore.instance.collection('responsnotif').add({
          'driverId': driverId,
          'passengerId': passengerId,
          'placesReservees': placesReservees,
          'depart': depart,
          'destination': destination,
          'driverFirstName': driverFirstName,
          'driverLastName': driverLastName,
          'driverPhoneNumber': driverPhoneNumber,
          'status': 'confirmed',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> _rejectReservation(Passenger passenger) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Récupérer les détails de la réservation
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('trajetreserver')
        .where('driverId', isEqualTo: user.uid)
        .where('userId', isEqualTo: passenger.id)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var reservation = snapshot.docs.first;
      var data = reservation.data() as Map<String, dynamic>;

      String driverId = data['driverId'];
      String passengerId = data['userId'];
      int placesReservees = data['placesReservees'];
      String depart = data['depart'];
      String destination = data['destination'];
      DocumentSnapshot<Map<String, dynamic>> driverSnapshot = await FirebaseFirestore.instance.collection('users').doc(driverId).get();
      if (driverSnapshot.exists) {
        Map<String, dynamic>? driverData = driverSnapshot.data();
        String driverFirstName = driverData?['firstName'];
        String driverLastName = driverData?['lastName'];
        String driverPhoneNumber = driverData?['numero'];

        // Ajouter une entrée dans la collection responsnotif
        await FirebaseFirestore.instance.collection('responsnotif').add({
          'driverId': driverId,
          'passengerId': passengerId,
          'placesReservees': placesReservees,
          'depart': depart,
          'destination': destination,
          'driverFirstName': driverFirstName,
          'driverLastName': driverLastName,
          'driverPhoneNumber': driverPhoneNumber,
          'status': 'not confirmed', // Change the status to 'not confirmed'
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
