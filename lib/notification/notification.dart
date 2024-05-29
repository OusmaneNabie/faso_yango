import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yango_faso/notification/detail_notif.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('trajetreserver')
                  .where('driverId', isEqualTo: _user?.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: ${snapshot.error}')),
                  );
                  return SizedBox.shrink();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('Aucune nouvelle réservation.');
                }
                return Column(
                  children: snapshot.data!.docs.map((reservation) {
                    Map<String, dynamic> data = reservation.data() as Map<String, dynamic>;
                    String passengerId = data['userId'];
                    String depart = data['depart'];
                    String destination = data['destination'];
                    int placesReservees = data['placesReservees'];

                    return NotificationItem(
                      title: 'Nouvelle réservation',
                      subtitle: 'Vous avez reçu une nouvelle réservation de $placesReservees places pour le trajet de $depart à $destination.',
                      icon: Icons.notifications_active,
                      time: 'Il y a ${DateTime.now().difference(data['timestamp'].toDate()).inHours} heures',
                      onPressed: () async {
                        // Effectuer une requête pour obtenir les détails du passager
                        DocumentSnapshot passengerSnapshot = await FirebaseFirestore.instance.collection('users').doc(passengerId).get();
                        if (passengerSnapshot.exists) {
                          Map<String, dynamic> passengerData = passengerSnapshot.data() as Map<String, dynamic>;
                          String firstName = passengerData['firstName'];
                          String lastName = passengerData['lastName'];
                          String passengerEmail = passengerData['email'];
                          String passengerPhoneNumber = passengerData['numero'];

                          // Naviguer vers la page des détails du passager
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PassengerDetailsPage(
                                passenger: Passenger(
                                  id: passengerId,
                                  firstName: firstName,
                                  lastName: lastName,
                                  email: passengerEmail,
                                  phoneNumber: passengerPhoneNumber,
                                ),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Les détails du passager ne peuvent pas être récupérés.')),
                          );
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String time;
  final VoidCallback onPressed;

  const NotificationItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.time,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    time,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
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
class Passenger {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  Passenger({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });
}
