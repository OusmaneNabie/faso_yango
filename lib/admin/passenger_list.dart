import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Passenger {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  String role;
  bool isBlocked;

  Passenger({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isBlocked,
  });

  factory Passenger.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Passenger(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      isBlocked: data['isBlocked'] ?? false,
    );
  }
}

class PassengerListPage extends StatefulWidget {
  @override
  _PassengerListPageState createState() => _PassengerListPageState();
}

class _PassengerListPageState extends State<PassengerListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Passenger> passengers = [];
  List<String> roles = ['conducteur', 'passager', 'administrateur'];

  @override
  void initState() {
    super.initState();
    _fetchPassengers();
  }

  Future<void> _fetchPassengers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'passager')
          .get();

      setState(() {
        passengers = querySnapshot.docs
            .map((doc) => Passenger.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print("Erreur lors de la récupération des conducteurs: $e");
    }
  }

  Future<void> _editPassenger(Passenger passenger) async {
    TextEditingController firstNameController = TextEditingController(text: passenger.firstName);
    TextEditingController lastNameController = TextEditingController(text: passenger.lastName);
    TextEditingController emailController = TextEditingController(text: passenger.email);
    String selectedRole = passenger.role;

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
                  await _firestore.collection('users').doc(passenger.uid).update({
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                  });
                  Navigator.of(context).pop();
                  _fetchPassengers();
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

  Future<void> _blockPassenger(Passenger passenger) async {
    try {
      await _firestore.collection('users').doc(passenger.uid).update({
        'isBlocked': true,
      });
      setState(() {
        passenger.isBlocked = true;
      });
    } catch (e) {
      print("Erreur lors du blocage du conducteur: $e");
    }
  }

  Future<void> _unblockPassenger(Passenger passenger) async {
    try {
      await _firestore.collection('users').doc(passenger.uid).update({
        'isBlocked': false,
      });
      setState(() {
        passenger.isBlocked = false;
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
        itemCount: passengers.length,
        itemBuilder: (context, index) {
          final passenger = passengers[index];
          return _buildPassengerCard(passenger);
        },
      ),
    );
  }

  Widget _buildPassengerCard(Passenger passenger) {
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
                passenger.firstName[0],
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
                    '${passenger.firstName} ${passenger.lastName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    passenger.email,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Rôle: ${passenger.role}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _editPassenger(passenger);
              },
            ),
            IconButton(
              icon: Icon(Icons.block, color: Colors.red),
              onPressed: () {
                _blockPassenger(passenger);
              },
            ),
            if (passenger.isBlocked)
              IconButton(
                icon: Icon(Icons.restore, color: Colors.green),
                onPressed: () {
                  _unblockPassenger(passenger);
                },
              ),
          ],
        ),
      ),
    );
  }
}


