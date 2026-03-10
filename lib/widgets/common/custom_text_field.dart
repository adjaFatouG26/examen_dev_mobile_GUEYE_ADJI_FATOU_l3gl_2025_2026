import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;  // Fonction de validation
  final bool obscureText; // Pour les mots de passe
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int maxLines; // Le State doit gérer le toggle de visibilité du mot de passe
// Si obscureText est true, afficher une icône œil pour basculer

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // Gère l'affichage/masquage du mot de passe
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon)
            : null,
        // Button oeil pour mot de passe
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}