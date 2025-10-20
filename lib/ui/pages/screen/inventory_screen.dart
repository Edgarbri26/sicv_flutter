import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/ui/widgets/App_search_bar.dart';
import '../../widgets/product_card.dart';
import '../add_edit_inventory_page.dart';
import '../../../models/inventory_item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem> inventoryItems = [];
  List<InventoryItem> filteredItems = [];
  TextEditingController searchController = TextEditingController();

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

  // void _addNewItem() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => AddEditInventoryScreen()),
  //   ).then((newItem) {
  //     if (newItem != null) {
  //       setState(() {
  //         inventoryItems.add(newItem);
  //         _filterItems();
  //       });
  //     }
  //   });
  // }

  void _editItem(InventoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditInventoryScreen(item: item),
      ),
    ).then((editedItem) {
      if (editedItem != null) {
        setState(() {
          final index = inventoryItems.indexWhere((i) => i.id == editedItem.id);
          if (index != -1) {
            inventoryItems[index] = editedItem;
            _filterItems();
          }
        });
      }
    });
  }

  void _deleteItem(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Item'),
        content: Text('¿Estás seguro de eliminar ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                inventoryItems.removeWhere((i) => i.id == item.id);
                _filterItems();
              });
              Navigator.pop(context);
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSearchBar(
          searchController: searchController,
          hintText: 'Buscar en inventario...',
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return ProductCard(
                item: item,
                onTap: () => _editItem(item),

                onDelete: () => _deleteItem(item),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') _editItem(item);
                    if (value == 'delete') _deleteItem(item);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
