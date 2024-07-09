import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yango_faso/admin/add_admin.dart';
import 'package:yango_faso/admin/add_driver.dart';
import 'package:yango_faso/admin/add_passenger.dart';
import 'package:yango_faso/admin/add_trip.dart';
import 'package:yango_faso/admin/admin_list.dart';
import 'package:yango_faso/admin/driver_liste.dart';
import 'package:yango_faso/admin/list_verification.dart';
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
      _isLoading = true;
    });

    try {
      await AuthentificationService.signOut(context);
    } catch (e) {
      print("Erreur lors de la déconnexion : $e");
    }

    await Future.delayed(Duration(seconds: 3));

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
      appBar: AppBar(
        title: Text('Tableau de bord Admin'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Statistiques'),
            _buildStatisticsGrid(),
            _buildSectionTitle('Gestion'),
            _buildManagementGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatisticCard(Icons.person, 'Utilisateurs', totalUsers.toString(), Colors.orange),
            _buildStatisticCard(Icons.directions_car, 'Trajets', totalTrips.toString(), Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCard(IconData icon, String title, String value, Color color) {
    return Column(
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
    );
  }

  Widget _buildManagementGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildManagementCard(Icons.group, 'Utilisateurs', Colors.teal, _buildUserManagementSection),
        _buildManagementCard(Icons.directions_car, 'Trajets', Colors.blue, _buildTripManagementSection),
        _buildManagementCard(Icons.group_add, 'Gestion', Colors.orange, _buildSupportSection),
        _buildManagementCard(Icons.verified_user, 'Verifications', Colors.green, _buildFinancialSection),
      ],
    );
  }

  Widget _buildManagementCard(IconData icon, String title, Color color, Widget Function(BuildContext) contentBuilder) {
  return Card(
    elevation: 8,
    margin: EdgeInsets.all(8.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: color,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0),
                  contentBuilder(context),
                  SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Fermer',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildUserManagementSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(Icons.group, 'Passagers', Colors.blue, () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PassengerListPage()),
          );
        }),
        
        SizedBox(height: 10),
        _buildIconButton(Icons.group, 'Conducteurs', Colors.teal, () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DriverListPage()),
          );
        }),
        
        SizedBox(height: 10),
        _buildIconButton(Icons.group, 'Administrateurs', Colors.red, () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminListPage()),
          );
        }),
        
      ],
    );
  }

  Widget _buildTripManagementSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(Icons.directions_car, 'Liste des trajets', Colors.teal, () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AllTripsPage()),
          );
        }),
        SizedBox(height: 10),
        _buildIconButton(Icons.add, 'Ajouter Trajet', Colors.orange, () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTripForm()),
          );
        }),
        SizedBox(height: 10),
        _buildIconButton(Icons.list, 'Liste des véhicules', Colors.yellow, () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VehicleListPage()),
          );
        }),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        _buildIconButton(Icons.person_add, 'Ajouter Admin', Colors.teal, () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddAdminForm()),
          );
        }),
        SizedBox(height: 10),
        _buildIconButton(Icons.person_add, 'Ajouter Conducteur', Colors.orange, () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddDriverForm()),
          );
        }),
        SizedBox(height: 10),
        _buildIconButton(Icons.person_add, 'Ajouter Passager', Colors.blue, () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPassengerForm()),
          );
        }),
        
      ],
    );
  }

  Widget _buildFinancialSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(Icons.verified_user, 'Verification des roles', Colors.green, () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VerificationListPage()),
          );
          // Action pour voir les transactions financières
        }),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, String label, Color color, Function onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        shadowColor: Colors.grey,
        elevation: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}



}
