import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverReservedRidesPage extends StatefulWidget {
  @override
  _DriverReservedRidesPageState createState() => _DriverReservedRidesPageState();
}

class _DriverReservedRidesPageState extends State<DriverReservedRidesPage> {
  List<Map<String, dynamic>> reservedTrajets = [];
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    fetchReservedTrajets();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> fetchReservedTrajets() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && _isMounted) {
        String userId = user.uid;

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('trajetreserver')
            .where('userId', isEqualTo: userId)
            .get();

        if (_isMounted) {
          setState(() {
            reservedTrajets = querySnapshot.docs.map((doc) {
              Map<String, dynamic> trajetData = doc.data() as Map<String, dynamic>;
              trajetData['id'] = doc.id; // Ajouter l'ID du document Firestore
              return trajetData;
            }).toList();
          });
        }
      } else {
        print('Utilisateur non connecté.');
      }
    } catch (e) {
      if (_isMounted) {
        print('Erreur lors de la récupération des trajets réservés: $e');
      }
    }
  }

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes trajets réservés par les passagers'),
        backgroundColor: Colors.teal,
      ),
      body: reservedTrajets.isEmpty
          ? Center(
              child: Text('Aucun trajet réservé pour l\'instant.'),
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
                          Text('Départ: $depart', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Destination: $destination', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Date: $date', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Heure: $heure', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Places réservées: $placesReservees', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Numéro du conducteur: $numeroTelephone', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
