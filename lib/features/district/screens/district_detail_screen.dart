import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class DistrictDetailScreen extends StatelessWidget {
  final String districtId;
  const DistrictDetailScreen({super.key, required this.districtId});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Text('District: $districtId — coming soon', style: const TextStyle(color: AppColors.foreground))),
  );
}
