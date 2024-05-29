import 'package:flutter/material.dart';
import 'package:yango_faso/firebase/gestion_de_trajet.dart';

class AddTripForm extends StatefulWidget {
  @override
  State<AddTripForm> createState() => _AddTripFormState();
}

class _AddTripFormState extends State<AddTripForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _departController = TextEditingController();

  final TextEditingController _destinationController = TextEditingController();

  final TextEditingController _dateController = TextEditingController();

  final TextEditingController _heureController = TextEditingController();

  final TextEditingController _nombrePlacesController = TextEditingController();

  final TextEditingController _numeroController = TextEditingController();

  // Créer une instance de TrajetService
  final TrajetService _trajetService = TrajetService();

  bool _isPosting = false; 
 // Booléen pour contrôler la visibilité du cercle de progression
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un Trajet'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Formulaire d\'ajout de trajet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: _departController,
                      decoration: InputDecoration(
                        labelText: 'Point de départ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le point de départ';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        labelText: 'Destination',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la destination';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la date';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _heureController,
                      decoration: InputDecoration(
                        labelText: 'Heure',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer l\'heure';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nombrePlacesController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de places disponibles',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event_seat),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nombre de places disponibles';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _numeroController,
                      decoration: InputDecoration(
                        labelText: 'Numéro du conducteur',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le numéro du conducteur';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: _isPosting ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              // Activer la visibilité du cercle de progression
                              setState(() {
                                _isPosting = true;
                              });
        
                              // Appeler la méthode publierTrajet
                              await _trajetService.publierTrajet(
                                depart: _departController.text,
                                destination: _destinationController.text,
                                date: _dateController.text,
                                heure: _heureController.text,
                                nombrePlaces: int.parse(_nombrePlacesController.text),
                                telephone: _numeroController.text,
                                context: context, // Passer le contexte pour afficher la boîte de dialogue
                              );
        
                              // Désactiver la visibilité du cercle de progression après 3 secondes
                              Future.delayed(Duration(seconds: 3), () {
                                setState(() {
                                  _isPosting = false;
                                });
                              });
                            }
                          },
                      child: _isPosting ? _buildProgressIndicator(): Text('Ajouter le Trajet'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildProgressIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }
}
