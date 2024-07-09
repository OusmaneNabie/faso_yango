import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yango_faso/admin/admin_profil.dart';
import 'package:yango_faso/driver/driver_profil_page.dart';
import 'package:yango_faso/driver/profil_scroll.dart';
import 'package:yango_faso/firebase/authentification.dart';
import 'package:yango_faso/home/accueil.dart';
import 'package:yango_faso/notification/notification.dart';
import 'package:yango_faso/notification/passenger_notif.dart';
import 'package:yango_faso/passenger/profil_screen.dart';
import 'package:yango_faso/trajet/ajout_de_trajet.dart';
import 'package:yango_faso/trajet/liste_de_trajets.dart';

class BarDeNavigation extends StatefulWidget {
  const BarDeNavigation({Key? key});

  @override
  State<BarDeNavigation> createState() => _BarDeNavigationState();
}

class _BarDeNavigationState extends State<BarDeNavigation> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int _currentIndex = 0;
  late String roleUtilisateur = 'passager'; // Initialisation avec une valeur par défaut

  // Méthode pour récupérer le rôle de l'utilisateur
  Future<void> _getUserRole() async {
    AuthentificationService _authService = AuthentificationService();
    User? user = await _authService.getCurrentUser(); // Attendre la résolution de la méthode getCurrentUser()
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          roleUtilisateur = userData.data()?['role'] ?? 'passager';
        });
      }
    }
  }

  setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  // Méthode pour obtenir la page de profil en fonction du rôle de l'utilisateur
  Widget _getProfilePage() {
    switch (roleUtilisateur) {
      case 'passager':
        return UserProfileAndManagementPage();
      case 'conducteur':
        return DriverProfileManagement();
      case 'admin':
        return AdminDashboardPage();
      default:
        return SizedBox(); // Retourne une boîte vide par défaut si le rôle n'est pas reconnu
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(
            [
              "Recherche",
              "Publier un trajet",
              "Trajets disponibles",
              "Notifications",
              "Profil"
            ][_currentIndex],
            style:const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: [
          MyHomePage(),
          TripPostingPage(),
          PublishedRidesPage(),
          roleUtilisateur == 'passager' ? PassengerNotificationPage() : NotificationPage(),
          _getProfilePage(),
        ][_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1 && roleUtilisateur == 'passager') {
              _showPassengerDialog(context);
            } else {
              setCurrentIndex(index);
            }
          },
          showUnselectedLabels: true,
          selectedItemColor: Colors.teal,
          selectedFontSize: 16,
          unselectedFontSize: 12,
          unselectedItemColor: Colors.grey.withOpacity(0.7),
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          items: const [
            BottomNavigationBarItem(
              label: 'Recherche',
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              label: 'Publier',
              icon: Icon(Icons.add),
            ),
            BottomNavigationBarItem(
              label: 'Vos trajets',
              icon: Icon(Icons.directions_car),
            ),
            BottomNavigationBarItem(
              label: 'Notifications',
              icon: Icon(Icons.notifications_active),
            ),
            BottomNavigationBarItem(
              label: 'Profil',
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher une boîte de dialogue pour les passagers
  void _showPassengerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Action non autorisée'),
          content: Text('En tant que passager, vous ne pouvez pas publier un trajet. Pour pouvoir le faire, veuillez procéder à une vérification dans le poste de police de votre localité.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
