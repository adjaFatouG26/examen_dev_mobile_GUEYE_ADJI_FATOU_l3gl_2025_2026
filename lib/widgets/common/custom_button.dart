import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading; // Affiche CircularProgressIndicator
  final bool isOutlined; // true = OutlinedButton, false = ElevatedButton
  final IconData? icon; // Icône optionnelle à gauche
  final double? width;
  final double? height;
  final Color? color;
// Constructeur avec valeurs par défaut
// Méthode build qui retourne ElevatedButton ou OutlinedBut
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : icon != null
        ? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(text),
      ],
    )
        : Text(text);

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color ?? Theme.of(context).primaryColor),
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        child: buttonChild,
      ),
    );
  }
}