import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/screens/menu_filtersheet.dart';
import 'package:restaurant_os_ai/src/ui/widgets.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersProvider);
    final controller = ref.read(filtersProvider.notifier);
    final activeCount = activeFilterCount(filters);

    return Surface(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          TextField(
            onChanged: controller.setQuery,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.search_normal),
              hintText: 'Search menu',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openFilters(context),
                  icon: const Icon(Iconsax.filter, size: 18),
                  label: Text(
                    activeCount == 0 ? 'Filters' : 'Filters ($activeCount)',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 156),
                child: ChoicePill(
                  label: filters.sortBy.label,
                  icon: Iconsax.sort,
                  selected: filters.sortBy != SortOption.recommended,
                  onTap: () => _openFilters(context),
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MenuFilterSheet(),
    );
  }
}
