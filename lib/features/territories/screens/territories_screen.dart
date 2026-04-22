import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class TerritoriesScreen extends StatelessWidget {
  const TerritoriesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: const Center(child: Text('Territories — coming soon', style: TextStyle(color: AppColors.foreground))),
  );
}
