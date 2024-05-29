import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserVehiclesPage extends StatefulWidget {
  @override
  _UserVehiclesPageState createState() => _UserVehiclesPageState();
}

class _UserVehiclesPageState extends State<UserVehiclesPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _registrationController = TextEditingController();

  String? _vehicleIdToEdit;

  void _editVehicle(Map<String, dynamic> vehicleData, String vehicleId) {
    setState(() {
      _brandController.text = vehicleData['brand'];
      _modelController.text = vehicleData['model'];
      _yearController.text = vehicleData['year'];
      _colorController.text = vehicleData['color'];
      _registrationController.text = vehicleData['registration'];
      _vehicleIdToEdit = vehicleId;
    });
  }

  void _updateVehicle() async {
    if (_formKey.currentState!.validate()) {
      final vehicleData = {
        'brand': _brandController.text,
        'model': _modelController.text,
        'year': _yearController.text,
        'color': _colorController.text,
        'registration': _registrationController.text,
      };

      await FirebaseFirestore.instance
          .collection('vehicules')
          .doc(_vehicleIdToEdit)
          .update(vehicleData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Véhicule mis à jour avec succès!')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _vehicleIdToEdit = null;
      });
    }
  }

  void _deleteVehicle(String vehicleId) async {
    await FirebaseFirestore.instance.collection('vehicules').doc(vehicleId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Véhicule supprimé avec succès!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mes véhicules'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Text('Utilisateur non connecté.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes véhicules'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicules')
            .where('driverId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun véhicule trouvé.'));
          } else {
            final vehicles = snapshot.data!.docs;

            return ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index].data() as Map<String, dynamic>;
                final vehicleId = vehicles[index].id;

                return Card(
                  margin: EdgeInsets.all(10.0),
                  elevation: 5.0,
                  child: ListTile(
                    title: Text('${vehicle['brand']} ${vehicle['model']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Année: ${vehicle['year']}'),
                        Text('Couleur: ${vehicle['color']}'),
                        Text('Immatriculation: ${vehicle['registration']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editVehicle(vehicle, vehicleId),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteVehicle(vehicleId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: _vehicleIdToEdit != null
          ? FloatingActionButton.extended(
              onPressed: _updateVehicle,
              label: Text('Mettre à jour'),
              icon: Icon(Icons.save),
              backgroundColor: Colors.teal,
            )
          : null,
      bottomSheet: _vehicleIdToEdit != null
          ? Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _brandController,
                      decoration: InputDecoration(labelText: 'Marque'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la marque';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(labelText: 'Modèle'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le modèle';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _yearController,
                      decoration: InputDecoration(labelText: 'Année'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer l\'année';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _colorController,
                      decoration: InputDecoration(labelText: 'Couleur'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la couleur';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _registrationController,
                      decoration: InputDecoration(labelText: 'Immatriculation'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer l\'immatriculation';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}


