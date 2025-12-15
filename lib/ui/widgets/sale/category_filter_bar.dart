import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/models/index.dart';
import 'package:sicv_flutter/providers/category_provider.dart';
import 'package:sicv_flutter/providers/sale_provider.dart';

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoryProvider);

    final selectedCategoryId = ref.watch(saleSelectedCategoryIdProvider);

    return categoriesState.when(
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stack) => SizedBox(
        height: 50,
        child: Center(
          child: Text('Error cargando categorías: ${error.toString()}'),
        ),
      ),
      data: (categories) {
        final List<CategoryModel> categoriesWithAll = [
          CategoryModel(
            id: 0,
            name: 'Todos',
            description: 'Todos los productos',
            status: true,
          ),
          ...categories,
        ];

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoriesWithAll.length,
            itemBuilder: (context, index) {
              final category = categoriesWithAll[index];
              final bool isSelected = category.id == selectedCategoryId;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(saleSelectedCategoryIdProvider.notifier).state =
                          category.id;
                    }
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    // color: isSelected
                    //     ? Theme.of(context).colorScheme.onSecondary
                    //     : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  backgroundColor: Theme.of(context).cardColor,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
