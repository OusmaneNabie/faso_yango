import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yango_faso/firebase/gestion_de_trajet.dart';

class TripPostingPage extends StatefulWidget {
  const TripPostingPage({Key? key});

  @override
  State<TripPostingPage> createState() => _TripPostingPageState();
}

class _TripPostingPageState extends State<TripPostingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _heureController = TextEditingController();
  final TextEditingController _nombrePlacesController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();

  // Créer une instance de TrajetService
  final TrajetService _trajetService = TrajetService();

  bool _isPosting = false; // Booléen pour contrôler la visibilité du cercle de progression

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 4.0,
          color: Colors.white,
          margin: EdgeInsets.only(left: 20, right: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        controller: _departController,
                        decoration: InputDecoration(
                          labelText: 'Depart',
                          hintText: 'Entrez le depart',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le lieu de depart svp!';
                          }
                          return null;
                        },
                      ),
                    ),
                    TextFormField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        labelText: 'Destination',
                        hintText: 'Entrez la destination',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer le lieu de destination svp!";
                        }
                      },
                    ),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        hintText: 'Entrez la date',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer la date svp!";
                        }
                      },
                    ),
                    TextFormField(
                      controller: _heureController,
                      decoration: InputDecoration(
                        labelText: "Entrez l'heure",
                        hintText: "Entrez l'heure",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer l'heure svp!";
                        }
                      },
                    ),
                    TextFormField(
                      controller: _nombrePlacesController,
                      decoration: InputDecoration(
                        labelText: ' Entrez le nombres de Places',
                        hintText: 'Entrez le nombres de places',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer le nombre de place svp!";
                        }
                      },
                    ),
                    TextFormField(
                      controller: _numeroController,
                      decoration: InputDecoration(
                        labelText: ' Numero de telephone',
                        hintText: 'Entrez le numero de telephone',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer le numero svp!";
                        }
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal, // Background color
                          // Text color
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ), // Padding
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
                        child: _isPosting ? _buildProgressIndicator() : Text(
                          'Publier',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour afficher le cercle de progression
  Widget _buildProgressIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }
}
