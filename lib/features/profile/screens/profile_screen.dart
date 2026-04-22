import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: const Center(child: Text('Profile — coming soon', style: TextStyle(color: AppColors.foreground))),
  );
}
