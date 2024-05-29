import 'package:flutter/material.dart';
import 'package:yango_faso/home/widgets/recherche.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 500,
              height: 300,
              child: Image.asset('assets/images/bgimg1.jpg'),
            ),
            Container(
              child:Center(
                child: Container(
                  child: SearchSection(),
                ),

              ),
            ),
            
          ],
        ),
      ),   
    );
  }
}

