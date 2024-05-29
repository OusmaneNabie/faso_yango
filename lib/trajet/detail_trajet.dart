import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class TrajetDetailsPage extends StatefulWidget {
  final Map<String, dynamic> trajet;

  TrajetDetailsPage({required this.trajet});

  @override
  State<TrajetDetailsPage> createState() => _TrajetDetailsPageState();
}

class _TrajetDetailsPageState extends State<TrajetDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  late Future<DocumentSnapshot> userFuture;
  bool isLiked = false;
  int likesCount = 0;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userFuture =
          FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    }
    _initializeLikes();
  }

  void _initializeLikes() async {
    final trajetId = widget.trajet['id'];
    final likesSnapshot = await FirebaseFirestore.instance.collection('likes').doc(trajetId).get();
    if (likesSnapshot.exists) {
      setState(() {
        likesCount = likesSnapshot.data()!['count'];
        isLiked = likesSnapshot.data()!['usersLiked'].contains(FirebaseAuth.instance.currentUser!.uid);
      });
    }
  }

  void _toggleLike() async {
    final trajetId = widget.trajet['id'];
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final likesRef = FirebaseFirestore.instance.collection('likes').doc(trajetId);

    setState(() {
      if (isLiked) {
        likesCount--;
        isLiked = false;
        likesRef.update({
          'count': likesCount,
          'usersLiked': FieldValue.arrayRemove([userId]),
        });
      } else {
        likesCount++;
        isLiked = true;
        likesRef.set({
          'count': likesCount,
          'usersLiked': FieldValue.arrayUnion([userId]),
        }, SetOptions(merge: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final depart = widget.trajet['depart'];
    final destination = widget.trajet['destination'];
    final heure = widget.trajet['heure'];
    final date = widget.trajet['date'];
    final nombrePlaces = widget.trajet['nombrePlaces'];
    final numeroTelephone = widget.trajet['numeroTelephone'];
    final userNom = widget.trajet['userNom'];
    final userPrenom = widget.trajet['userPrenom'];
    final userId = widget.trajet['userID'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails du Trajet',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrajetHeader(
              depart: depart,
              destination: destination,
              userNom: userNom,
              userPrenom: userPrenom,
              isLiked: isLiked,
              likesCount: likesCount,
              onLikeButtonPressed: _toggleLike,
            ),
            SizedBox(height: 16.0),
            TrajetInfo(
              date: date,
              heure: heure,
              depart: depart,
              destination: destination,
            ),
            SizedBox(height: 16.0),
            TrajetItineraire(),
            SizedBox(height: 16.0),
            TrajetBookingDetails(nombrePlaces: nombrePlaces),
            SizedBox(height: 16.0),
            ContactDriver(numeroTelephone: numeroTelephone),
            SizedBox(height: 16.0),
            SendSmsToDriver(phoneNumber: numeroTelephone),
            SizedBox(height: 16.0),
            AvisSection(trajetId: widget.trajet['id']),
            SizedBox(height: 16.0),
            FutureBuilder<DocumentSnapshot>(
              future: userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('Utilisateur non trouvé.'));
                } else {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final name = userData['firstName'];
                  final surname = userData['lastName'];
                  return CommentSection(
                    commentController: _commentController,
                    name: name,
                    surname: surname,
                    trajetId: widget.trajet['id'],
                  );
                }
              },
            ),
            SizedBox(height: 16.0),
            PolicyAndSupport(),
            SizedBox(height: 16.0),
            SuggestionsSection(),
          ],
        ),
      ),
    );
  }
}

class TrajetHeader extends StatelessWidget {
  final String depart;
  final String destination;
  final String userNom;
  final String userPrenom;
  final bool isLiked;
  final int likesCount;
  final VoidCallback onLikeButtonPressed;

  TrajetHeader({
    required this.depart,
    required this.destination,
    required this.userNom,
    required this.userPrenom,
    required this.isLiked,
    required this.likesCount,
    required this.onLikeButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
  color: Colors.teal[100],
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$depart -> $destination',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person, size: 48.0),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conducteur: $userNom $userPrenom',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        Text('4.0 (200 avis)'),
                      ],
                    ),
                    Text('Véhicule: Peugeot 208, Rouge'),
                  ],
                ),
              ],
            ),
            
          ],
        ),
        Column(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                    color: isLiked ? Colors.blue : Colors.grey,
                  ),
                  onPressed: onLikeButtonPressed,
                ),
                Text('$likesCount J\'aime'),
              ],
            ),
      ],
    ),
  ),
);

  }
}

