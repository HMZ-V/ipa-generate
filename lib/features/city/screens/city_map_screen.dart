import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class CityMapScreen extends StatelessWidget {
  const CityMapScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: const Center(child: Text('City Map — coming soon', style: TextStyle(color: AppColors.foreground))),
  );
}
