import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: const Center(child: Text('Learn — coming soon', style: TextStyle(color: AppColors.foreground))),
  );
}
