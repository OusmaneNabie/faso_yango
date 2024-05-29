import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yango_faso/authentification/sign_in.dart';
import 'package:yango_faso/firebase/authentification.dart';
import 'package:yango_faso/home/bar_de_navigation.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _numeroController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = await _authService.signUpWithEmailAndPassword(
        context,
        _emailController.text,
        _passwordController.text,
        _nomController.text,
        _prenomController.text,
        _numeroController.text,
        'passager',
      );

      await Future.delayed(Duration(seconds: 3));

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BarDeNavigation(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription',
         style: TextStyle(
          fontWeight: FontWeight.bold,
          color:Colors.white
          )
          ),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: 'logo',
                      child: Icon(Icons.person_add, size: 100, color: Colors.teal),
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _nomController,
                      labelText: 'Nom',
                      hintText: 'Entrez votre nom',
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre nom' : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextFormField(
                      controller: _prenomController,
                      labelText: 'Prénom',
                      hintText: 'Entrez votre prénom',
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre prénom' : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextFormField(
                      controller: _numeroController,
                      labelText: 'Numéro',
                      hintText: 'Entrez votre numéro',
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre numéro' : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre email' : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextFormField(
                      controller: _passwordController,
                      labelText: 'Mot de passe',
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre mot de passe' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 5,
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _handleSignUp,
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Inscription', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 20),
                    const Text('ou connectez-vous avec:', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(FontAwesomeIcons.facebook, Colors.blue, () {
                          // Implémentez la logique de connexion avec Facebook ici
                        }),
                        const SizedBox(width: 20),
                        _buildSocialButton(FontAwesomeIcons.google, Colors.red, () {
                          // Implémentez la logique de connexion avec Google ici
                        }),
                        const SizedBox(width: 20),
                        _buildSocialButton(FontAwesomeIcons.apple, Colors.black, () {
                          // Implémentez la logique de connexion avec iCloud ici
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Vous avez déjà un compte?"),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildSocialButton(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, color: Colors.white, size: 25),
      ),
    );
  }
}
