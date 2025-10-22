import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/inventory_item.dart';
import 'package:sicv_flutter/ui/widgets/App_search_bar.dart';
import 'package:sicv_flutter/ui/widgets/product_card.dart';

class SaleScreen extends StatefulWidget {
  final List<InventoryItem> saleItemsSelled;
  const SaleScreen({super.key, required this.saleItemsSelled});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  TextEditingController searchController = TextEditingController();
  List<InventoryItem> inventoryItems = [];
  List<InventoryItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
    searchController.addListener(_filterItems);
  }

  void _loadSampleData() {
    setState(() {
      inventoryItems = [
        InventoryItem(
          id: '1',
          name: 'Harina PAN',
          description: 'Harina de maíz precocida',
          quantity: 50,
          price: 1.40,
          category: 'Alimentos',
          lastUpdated: DateTime.now(),
        ),
        InventoryItem(
          id: '2',
          name: 'Cigarros Marlboro',
          description: 'Cigarros de tabaco rubio',
          quantity: 5,
          price: 5.99,
          category: 'Tabaco',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
        InventoryItem(
          id: '3',
          name: 'Café',
          description: 'Café de granos',
          quantity: 0,
          price: 10.99,
          category: 'Bebidas',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
        InventoryItem(
          id: '3',
          name: 'Café',
          description: 'Café de granos',
          quantity: 0,
          price: 10.99,
          category: 'Bebidas',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
        InventoryItem(
          id: '3',
          name: 'Café',
          description: 'Café de granos',
          quantity: 0,
          price: 10.99,
          category: 'Bebidas',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
        InventoryItem(
          id: '3',
          name: 'Café',
          description: 'Café de granos',
          quantity: 0,
          price: 10.99,
          category: 'Bebidas',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
        InventoryItem(
          id: '3',
          name: 'Café',
          description: 'Café de granos',
          quantity: 0,
          price: 10.99,
          category: 'Bebidas',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
        InventoryItem(
          id: '3',
          name: 'Café',
          description: 'Café de granos',
          quantity: 0,
          price: 10.99,
          category: 'Bebidas',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
        InventoryItem(
          id: '3',
          name: 'Café',
          description: 'Café de granos',
          quantity: 0,
          price: 10.99,
          category: 'Bebidas',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
        InventoryItem(
          id: '3',
          name: 'Café',
          description: 'Café de granos',
          quantity: 0,
          price: 10.99,
          category: 'Bebidas',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
        InventoryItem(
          id: '3',
          name: 'Café',
          description: 'Café de granos',
          quantity: 0,
          price: 10.99,
          category: 'Bebidas',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
        InventoryItem(
          id: '3',
          name: 'Café',
          description: 'Café de granos',
          quantity: 0,
          price: 10.99,
          category: 'Bebidas',
          lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        ),
      ];
      filteredItems = inventoryItems;
    });
  }

  void _addNewItem(InventoryItem newItem) {
    setState(() {
      widget.saleItemsSelled.add(newItem);
    });
  }

  void _filterItems() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = inventoryItems.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSearchBar(
          searchController: searchController,
          hintText: 'Buscar producto.....',
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return ProductCard(
                item: item,
                onTap: () {},

                onDelete: () {},
                trailing: IconButton(
                  onPressed: () => _addNewItem(item),
                  icon: Icon(Icons.add),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
