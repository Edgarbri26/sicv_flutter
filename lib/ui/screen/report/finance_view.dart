import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/purchase/purchase_model.dart';
import 'package:sicv_flutter/models/sale/sale_model.dart';
import 'package:sicv_flutter/services/purchase_service.dart';
import 'package:sicv_flutter/services/sale_service.dart'; 
import 'package:sicv_flutter/providers/finance_provider.dart';
import 'package:sicv_flutter/ui/widgets/purchase_detail_modal.dart';
import 'package:sicv_flutter/ui/widgets/sale_detail_modal.dart'; 

class FinancesView extends ConsumerStatefulWidget {
  const FinancesView({super.key});

  @override
  ConsumerState<FinancesView> createState() => _FinancesViewState();
}

class _FinancesViewState extends ConsumerState<FinancesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- PESTAÑAS ---
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Ventas (Ingresos)'),
              Tab(text: 'Compras (Egresos)'),
            ],
          ),
        ),

        // --- CONTENIDO ---
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSalesList(),
              _buildPurchasesList(),
            ],
          ),
        ),
      ],
    );
  }

  // --- LISTA DE VENTAS ---
  Widget _buildSalesList() {
    final salesAsync = ref.watch(salesHistoryProvider);

    return salesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (sales) {
        if (sales.isEmpty) {
          return _buildEmptyState("No hay ventas registradas.");
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: sales.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final saleSummary = sales[index];
            
            return _TransactionCard(
              title: "Venta #${saleSummary.saleId ?? '---'}",
              subtitle: saleSummary.clientName != 'N/A' 
                ? saleSummary.clientName 
                : "CI: ${saleSummary.clientCi}",
              amount: saleSummary.totalUsd, 
              date: saleSummary.soldAt, 
              isIncome: true,
              onTap: () {
                if (saleSummary.saleId != null) {
                  _showDetail(context, saleSummary.saleId!);
                }
              },
            );
          },
        );
      },
    );
  }

  // --- LISTA DE COMPRAS (CORREGIDA) ---
    Widget _buildPurchasesList() {
      final purchasesAsync = ref.watch(purchasesHistoryProvider);

      return purchasesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (purchases) {
          if (purchases.isEmpty) return _buildEmptyState("No hay compras registradas.");
          
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: purchases.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return _TransactionCard(
                title: "Compra #${purchase.purchaseId}",
                subtitle: purchase.providerName,
                amount: purchase.totalUsd,
                date: purchase.boughtAt, 
                
                isIncome: false, 
                onTap: () {
                    final id = purchase.purchaseId;
                    if (id != null) {
                      _showPurchaseDetail(context, id);
                    }
                }, 
              );
            }
          );
        },
      );
    }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  // --- NUEVA FUNCIÓN PARA DETALLE DE COMPRA ---
  void _showPurchaseDetail(BuildContext context, int purchaseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return FutureBuilder<PurchaseModel>(
              // Llamamos al servicio de compras
              future: PurchaseService().getById(purchaseId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  );
                }
                if (snapshot.hasData) {
                  // AQUÍ USAMOS EL NUEVO MODAL DE COMPRA
                  return PurchaseDetailModal(purchase: snapshot.data!);
                }
                return const SizedBox();
              },
            );
          }
        );
      },
    );
  }

  void _showDetail(BuildContext context, int saleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return FutureBuilder<SaleModel>(
              future: SaleService().getById(saleId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Center(child: Text("Error al cargar detalle: ${snapshot.error}")),
                  );
                }
                if (snapshot.hasData) {
                  return SaleDetailModal(sale: snapshot.data!);
                }
                return const SizedBox();
              },
            );
          }
        );
      },
    );
  }
}

// --- TARJETA REUTILIZABLE ---
class _TransactionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    final color = isIncome ? Colors.green.shade700 : Colors.red.shade700;
    final iconBg = isIncome ? Colors.green.shade50 : Colors.red.shade50;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle, 
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isIncome ? '+' : '-'}${currency.format(amount)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16, 
                      color: color
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM HH:mm').format(date),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}