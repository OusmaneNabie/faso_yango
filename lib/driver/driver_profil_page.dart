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
            _buildActionButtons(),
            SizedBox(height: 20),
            _buildSectionTitle('Résumé des trajets'),
            _buildSummaryCard(
              icon: Icons.map,
              title: 'Trajets effectués',
              value: '120',
              color: Colors.blue,
            ),
            _buildSummaryCard(
              icon: Icons.calendar_today,
              title: 'Prochains trajets',
              value: '8',
              color: Colors.orange,
            ),
            _buildSummaryCard(
              icon: Icons.monetization_on,
              title: 'Revenu total',
              value: '\$2500',
              color: Colors.green,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddTripForm()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: Text('Ajouter un trajet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  )),
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddVehicleForm()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: Text('Ajouter vehicule',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  )),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DriverReservedRidesPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: Text('Trajets réservés',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  )),
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserVehiclesPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: Text(' Mes vehicules...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  )),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DriverTripsPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: Text('Mes trajets',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              )),
        ),
      ],
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

  Widget _buildSummaryCard(
      {required IconData icon,
      required String title,
      required String value,
      required Color color}) {
    return Card(
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
                Text(
                  value,
                  style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
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
          icon: Icons.info,
          title: 'Nouvelle réservation',
          subtitle: 'Vous avez une nouvelle réservation pour demain.',
          color: Colors.teal,
        ),
        _buildNotificationItem(
          icon: Icons.warning,
          title: 'Avis en attente',
          subtitle: 'Vous avez un nouvel avis en attente de validation.',
          color: Colors.orange,
        ),
        _buildNotificationItem(
          icon: Icons.event_available,
          title: 'Trajet confirmé',
          subtitle: 'Votre prochain trajet a été confirmé par le passager.',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 36, color: color),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
