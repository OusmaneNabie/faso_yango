import 'package:flutter/material.dart';
import 'package:yango_faso/authentification/sign_in.dart';
import 'package:yango_faso/authentification/sign_up.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        width: 350, // Largeur souhaitée du cadre
        height: 300, // Hauteur souhaitée du cadre
        child: Card(
          elevation: 4, // Ajustez l'élévation selon vos préférences
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: const TextSpan(
                    text: "Connectez vous pour avoir plus d'options sur notre plateforme",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(230, 0, 0, 0),
                      
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Sets the button's main color
                    foregroundColor: Colors.white,
                    // Sets the color of text and icons when they are displayed on top of the primary color
                    shadowColor: Colors.black, // Sets the color of the shadow
                    elevation: 5, // Sets the elevation of the button
                    padding: EdgeInsets.all(
                        16), // Sets the padding around the button's content
                    minimumSize: const Size(250, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignInPage(),
                      ),
                    ); // Navigate to signup page
                  },
                  child: const Text('Inscription'),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Sets the button's main color
                    foregroundColor: Colors.white,
                    // Sets the color of text and icons when they are displayed on top of the primary color
                    shadowColor: Colors.black, // Sets the color of the shadow
                    elevation: 5, // Sets the elevation of the button
                    padding: EdgeInsets.all(
                        16), // Sets the padding around the button's content
                    minimumSize: const Size(250, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginPage(),
                      ),
                    ); // Navigate to login page
                  },
                  child: const Text('Connexion'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}