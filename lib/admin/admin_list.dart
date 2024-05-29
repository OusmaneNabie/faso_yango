import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Admin {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  String role;
  bool isBlocked;

  Admin({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isBlocked,
  });

  factory Admin.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Admin(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      isBlocked: data['isBlocked'] ?? false,
    );
  }
}

class AdminListPage extends StatefulWidget {
  @override
  _AdminListPageState createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Admin> admins = [];
  List<String> roles = ['conducteur', 'passager', 'administrateur'];

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'passager')
          .get();

      setState(() {
        admins = querySnapshot.docs
            .map((doc) => Admin.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print("Erreur lors de la récupération des conducteurs: $e");
    }
  }

  Future<void> _editAdmin(Admin admin) async {
    TextEditingController firstNameController = TextEditingController(text: admin.firstName);
    TextEditingController lastNameController = TextEditingController(text: admin.lastName);
    TextEditingController emailController = TextEditingController(text: admin.email);
    String selectedRole = admin.role;

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
                  await _firestore.collection('users').doc(admin.uid).update({
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                  });
                  Navigator.of(context).pop();
                  _fetchAdmins();
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

  Future<void> _blockAdmin(Admin admin) async {
    try {
      await _firestore.collection('users').doc(admin.uid).update({
        'isBlocked': true,
      });
      setState(() {
        admin.isBlocked = true;
      });
    } catch (e) {
      print("Erreur lors du blocage du conducteur: $e");
    }
  }

  Future<void> _unblockAdmin(Admin admin) async {
    try {
      await _firestore.collection('users').doc(admin.uid).update({
        'isBlocked': false,
      });
      setState(() {
        admin.isBlocked = false;
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
        itemCount: admins.length,
        itemBuilder: (context, index) {
          final admin = admins[index];
          return _buildAdminCard(admin);
        },
      ),
    );
  }

  Widget _buildAdminCard(Admin admin) {
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
                admin.firstName[0],
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
                    '${admin.firstName} ${admin.lastName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    admin.email,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Rôle: ${admin.role}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _editAdmin(admin);
              },
            ),
            IconButton(
              icon: Icon(Icons.block, color: Colors.red),
              onPressed: () {
                _blockAdmin(admin);
              },
            ),
            if (admin.isBlocked)
              IconButton(
                icon: Icon(Icons.restore, color: Colors.green),
                onPressed: () {
                  _unblockAdmin(admin);
                },
              ),
          ],
        ),
      ),
    );
  }
}


