import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yango_faso/admin/admin_profil.dart';
import 'package:yango_faso/home/accueil.dart';
import 'package:yango_faso/trajet/detail_trajet.dart';

class AllTripsPage extends StatefulWidget {
  @override
  _AllTripsPageState createState() => _AllTripsPageState();
}

class _AllTripsPageState extends State<AllTripsPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tous les Trajets'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminDashboardPage(),
                ),
              );
            },
          ),
        ],
      ),
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

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                // Action à effectuer lorsqu'une carte est cliquée
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TrajetDetailsPage(trajet: trajet), // Remplacez MyHomePage par votre page souhaitée
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
