import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/inventory_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text('Productos disponibles', style: AppTextStyles.headlineLarge),
            SizedBox(height: 16),
            InventoryCard(title: 'Laptop Dell', statusColor: AppColors.success),
            InventoryCard(title: 'Monitor LG', statusColor: AppColors.warning),
          ],
        ),
      ),
    );
  }
}
