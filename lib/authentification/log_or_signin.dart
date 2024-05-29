import 'package:flutter/material.dart';
import 'package:yango_faso/authentification/widget/log_or_sign_widget.dart';

class LogSinPage extends StatefulWidget {
  const LogSinPage({super.key});

  @override
  State<LogSinPage> createState() => _LogSinPageState();
}

class _LogSinPageState extends State<LogSinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
       body: SingleChildScrollView(
        child: Stack(
          children: [
             Container(
              width: double.infinity,
               child:
                Image.asset('assets/images/bgimg1.jpg'),
             ),
            Padding(
              padding: const EdgeInsets.only(top:60),
              child: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WelcomePage(),
                    ],
                  ),
                ),
              ),
            )
            ],
            ), 
       ),
       
    );
  }
}