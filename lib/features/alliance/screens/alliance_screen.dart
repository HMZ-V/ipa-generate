import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class AllianceScreen extends StatelessWidget {
  const AllianceScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: const Center(child: Text('Alliance — coming soon', style: TextStyle(color: AppColors.foreground))),
  );
}
