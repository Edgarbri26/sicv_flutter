import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/purchase/purchase_model.dart';
import 'package:sicv_flutter/models/sale/sale_model.dart';
import 'package:sicv_flutter/models/sale/sale_summary_model.dart';
import 'package:sicv_flutter/models/purchase/purchase_summary_model.dart';
import 'package:sicv_flutter/providers/report/finance_provider.dart';
import 'package:sicv_flutter/services/purchase_service.dart';
import 'package:sicv_flutter/services/sale_service.dart';
import 'package:sicv_flutter/ui/widgets/purchase_detail_modal.dart';
import 'package:sicv_flutter/ui/widgets/bill_detail_modal.dart';
import 'package:sicv_flutter/ui/widgets/report/date_filter_selector.dart';
import 'package:sicv_flutter/ui/widgets/report/transaction_card.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          children: [
            // --- CABECERA Y FILTROS ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              color: Theme.of(context).scaffoldBackgroundColor,
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
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Movimientos",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 14),
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
                          ref
                              .read(historyFilterProvider.notifier)
                              .state = filterState.copyWith(
                            period: 'custom',
                            customRange: newRange,
                          );
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
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).shadowColor.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            labelColor: Theme.of(context).primaryColor,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            unselectedLabelColor: Theme.of(context).hintColor,
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
                        color: Theme.of(context).cardColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isAscending = !_isAscending;
                            });
                          },
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Esto está bien, es para la animación del click
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              _isAscending
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: Theme.of(context).primaryColor,
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
                children: [_buildSalesList(), _buildPurchasesList()],
              ),
            ),
          ],
        );

        if (constraints.maxWidth > 680) {
          return content;
        } else {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: content,
          );
        }
      },
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
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 40,
            ),
            Text("Error: $err", textAlign: TextAlign.center),
            TextButton(
              onPressed: () => ref.refresh(salesHistoryProvider),
              child: const Text("Reintentar"),
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 100,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: sortedSales.length,
                itemBuilder: (context, index) {
                  final saleSummary = sortedSales[index];
                  return TransactionCard(
                    title: "${saleSummary.sellerName}",
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: sortedSales.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final saleSummary = sortedSales[index];
                  return TransactionCard(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 100,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: sortedPurchases.length,
                itemBuilder: (context, index) {
                  final purchase = sortedPurchases[index];
                  return TransactionCard(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: sortedPurchases.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final purchase = sortedPurchases[index];
                  return TransactionCard(
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
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).hintColor,
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text("Error al cargar: ${snapshot.error}"),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return BillDetailModal(sale: snapshot.data!);
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
