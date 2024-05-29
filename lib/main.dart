import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:yango_faso/authentification/log_or_signin.dart';
import 'package:yango_faso/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LogSinPage(),
    );
  }
}
