import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venta')),
      body: Column(
        children: [
          Row(),
          CardProduct(
            title: "Producto 1",
            stock: 7,
            image: Icon(Icons.scale),
            onPressed: () {
              print("objeto 1");
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: "Ver Lista de venta",
        child: Icon(Icons.edit),
      ),
    );
  }
}

class CardProduct extends StatelessWidget {
  final Icon image;
  final String title;
  final int stock;
  final VoidCallback onPressed;

  const CardProduct({
    super.key,
    required this.title,
    required this.stock,
    required this.image,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.disabled,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
      ),
      padding: EdgeInsets.all(AppSizes.spacingM),
      margin: EdgeInsets.symmetric(
        vertical: AppSizes.spacingXS,
        horizontal: AppSizes.spacingS,
      ),
      child: Row(
        spacing: AppSizes.spacingL,
        children: [
          image,
          Expanded(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(title), Text(stock.toString())],
            ),
          ),

          IconButton(
            onPressed: onPressed,
            icon: Icon(
              Icons.add_circle_outline,
              color: stock > 5 ? AppColors.success : AppColors.danger,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
