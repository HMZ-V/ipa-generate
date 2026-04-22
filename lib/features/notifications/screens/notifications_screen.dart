import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: const Center(child: Text('Notifications — coming soon', style: TextStyle(color: AppColors.foreground))),
  );
}
