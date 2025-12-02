import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/ui/screen/home/purchase_screen.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sidebarx/sidebarx.dart';

// ==========================================
// 1. PURCHASE PAGE (Layout & Scaffold)
// ==========================================
class PurchasePage extends StatefulWidget {
  final SidebarXController controller;

  const PurchasePage({super.key, required this.controller});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  // Key para controlar el formulario interno desde el FAB
  final GlobalKey<PurchaseScreenState> _contentKey =
      GlobalKey<PurchaseScreenState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AppSizes.breakpoint;

        return Scaffold(
          backgroundColor: AppColors.background,

          // --- APP BAR (Solo móvil) ---
          appBar: !isWide
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    'Registro de Compra',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  iconTheme: IconThemeData(color: AppColors.textPrimary),
                )
              : null,

          // --- DRAWER (Solo móvil) ---
          drawer: isWide ? null : MySideBar(controller: widget.controller),

          // --- BODY (Responsivo) ---
          body: isWide
              ? Row(
                  children: [
                    SizedBox(
                      width: 250,
                      child: MySideBar(controller: widget.controller),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: PurchaseScreen(key: _contentKey),
                      ),
                    ),
                  ],
                )
              : PurchaseScreen(key: _contentKey),

          // --- FAB: Agregar Producto ---
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Llama al modal de búsqueda dentro del contenido
              _contentKey.currentState?.showProductSearchModal();
            },
            backgroundColor: AppColors.primary,
            icon: Icon(Icons.add_shopping_cart, color: AppColors.secondary),
            label: Text(
              "Agregar Producto",
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
