import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/theme.dart';
import 'package:restaurant_os_ai/src/ui/widgets.dart';

class MenuFilterSheet extends ConsumerWidget {
  const MenuFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final filters = ref.watch(filtersProvider);
    final controller = ref.read(filtersProvider.notifier);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        decoration: const BoxDecoration(
          color: AppColors.faint,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.filter, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Filters',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconActionButton(
                          icon: Iconsax.close_circle,
                          tooltip: 'Close',
                          onPressed: Navigator.of(context).pop,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FilterSection(
                      title: 'Category',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoicePill(
                            label: 'All',
                            selected: filters.categoryId == null,
                            onTap: () => controller.selectCategory(null),
                          ),
                          for (final category in categories)
                            ChoicePill(
                              label: category.name,
                              selected: filters.categoryId == category.id,
                              onTap: () =>
                                  controller.selectCategory(category.id),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FilterSection(
                      title: 'Tags',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoicePill(
                            label: 'Open now',
                            icon: Iconsax.timer_start,
                            selected: filters.isOpenNow,
                            onTap: controller.toggleOpenNow,
                          ),
                          ChoicePill(
                            label: 'Halal',
                            icon: Iconsax.tick_circle,
                            selected: filters.isHalal,
                            onTap: controller.toggleHalal,
                          ),
                          ChoicePill(
                            label: 'Veg',
                            icon: Iconsax.tree,
                            selected: filters.isVegetarian,
                            onTap: controller.toggleVegetarian,
                          ),
                          ChoicePill(
                            label: 'Vegan',
                            icon: Iconsax.tree,
                            selected: filters.isVegan,
                            onTap: controller.toggleVegan,
                          ),
                          ChoicePill(
                            label: 'Spicy',
                            icon: Iconsax.flash,
                            selected: filters.isSpicy,
                            onTap: controller.toggleSpicy,
                          ),
                          ChoicePill(
                            label: 'Best seller',
                            icon: Iconsax.crown,
                            selected: filters.isBestSeller,
                            onTap: controller.toggleBestSeller,
                          ),
                          ChoicePill(
                            label: 'Offers',
                            icon: Iconsax.discount_shape,
                            selected: filters.hasOffers,
                            onTap: controller.toggleOffers,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FilterSection(
                      title: 'Sort',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final option in SortOption.values)
                            ChoicePill(
                              label: option.label,
                              icon: Iconsax.sort,
                              selected: filters.sortBy == option,
                              onTap: () => controller.setSort(option),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FilterSection(
                      title: 'Price',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filters.maxPrice == null
                                ? 'Any price'
                                : 'Up to ${money(filters.maxPrice!)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.muted),
                          ),
                          Slider(
                            value: filters.maxPrice ?? 1800,
                            min: 200,
                            max: 1800,
                            divisions: 9,
                            label: filters.maxPrice == null
                                ? 'Any'
                                : money(filters.maxPrice!),
                            onChanged: controller.setMaxPrice,
                          ),
                          OutlinedButton.icon(
                            onPressed: () => controller.setMaxPrice(null),
                            icon: const Icon(Iconsax.close_circle, size: 17),
                            label: const Text('Any price'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 12 + bottomPadding),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.reset,
                      icon: const Icon(Iconsax.refresh, size: 17),
                      label: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Iconsax.tick_circle, size: 17),
                      label: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

int activeFilterCount(MenuFilters filters) {
  var count = 0;
  if (filters.categoryId != null) count++;
  if (filters.isOpenNow) count++;
  if (filters.isHalal) count++;
  if (filters.isVegetarian) count++;
  if (filters.isVegan) count++;
  if (filters.isSpicy) count++;
  if (filters.isBestSeller) count++;
  if (filters.hasOffers) count++;
  if (filters.maxPrice != null) count++;
  if (filters.sortBy != SortOption.recommended) count++;
  return count;
}



