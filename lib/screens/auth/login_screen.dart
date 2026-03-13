import 'package:flutter/material.dart'; // ici on a importe les composants graphiques
import 'package:sunu_task/core/constants/app_colors.dart'; //----ls couleurs---
import 'package:sunu_task/providers/auth_provider.dart'; // ---- la logique de connecxion
import 'package:sunu_task/screens/home/home_screen.dart'; // ------Page qui vient aprés la page de connexionn----
import 'package:sunu_task/screens/auth/register_screen.dart'; // ------Page d'inscription----
import 'package:sunu_task/widgets/common/custom_button.dart';// on personnalise un button
import 'package:sunu_task/widgets/common/custom_text_field.dart'; //---- On a le champs de texte

// ici on definit la page
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ----- logique qui se passe en arriére plan
class _LoginScreenState extends State<LoginScreen> {

  //  Clé pour valider si le formulaire est bien rempli

  final _formKey = GlobalKey<FormState>();

  //  Controllers pr lire que l'utilisateur écrit
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Provider permet l'accés au service d'authentification
  final _authProvider = AuthProvider();

  @override
  void dispose() {
    //  Libère les controllers
    _emailController.dispose();  // on éteint les controlers pr libérer de memoire quand on quitt le page
    _passwordController.dispose(); ///// -----
    super.dispose();
  }

  Future<void> _login() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) return;

    //  Appeler login() ici on envoie le email et le mot de passe au serveur
    final success = await _authProvider.login(
    _emailController.text.trim(), // email
    _passwordController.text.trim(), // password
    );

    if (!mounted) return;

    // Si la connexion marche
    if (success) {
      Navigator.pushAndRemoveUntil( // on va vers l'ecran d'acceuil appelé le HomeScreen
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(authProvider: _authProvider),
        ),
            (route) => false,
      );
    } else {
      //  Si erreur SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar( // là elle affiche un petit mess d'erreur en bas de l'ecran pr prévenir l'utilisateur
          content: Text(_authProvider.error ?? 'Erreur de connexion'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Email
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email obligatoire';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Email invalide';
                    }
                    return null;

                  },
                ),

                // Mot de passe
                CustomTextField(
                  label: 'Mot de passe',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mot de passe obligatoire';
                    }
                    if (value.length < 6) {
                      return 'Minimum 6 caractéres';
                    }
                    return null;
                  },
                ),

                // Bouton connexion
                ListenableBuilder(
                  listenable: _authProvider,
                  builder: (context, _) {
                    return CustomButton(
                      text: 'Se connecter',
                      onPressed: _login,
                      isLoading: _authProvider.isLoading,
                      color: AppColors.primary,
                    );
                  },
                ),

                // Lien inscription
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text("Pas de compte ? S'inscrire"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}