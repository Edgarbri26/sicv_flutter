import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/purchase/purchase_model.dart';
import 'package:sicv_flutter/models/sale/sale_model.dart';
import 'package:sicv_flutter/models/sale/sale_summary_model.dart';
import 'package:sicv_flutter/models/purchase/purchase_summary_model.dart';
import 'package:sicv_flutter/providers/report/finance_provider.dart';
import 'package:sicv_flutter/services/purchase_service.dart';
import 'package:sicv_flutter/services/sale_service.dart';
import 'package:sicv_flutter/ui/widgets/purchase_detail_modal.dart';
import 'package:sicv_flutter/ui/widgets/sale_detail_modal.dart';

// IMPORTAMOS LOS PROVIDERS Y EL WIDGET DE FILTRO
import 'package:sicv_flutter/ui/widgets/rerport/date_filter_selector.dart'; 

class FinancesView extends ConsumerStatefulWidget {
  const FinancesView({super.key});

  @override
  ConsumerState<FinancesView> createState() => _FinancesViewState();
}

class _FinancesViewState extends ConsumerState<FinancesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAscending = false; // Estado para el ordenamiento local

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
    // 1. Escuchamos el estado del filtro para pasárselo al widget selector
    final filterState = ref.watch(historyFilterProvider);

    return Column(
      children: [
        // --- CABECERA Y FILTROS ---
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Título y Selector de Fechas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Historial",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                      ),
                      Text(
                        "Movimientos",
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                  
                  // WIDGET DE FILTRO DE FECHAS
                  DateFilterSelector(
                    selectedFilter: filterState.period,
                    selectedDateRange: filterState.customRange,
                    onFilterChanged: (newFilter) {
                      // Actualizamos el provider, esto dispara la recarga de las listas
                      ref.read(historyFilterProvider.notifier).state =
                          filterState.copyWith(period: newFilter);
                    },
                    onDateRangeChanged: (newRange) {
                      ref.read(historyFilterProvider.notifier).state =
                          filterState.copyWith(period: 'custom', customRange: newRange);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Tabs y Botón de Ordenar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: AppColors.primary,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        unselectedLabelColor: Colors.grey.shade600,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.trending_up, size: 18),
                                SizedBox(width: 8),
                                Text('Ventas'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.trending_down, size: 18),
                                SizedBox(width: 8),
                                Text('Compras'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón de Ordenamiento
                  Material(
                    color: Colors.white,
                    // borderRadius: BorderRadius.circular(12), // <--- ELIMINA ESTA LÍNEA (Causa el conflicto)
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12)), // Ya estás definiendo el borde aquí
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isAscending = !_isAscending;
                        });
                      },
                      borderRadius: BorderRadius.circular(12), // Esto está bien, es para la animación del click
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          _isAscending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // --- CONTENIDO (LISTAS) ---
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSalesList(), 
              _buildPurchasesList()
            ],
          ),
        ),
      ],
    );
  }

  // --- LISTA DE VENTAS ---
  Widget _buildSalesList() {
    // Usamos el provider que ya tiene la lógica de fechas
    final salesAsync = ref.watch(salesHistoryProvider);

    return salesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            Text("Error: $err", textAlign: TextAlign.center),
            TextButton(
                onPressed: () => ref.refresh(salesHistoryProvider),
                child: const Text("Reintentar"))
          ],
        ),
      ),
      data: (sales) {
        if (sales.isEmpty) {
          return _buildEmptyState(
            "No hay ventas en este periodo",
            Icons.sell_outlined,
          );
        }

        // Ordenamiento local (Client-side sorting)
        final sortedSales = List<SaleSummaryModel>.from(sales);
        sortedSales.sort((a, b) {
          return _isAscending
              ? a.soldAt.compareTo(b.soldAt)
              : b.soldAt.compareTo(a.soldAt);
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 100,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: sortedSales.length,
                itemBuilder: (context, index) {
                  final saleSummary = sortedSales[index];
                  return _TransactionCard(
                    title: "Vendido por ${saleSummary.sellerName}",
                    amount: saleSummary.totalUsd,
                    amountBs: saleSummary.totalVes,
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
            } else {
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: sortedSales.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final saleSummary = sortedSales[index];
                  return _TransactionCard(
                    title: "Vendido por ${saleSummary.sellerName}",
                    amount: saleSummary.totalUsd,
                    amountBs: saleSummary.totalVes,
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
            }
          },
        );
      },
    );
  }

  // --- LISTA DE COMPRAS ---
  Widget _buildPurchasesList() {
    // Usamos el provider que ya tiene la lógica de fechas
    final purchasesAsync = ref.watch(purchasesHistoryProvider);

    return purchasesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (purchases) {
        if (purchases.isEmpty) {
          return _buildEmptyState(
            "No hay compras en este periodo",
            Icons.shopping_bag_outlined,
          );
        }

        final sortedPurchases = List<PurchaseSummaryModel>.from(purchases);
        sortedPurchases.sort((a, b) {
          return _isAscending
              ? a.boughtAt.compareTo(b.boughtAt)
              : b.boughtAt.compareTo(a.boughtAt);
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 100,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: sortedPurchases.length,
                itemBuilder: (context, index) {
                  final purchase = sortedPurchases[index];
                  return _TransactionCard(
                    title: "Compra #${purchase.purchaseId}",
                    amount: purchase.totalUsd,
                    amountBs: purchase.totalVes,
                    date: purchase.boughtAt,
                    isIncome: false,
                    onTap: () {
                      if (purchase.purchaseId != null) {
                        _showPurchaseDetail(context, purchase.purchaseId!);
                      }
                    },
                  );
                },
              );
            } else {
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: sortedPurchases.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final purchase = sortedPurchases[index];
                  return _TransactionCard(
                    title: "Compra #${purchase.purchaseId}",
                    amount: purchase.totalUsd,
                    amountBs: purchase.totalVes,
                    date: purchase.boughtAt,
                    isIncome: false,
                    onTap: () {
                      if (purchase.purchaseId != null) {
                        _showPurchaseDetail(context, purchase.purchaseId!);
                      }
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- MODAL DETALLE COMPRA ---
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
              future: PurchaseService().getById(purchaseId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  );
                }
                if (snapshot.hasData) {
                  return PurchaseDetailModal(purchase: snapshot.data!);
                }
                return const SizedBox();
              },
            );
          },
        );
      },
    );
  }

  // --- MODAL DETALLE VENTA ---
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
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child:
                        Center(child: Text("Error al cargar: ${snapshot.error}")),
                  );
                }
                if (snapshot.hasData) {
                  return SaleDetailModal(sale: snapshot.data!);
                }
                return const SizedBox();
              },
            );
          },
        );
      },
    );
  }
}

// --- TARJETA DE TRANSACCIÓN ---
class _TransactionCard extends StatelessWidget {
  final String title;
  final double amount;
  final double amountBs;
  final DateTime date;
  final bool isIncome;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.title,
    required this.amount,
    required this.amountBs,
    required this.date,
    required this.isIncome,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    final currencyBs = NumberFormat.currency(symbol: 'Bs. ');
    final color = isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final iconBg = isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final icon = isIncome
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM, HH:mm').format(date),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${isIncome ? '+' : '-'}${currency.format(amount)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    Text(
                      "${isIncome ? '+' : '-'}${currencyBs.format(amountBs)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13, // Ligeramente más pequeño para el secundario
                        color: color.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}