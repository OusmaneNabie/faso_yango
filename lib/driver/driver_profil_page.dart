import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yango_faso/admin/add_trip.dart';
import 'package:yango_faso/driver/add_car.dart';
import 'package:yango_faso/driver/drver_car.dart';
import 'package:yango_faso/driver/reserved_trip.dart';
import 'package:yango_faso/driver/trip_list.dart';
import 'package:yango_faso/firebase/authentification.dart';
import 'package:yango_faso/trajet/ajout_de_trajet.dart';

class DriverDashboardPage extends StatefulWidget {
  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  bool _isLoading = false;
  void _logout(BuildContext context) async {
    setState(() {
      _isLoading = true; // Mettre à jour l'état de chargement à vrai
    });

    // Logique pour la déconnexion
    try {
      await AuthentificationService.signOut(
          context); // Appeler la fonction signOut
    } catch (e) {
      print("Erreur lors de la déconnexion : $e");
    }

    // Attendez 3 secondes
    await Future.delayed(Duration(seconds: 3));

    // Mettre à jour l'état de chargement à faux après 3 secondes
    setState(() {
      _isLoading = false;
    });
  }

  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        firstName = userDoc['firstName'];
        lastName = userDoc['lastName'];
        email = userDoc['email'];
        phoneNumber = userDoc['numero'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDriverInfoCard(),
            SizedBox(height: 20),
            SizedBox(height: 20),
            _buildSectionTitle('Résumé des trajets'),
            _buildSummaryCard(
              icon: Icons.trip_origin_sharp,
              title: 'Ajouter un trajet',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTripForm()), // Remplacez `VotreNouvellePage` par le nom de votre page de destination
                );
              },
            ),

            _buildSummaryCard(
              icon: Icons.car_rental,
              title: 'Ajouter un véhicule',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddVehicleForm()), // Remplacez `VotreNouvellePage` par le nom de votre page de destination
                );
              },
            ),
            _buildSummaryCard(
              icon: Icons.takeout_dining,
              title: 'Trajets réservés',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DriverReservedRidesPage()), // Remplacez `VotreNouvellePage` par le nom de votre page de destination
                );
              },
            ),
            _buildSummaryCard(
              icon: Icons.car_repair,
              title: 'Mes véhicules',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserVehiclesPage()), // Remplacez `VotreNouvellePage` par le nom de votre page de destination
                );
              },
            ),
            _buildSectionTitle('Statistiques de performance'),
            _buildPerformanceChart(),
            _buildSectionTitle('Notifications'),
            _buildNotificationList(),
            SizedBox(height: 20), // Add some spacing before the logout button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations du conducteur',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            SizedBox(height: 16),
            _buildInfoItem('Nom', '$firstName'),
            _buildInfoItem('Prénom', '$lastName'),
            _buildInfoItem('Email', '$email'),
            _buildInfoItem('Numéro de téléphone', '$phoneNumber'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Graphique des performances',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
  return Column(
    children: [
      _buildNotificationItem(
        icon: Icons.add_road_outlined,
        title: 'Mes trajets',
        color: Colors.teal,
        onTap: () {
          // Action lorsque l'élément est tapé (par exemple, navigation vers une nouvelle page)
          // Exemple de navigation :
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DriverTripsPage()), // Remplacez `VotreNouvellePage` par le nom de votre page de destination
          );
        },
      ),
      _buildNotificationItem(
        icon: Icons.warning,
        title: 'Avis en attente',
        color: Colors.orange,
        onTap: () {
          // Action lorsque l'élément est tapé
        },
      ),
      _buildNotificationItem(
        icon: Icons.event_available,
        title: 'Trajet confirmé',
        color: Colors.blue,
        onTap: () {
          // Action lorsque l'élément est tapé
        },
      ),
    ],
  );
}

Widget _buildNotificationItem({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap, // Ajoutez VoidCallback comme paramètre
}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 36, color: color),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        
      ),
    ),
  );
}

  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _logout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // Background color
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        icon: Icon(Icons.logout, color: Colors.white),
        label: Text('Déconnexion',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
