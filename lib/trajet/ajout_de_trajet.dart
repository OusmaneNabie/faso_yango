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

  final TrajetService _trajetService = TrajetService();
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextFormField(
                  controller: _departController,
                  labelText: 'Départ',
                  hintText: 'Entrez le départ',
                  icon: Icons.location_on,
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _destinationController,
                  labelText: 'Destination',
                  hintText: 'Entrez la destination',
                  icon: Icons.location_city,
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _dateController,
                  labelText: 'Date',
                  hintText: 'Entrez la date',
                  icon: Icons.date_range,
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _heureController,
                  labelText: "Entrez l'heure",
                  hintText: "Entrez l'heure",
                  icon: Icons.access_time,
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _nombrePlacesController,
                  labelText: 'Nombre de places',
                  hintText: 'Entrez le nombre de places',
                  icon: Icons.event_seat,
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _numeroController,
                  labelText: 'Numéro de téléphone',
                  hintText: 'Entrez le numéro de téléphone',
                  icon: Icons.phone,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // couleur de fond teal pour le bouton
                  ),
                  onPressed: _isPosting
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isPosting = true;
                            });

                            await _trajetService.publierTrajet(
                              depart: _departController.text,
                              destination: _destinationController.text,
                              date: _dateController.text,
                              heure: _heureController.text,
                              nombrePlaces: int.parse(_nombrePlacesController.text),
                              telephone: _numeroController.text,
                              context: context,
                            );

                            Future.delayed(Duration(seconds: 3), () {
                              setState(() {
                                _isPosting = false;
                              });
                            });
                          }
                        },
                  child: _isPosting
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Publier',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(40),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }
}
