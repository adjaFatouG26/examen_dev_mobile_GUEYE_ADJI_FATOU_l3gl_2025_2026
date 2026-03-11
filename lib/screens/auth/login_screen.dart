import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/screens/home/home_screen.dart';
import 'package:sunu_task/screens/auth/register_screen.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //  Clé du formulaire

  final _formKey = GlobalKey<FormState>();

  //  Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //  Provider
  final _authProvider = AuthProvider();

  @override
  void dispose() {
    //  Libère les controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) return;

    //  Appeler login()
    final success = await _authProvider.login(
    _emailController.text.trim(), // email
    _passwordController.text.trim(), // password
    );

    if (!mounted) return;

    // Si succès → HomeScreen
    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } else {
      //  Si erreur → SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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