import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yango_faso/admin/add_admin.dart';
import 'package:yango_faso/admin/add_driver.dart';
import 'package:yango_faso/admin/add_passenger.dart';
import 'package:yango_faso/admin/add_trip.dart';
import 'package:yango_faso/admin/admin_list.dart';
import 'package:yango_faso/admin/driver_liste.dart';
import 'package:yango_faso/admin/liste_car.dart';
import 'package:yango_faso/admin/passenger_list.dart';
import 'package:yango_faso/admin/trip_list.dart';
import 'package:yango_faso/firebase/authentification.dart';

class AdminDashboardPage extends StatefulWidget {
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = false;
  int totalUsers = 0;
  int totalTrips = 0;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  void _logout(BuildContext context) async {
    setState(() {
      _isLoading = true; // Mettre à jour l'état de chargement à vrai
    });

    // Logique pour la déconnexion
    try {
      await AuthentificationService.signOut(context); // Appeler la fonction signOut
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

  Future<void> fetchStatistics() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance.collection('trajets').get();

      setState(() {
        totalUsers = usersSnapshot.docs.length;
        totalTrips = tripsSnapshot.docs.length;
      });
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
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
            _buildSectionTitle('Tableau de bord '),
            SizedBox(height: 20),
            _buildSectionTitle('Statistiques'),
            _buildStatisticsGrid(),
            SizedBox(height: 20),
            _buildSectionCard('Gestion des Utilisateurs', _buildUserManagementSection()),
            SizedBox(height: 20),
            _buildSectionCard('Gestion des Trajets', _buildTripManagementSection()),
            SizedBox(height: 20),
            _buildSectionCard('Support et Tickets', _buildSupportSection()),
            SizedBox(height: 20),
            _buildSectionCard('Gestion Financière', _buildFinancialSection()),
            SizedBox(height: 20),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildScrollableStatisticCard(Icons.directions_car, 'Trajets actifs', totalTrips.toString(), Colors.blue),
        _buildScrollableStatisticCard(Icons.check_circle, 'Trajets terminés', '450', Colors.green),
        _buildScrollableStatisticCard(Icons.person, 'Utilisateurs actifs', totalUsers.toString(), Colors.orange),
        _buildScrollableStatisticCard(Icons.attach_money, 'Revenus générés', '\$25,000', Colors.purple),
      ],
    );
  }

  Widget _buildScrollableStatisticCard(IconData icon, String title, String value, Color color) {
    return SingleChildScrollView(
      child: _buildStatisticCard(icon, title, value, color),
    );
  }

  Widget _buildStatisticCard(IconData icon, String title, String value, Color color) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: color),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(
              value,
              style: TextStyle(fontSize: 24, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 8.0),
            content,
          ],
        ),
      ),
    );
  }
Widget _buildUserManagementSection() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        Icon(Icons.arrow_back_ios), // Flèche de gauche
        SizedBox(width: 10),
        _buildIconButton(Icons.group, 'Passagers', Colors.teal, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PassengerListPage()),
          );
        }),
        SizedBox(width: 20),
        _buildIconButton(Icons.person_add, 'passager', Colors.purple, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPassengerForm()),
          );
        }),
        SizedBox(width: 20),
        _buildIconButton(Icons.group, 'Conducteurs', Colors.teal, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DriverListPage()),
          );
        }),
        SizedBox(width: 20),
        _buildIconButton(Icons.person_add, 'Conducteur', Colors.purple, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddDriverForm()),
          );
        }),
        SizedBox(width: 20),
        _buildIconButton(Icons.group, 'Administrateurs', Colors.teal, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminListPage()),
          );
        }),
        SizedBox(width: 20),
        _buildIconButton(Icons.person_add, 'Administrateur', Colors.purple, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddAdminForm()),
          );
        }),
        SizedBox(width: 10),
        Icon(Icons.arrow_forward_ios), // Flèche de droite
      ],
    ),
  );
}

Widget _buildTripManagementSection() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        Icon(Icons.arrow_back_ios), // Flèche de gauche
        SizedBox(width: 10),
        _buildIconButton(Icons.directions_car, 'Liste des trajets', Colors.teal, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AllTripsPage()),
          );
        }),
        SizedBox(width: 20),
        _buildIconButton(Icons.add, 'ajouter un trajet', Colors.purple, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTripForm()),
          );
        }),
        SizedBox(width: 20),
        _buildIconButton(Icons.add, 'Liste des vehicules', Colors.yellow, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VehicleListPage()),
          );
        }),
        SizedBox(width: 10),
        Icon(Icons.arrow_forward_ios), // Flèche de droite
      ],
    ),
  );
}



  Widget _buildSupportSection() {
    return Row(
      children: [
        _buildIconButton(Icons.support_agent, 'Voir les tickets de support', Colors.orange, () {
          // Action pour voir la liste des tickets de support
        }),
      ],
    );
  }

  Widget _buildFinancialSection() {
    return Row(
      children: [
        _buildIconButton(Icons.attach_money, 'Voir les transactions', Colors.green, () {
          // Action pour voir les transactions financières
        }),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () =>  _logout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // Background color
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        icon: Icon(Icons.logout, color: Colors.white),
        label: Text('Déconnexion', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
