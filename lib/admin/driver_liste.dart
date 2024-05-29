import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Driver {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  String role;
  bool isBlocked;

  Driver({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isBlocked,
  });

  factory Driver.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Driver(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      isBlocked: data['isBlocked'] ?? false,
    );
  }
}

class DriverListPage extends StatefulWidget {
  @override
  _DriverListPageState createState() => _DriverListPageState();
}

class _DriverListPageState extends State<DriverListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Driver> drivers = [];
  List<String> roles = ['conducteur', 'passager', 'administrateur'];

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'conducteur')
          .get();

      setState(() {
        drivers = querySnapshot.docs
            .map((doc) => Driver.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print("Erreur lors de la récupération des conducteurs: $e");
    }
  }

  Future<void> _editDriver(Driver driver) async {
    TextEditingController firstNameController = TextEditingController(text: driver.firstName);
    TextEditingController lastNameController = TextEditingController(text: driver.lastName);
    TextEditingController emailController = TextEditingController(text: driver.email);
    String selectedRole = driver.role;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier les informations du conducteur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'Prénom'),
              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
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
              onPressed: () async {
                try {
                  await _firestore.collection('users').doc(driver.uid).update({
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                  });
                  Navigator.of(context).pop();
                  _fetchDrivers();
                } catch (e) {
                  print("Erreur lors de la mise à jour du conducteur: $e");
                }
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _blockDriver(Driver driver) async {
    try {
      await _firestore.collection('users').doc(driver.uid).update({
        'isBlocked': true,
      });
      setState(() {
        driver.isBlocked = true;
      });
    } catch (e) {
      print("Erreur lors du blocage du conducteur: $e");
    }
  }

  Future<void> _unblockDriver(Driver driver) async {
    try {
      await _firestore.collection('users').doc(driver.uid).update({
        'isBlocked': false,
      });
      setState(() {
        driver.isBlocked = false;
      });
    } catch (e) {
      print("Erreur lors du déblocage du conducteur: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Conducteurs'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          final driver = drivers[index];
          return _buildDriverCard(driver);
        },
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(
                driver.firstName[0],
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              backgroundColor: Colors.teal,
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${driver.firstName} ${driver.lastName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    driver.email,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Rôle: ${driver.role}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _editDriver(driver);
              },
            ),
            IconButton(
              icon: Icon(Icons.block, color: Colors.red),
              onPressed: () {
                _blockDriver(driver);
              },
            ),
            if (driver.isBlocked)
              IconButton(
                icon: Icon(Icons.restore, color: Colors.green),
                onPressed: () {
                  _unblockDriver(driver);
                },
              ),
          ],
        ),
      ),
    );
  }
}


