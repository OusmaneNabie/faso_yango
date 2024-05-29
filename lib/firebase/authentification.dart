import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yango_faso/authentification/widget/log_or_sign_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//*****************************GESTION DE L'INSCRIPTION*********************************** */
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailAndPassword(BuildContext context, String email, String password, String firstName, String lastName, String numero, String role) async {
    try {
      // Vérifier la longueur minimale du mot de passe
      if (password.length < 8) {
        _showErrorDialog(context, 'Le mot de passe doit contenir au moins 8 caractères');
        return null;
      }

      // Vérifier si l'e-mail est dans un format valide
      if (!isValidEmail(email)) {
        _showErrorDialog(context, "L\'e-mail n'est pas dans un format valide");
        return null;
      }

      // Créer un nouvel utilisateur avec l'e-mail et le mot de passe
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupérer l'UID de l'utilisateur
      String uid = userCredential.user!.uid;
       
       // Récupérer le token FCM de l'appareil
    String fcmToken = await _retrieveFCMToken();
      // Ajouter les informations supplémentaires à Firestore
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'numero': numero, // Champ pour le numéro
        'role': role, // Rôle par défaut
        'token': fcmToken, // Ajouter le token FCM
      });
       
      // Afficher une boîte de dialogue pour informer l'utilisateur que l'inscription a réussi
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Inscription réussie'),
            content: Text('Votre inscription a été effectuée avec succès.'),
            actions: <Widget>[
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

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs spécifiques à FirebaseAuth
      _showErrorDialog(context, e.message ?? 'Une erreur s\'est produite lors de l\'inscription');
      return null;
    } catch (e) {
      _showErrorDialog(context, 'Une erreur s\'est produite lors de l\'inscription: $e');
      return null;
    }
  }

  bool isValidEmail(String email) {
    // Expression régulière pour vérifier si l'e-mail est dans un format valide
    String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailRegex);
    return regExp.hasMatch(email);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Erreur',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
  // Fonction pour récupérer le token FCM de l'appareil
Future<String> _retrieveFCMToken() async {
  // Initialiser Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  // Récupérer le token FCM de l'appareil
  String? token = await messaging.getToken();
  return token ?? '';
}
}
//*****************************FIN DE GESTION DE L'INSCRIPTION*********************************** */


//*****************************GESTION DE LA CONNEXION*********************************** */



class AuthentificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour obtenir l'utilisateur actuellement connecté
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Connexion avec l'e-mail et le mot de passe
  Future<User?> signInWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupérer l'utilisateur connecté
      User? user = userCredential.user;

      if (user != null) {
        // Récupérer les données de l'utilisateur depuis Firestore
        DocumentSnapshot<Map<String, dynamic>> userData = await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists) {
          String role = userData.data()?['role'] ?? '';
          bool isBlocked = userData.data()?['isBlocked'] ?? false;

          if (isBlocked) {
            // Si l'utilisateur est bloqué, déconnecter et afficher un message d'erreur
            await _auth.signOut();
            _showErrorDialog(context, 'Votre compte a été bloqué. Veuillez contacter l\'administrateur.');
            return null;
          }

          // Si l'utilisateur n'est pas bloqué, continuer
          // Vous pouvez stocker le rôle de l'utilisateur dans les préférences ou le transmettre où vous en avez besoin
          return user;
        } else {
          // Si les données de l'utilisateur n'existent pas dans Firestore
          _showErrorDialog(context, 'Aucune information utilisateur trouvée');
          return null;
        }
      } else {
        // Si l'utilisateur est null
        _showErrorDialog(context, 'Utilisateur null');
        return null;
      }
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs spécifiques à FirebaseAuth
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        _showErrorDialog(context, 'Email ou mot de passe incorrect');
      } else {
        _showErrorDialog(context, 'Erreur lors de la connexion : ${e.message}');
      }
      return null;
    } catch (e) {
      // Gérer les erreurs générales
      _showErrorDialog(context, 'Une erreur s\'est produite lors de la connexion : $e');
      return null;
    }
  }

  // Vos autres méthodes...

  // Afficher une boîte de dialogue d'erreur
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
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


//***************************** FIN DE GESTION DE LA CONNEXION*********************************** */
//*****************************  GESTION DE LA DECONNEXION*********************************** */
static Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Rediriger vers la page de bienvenue après la déconnexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    } catch (e) {
      print("Erreur lors de la déconnexion : $e");
    }
  }
//***************************** FIN DE GESTION DE LA DECONNEXION*********************************** */

}



