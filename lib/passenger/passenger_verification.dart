import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:yango_faso/home/bar_de_navigation.dart';

class AccountVerificationPage extends StatefulWidget {
  @override
  _AccountVerificationPageState createState() =>
      _AccountVerificationPageState();
}

class _AccountVerificationPageState extends State<AccountVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();

  XFile? _idCardImage;
  XFile? _vehicleCardImage;
  XFile? _vehicleImage;
  XFile? _insuranceImage;

  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source, Function(XFile?) setImage) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setImage(pickedFile);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _idCardImage != null &&
        _vehicleCardImage != null &&
        _vehicleImage != null &&
        _insuranceImage != null) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        String idCardUrl = await _uploadFile(_idCardImage!);
        String vehicleCardUrl = await _uploadFile(_vehicleCardImage!);
        String vehicleImageUrl = await _uploadFile(_vehicleImage!);
        String insuranceImageUrl = await _uploadFile(_insuranceImage!);

        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance.collection('verification').add({
            'userId': user.uid,
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'registrationNumber': _registrationNumberController.text,
            'idCardUrl': idCardUrl,
            'vehicleCardUrl': vehicleCardUrl,
            'vehicleImageUrl': vehicleImageUrl,
            'insuranceImageUrl': insuranceImageUrl,
            'timestamp': FieldValue.serverTimestamp(),
            'status': false, // Ajout du champ status initialisé à false
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Formulaire envoyé avec succès')));

          // Redirection vers la page de profil après succès avec un délai
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BarDeNavigation()), // Remplacez avec votre page de profil
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Utilisateur non connecté')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de l\'envoi du formulaire: $e')));
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Veuillez remplir tous les champs et télécharger toutes les images')));
    }
  }

  Future<String> _uploadFile(XFile file) async {
    File fileToUpload = File(file.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = storageReference.putFile(fileToUpload);
    await uploadTask.whenComplete(() => null);
    return await storageReference.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Vérification de compte',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _registrationNumberController,
                  decoration: InputDecoration(
                    labelText: 'Matricule du véhicule',
                    prefixIcon: Icon(Icons.directions_car, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le matricule du véhicule';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text('Charger votre permis:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _idCardImage == null
                    ? Text('Pas d\'image sélectionnée.')
                    : Image.file(File(_idCardImage!.path),
                        width: 200, height: 150, fit: BoxFit.cover),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery,
                      (image) => setState(() => _idCardImage = image)),
                  icon: Icon(Icons.upload_file),
                  label: Text('Sélectionnez l\'image de votre permis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Charger la carte grise du véhicule:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _vehicleCardImage == null
                    ? Text('Pas d\'image sélectionnée.')
                    : Image.file(File(_vehicleCardImage!.path),
                        width: 300, height: 200, fit: BoxFit.cover),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery,
                      (image) => setState(() => _vehicleCardImage = image)),
                  icon: Icon(Icons.upload_file),
                  label: Text('Sélectionnez l\'image de la carte grise'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Charger l\'image du véhicule:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _vehicleImage == null
                    ? Text('Pas d\'image sélectionnée.')
                    : Image.file(File(_vehicleImage!.path),
                        width: 300, height: 200, fit: BoxFit.cover),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery,
                      (image) => setState(() => _vehicleImage = image)),
                  icon: Icon(Icons.upload_file),
                  label: Text('Sélectionnez l\'image du véhicule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Charger l\'image de votre CNI:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _insuranceImage == null
                    ? Text('Pas d\'image sélectionnée.')
                    : Image.file(File(_insuranceImage!.path),
                        width: 300, height: 200, fit: BoxFit.cover),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery,
                      (image) => setState(() => _insuranceImage = image)),
                  icon: Icon(Icons.upload_file),
                  label: Text('Sélectionnez l\'image de votre CNI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: _isSubmitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.teal),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          child: Text('Vérifier'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
