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
            // Reemplazo temporal de InventoryCard para evitar errores de firma
            Card(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.success, child: Icon(Icons.inventory_2, color: Colors.white)),
                title: Text('Laptop Dell'),
                subtitle: Text('Disponible'),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.danger, child: Icon(Icons.monitor, color: Colors.white)),
                title: Text('Monitor LG'),
                subtitle: Text('Disponible'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
