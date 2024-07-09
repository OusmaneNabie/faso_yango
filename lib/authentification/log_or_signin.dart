import 'package:flutter/material.dart';
import 'package:yango_faso/authentification/widget/log_or_sign_widget.dart';

class LogSinPage extends StatefulWidget {
  const LogSinPage({Key? key}) : super(key: key);

  @override
  State<LogSinPage> createState() => _LogSinPageState();
}

class _LogSinPageState extends State<LogSinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Road.jpg',
            fit: BoxFit.cover, // Pour couvrir toute la zone
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WelcomePage(), // Vous pouvez ajouter d'autres widgets ici
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