class TrajetInfo extends StatelessWidget {
  final String date;
  final String heure;
  final String depart;
  final String destination;

  TrajetInfo({
    required this.date,
    required this.heure,
    required this.depart,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(
                icon: Icons.date_range, label: 'Date de départ', value: date),
            SizedBox(height: 8.0),
            InfoRow(
                icon: Icons.access_time,
                label: 'Heure de départ',
                value: heure),
            SizedBox(height: 8.0),
            InfoRow(
                icon: Icons.location_on,
                label: 'Point de départ',
                value: depart),
            SizedBox(height: 8.0),
            InfoRow(
                icon: Icons.location_on,
                label: 'Destination',
                value: destination),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal),
        SizedBox(width: 16.0),
        Expanded(
          child: Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class TrajetItineraire extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itinéraire prévu',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 200.0,
              color: Colors.grey[300],
              child: Center(child: Text('Carte de l\'itinéraire')),
            ),
          ],
        ),
      ),
    );
  }
}

class TrajetBookingDetails extends StatelessWidget {
  final int nombrePlaces;

  TrajetBookingDetails({required this.nombrePlaces});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Réservation',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            InfoRow(
              icon: Icons.people,
              label: 'Nombre de places disponibles',
              value: nombrePlaces.toString(),
            ),
            SizedBox(height: 8.0),
            Text(
                'Pour réserver votre place, contactez le conducteur via le numéro de téléphone fourni.'),
          ],
        ),
      ),
    );
  }
}

class ContactDriver extends StatelessWidget {
  final String numeroTelephone;

  ContactDriver({required this.numeroTelephone});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contacter le conducteur',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            GestureDetector(
              onTap: () => launch('tel:$numeroTelephone'),
              child: Row(
                children: [
                  Icon(Icons.phone, color: Colors.teal),
                  SizedBox(width: 16.0),
                  Text(
                    numeroTelephone,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SendSmsToDriver extends StatelessWidget {
  final String phoneNumber;

  SendSmsToDriver({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envoyer un SMS au conducteur',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            GestureDetector(
              onTap: () => _sendSms(context),
              child: Row(
                children: [
                  Icon(Icons.message, color: Colors.teal),
                  SizedBox(width: 16.0),
                  Text(
                    phoneNumber,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendSms(BuildContext context) async {
    final url = 'sms:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Impossible d\'ouvrir l\'application SMS.'),
      ));
    }
  }
}

class AvisSection extends StatelessWidget {
  final String trajetId;

  AvisSection({required this.trajetId});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Avis des utilisateurs',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('avis')
                  .where('trajetId', isEqualTo: trajetId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucun avis disponible.'));
                } else {
                  return Column(
                    children: snapshot.data!.docs.map((document) {
                      final data = document.data() as Map<String, dynamic>;
                      final commentaire = data['commentaire'];
                      final note = data['note'];
                      final user = data['user'];
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text(user),
                        subtitle: Text(commentaire),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < note ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CommentSection extends StatelessWidget {
  final TextEditingController commentController;
  final String name;
  final String surname;
  final String trajetId;

  CommentSection({
    required this.commentController,
    required this.name,
    required this.surname,
    required this.trajetId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laisser un commentaire',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Votre commentaire',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () async {
                final commentaire = commentController.text;
                if (commentaire.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('comments').add({
                    'trajetId': trajetId,
                    'user': '$name $surname',
                    'commentaire': commentaire,
                    'note': 5, // Exemple de note, à changer selon l'implémentation
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  commentController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Commentaire ajouté !')));
                }
              },
              child: Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}

class PolicyAndSupport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Politique de confidentialité | Conditions d\'utilisation',
          style: TextStyle(decoration: TextDecoration.underline),
        ),
        SizedBox(height: 8.0),
        GestureDetector(
          onTap: () => launch('mailto:support@nomdelapplication.com'),
          child: Row(
            children: [
              Icon(Icons.support, color: Colors.teal),
              SizedBox(width: 8.0),
              Text(
                'Support: support@nomdelapplication.com',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SuggestionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Text(
            'Suggestions de trajets',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          height: 200.0, // Hauteur fixe pour la liste des suggestions
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('trajets').limit(3).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Aucun trajet suggéré.'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final depart = data['depart'];
                    final destination = data['destination'];
                    final heure = data['heure'];
                    final date = data['date'];
                    return ListTile(
                      title: Text('$depart -> $destination'),
                      subtitle: Text('Date: $date, Heure: $heure'),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

