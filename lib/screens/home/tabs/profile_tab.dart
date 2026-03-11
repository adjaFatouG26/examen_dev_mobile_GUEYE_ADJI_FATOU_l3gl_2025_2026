// profile_tab.dart
import 'package:flutter/material.dart';
import 'package:sunu_task/providers/auth_provider.dart';

class ProfileTab extends StatelessWidget {
  final AuthProvider authProvider;

  const ProfileTab({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profil'),
    );
  }
}