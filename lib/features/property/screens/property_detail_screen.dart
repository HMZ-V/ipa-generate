import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class PropertyDetailScreen extends StatelessWidget {
  final String blockId;
  const PropertyDetailScreen({super.key, required this.blockId});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Text('Property: $blockId — coming soon', style: const TextStyle(color: AppColors.foreground))),
  );
}
