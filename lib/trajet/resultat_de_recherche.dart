import 'package:flutter/material.dart';
import 'package:yango_faso/home/accueil.dart';

class SearchResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> results;

  const SearchResultsPage({Key? key, required this.results, required List<Map<String, dynamic>> searchResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Résultats de la recherche'),
      ),
      body: results.isEmpty
          ? Center(
              child: Text(
                'Aucun trajet trouvé',
                style: TextStyle(fontSize: 20.0),
              ),
            )
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                // Affichez les détails du trajet ici
                return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              
              child: Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.teal),
                          SizedBox(width: 8), // Ajouter un espacement horizontal de 8 pixels
                          Text(
                            'Depart: ${result['depart']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      SizedBox(height: 8), // Ajouter un espacement vertical de 8 pixels
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.teal),
                          SizedBox(width: 8), // Ajouter un espacement horizontal de 8 pixels
                          Text(
                            'Destination: ${result['destination']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8), // Ajouter un espacement vertical de 8 pixels
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.teal),
                          SizedBox(width: 8), // Ajouter un espacement horizontal de 8 pixels
                          Text(
                            'Date: ${result['date']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      SizedBox(height: 8), // Ajouter un espacement vertical de 8 pixels
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.teal),
                          SizedBox(width: 8), // Ajouter un espacement horizontal de 8 pixels
                          Text(
                            'Heure: ${result['heure']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      SizedBox(height: 8), // Ajouter un espacement vertical de 8 pixels
                      Row(
                        children: [
                          Icon(Icons.airline_seat_recline_normal, color: Colors.teal),
                          SizedBox(width: 8), // Ajouter un espacement horizontal de 8 pixels
                          Text(
                            'Places: ${result['nombrePlaces']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      
                      SizedBox(height: 8), // Ajouter un espacement vertical de 8 pixels
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue),
                          SizedBox(width: 8), // Ajouter un espacement horizontal de 8 pixels
                          Text(
                            'Numéro: ${result['numeroTelephone']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Action pour réserver le trajet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.teal),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(horizontal: 16.0), // Ajouter une marge horizontale de 16 pixels
                      ),
                    ),
                    child: Text(
                      'Réserver',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          );
              },
            ),
    );
  }
}
