import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yango_faso/home/resultat_recherche.dart';

class SearchSection extends StatefulWidget {
  @override
  _SearchSectionState createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _heureController = TextEditingController();
  final TextEditingController _placesController = TextEditingController();

  bool _isLoading = false;  // Variable d'état pour le chargement

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                controller: _departController,
                decoration: InputDecoration(
                  labelText: 'Départ',
                  hintText: 'Entrez le départ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le lieu de départ svp!';
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
                  return 'Veuillez entrer la destination svp!';
                }
                return null;
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
                  return 'Veuillez entrer la date svp!';
                }
                return null;
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
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: _isLoading ? null : () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;  // Début du chargement
                    });
                    searchTrajets(context);
                  }
                },
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Rechercher',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void searchTrajets(BuildContext context) {
    String depart = _departController.text;
    String destination = _destinationController.text;

    // Requête Firestore pour rechercher les trajets
    FirebaseFirestore.instance
        .collection('trajets')
        .where('depart', isEqualTo: depart)
        .where('destination', isEqualTo: destination)
        .get()
        .then((querySnapshot) {
      List<Map<String, dynamic>> results = [];
      querySnapshot.docs.forEach((doc) {
        results.add(doc.data());
      });

      // Naviguer vers la page des résultats avec les résultats de la recherche
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(results: results),
        ),
      );
    }).catchError((error) {
      print('Erreur lors de la recherche des trajets: $error');
      showErrorDialog(context, 'Erreur lors de la recherche des trajets: $error');
    }).whenComplete(() {
      setState(() {
        _isLoading = false;  // Fin du chargement
      });
    });
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
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
