import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/ui/screen/home/sale_screen.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sidebarx/sidebarx.dart';

class SalePage extends StatefulWidget {
  final SidebarXController controller;

  const SalePage({super.key, required this.controller});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  final GlobalKey<SaleScreenState> _saleScreenKey =
      GlobalKey<SaleScreenState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AppSizes.breakpoint;

        // Estructura principal del Scaffold
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: !isWide ? AppBarApp(title: 'Punto de Venta') : null,
          drawer: isWide ? null : MySideBar(controller: widget.controller),
          body: isWide
              ? Row(
                  children: [
                    MySideBar(controller: widget.controller),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                        ), // Un poco de aire arriba
                        child: SaleScreen(key: _saleScreenKey),
                      ),
                    ),
                  ],
                )
              : SaleScreen(key: _saleScreenKey),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _saleScreenKey.currentState?.showSaleDetail(context);
            },
            backgroundColor: AppColors.primary,
            icon: Icon(
              Symbols.shopping_cart_checkout,
              color: AppColors.secondary,
            ),
            label: Text(
              "Ver Orden",
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
