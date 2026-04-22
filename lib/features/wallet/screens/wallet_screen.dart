import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: const Center(child: Text('Wallet — coming soon', style: TextStyle(color: AppColors.foreground))),
  );
}
