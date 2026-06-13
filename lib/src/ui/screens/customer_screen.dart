import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/widgets/empty_state.dart';
import 'package:restaurant_os_ai/src/ui/widgets/filter_bar.dart';
import 'package:restaurant_os_ai/src/ui/widgets/menu_carditem.dart';
import 'package:restaurant_os_ai/src/ui/widgets/restarant_hero.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/section_title.dart';

class CustomerScreen extends ConsumerWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredMenuProvider);
    final width = MediaQuery.sizeOf(context).width;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        width >= 390 ? 16 : 12,
        14,
        width >= 390 ? 16 : 12,
        96,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RestaurantHero(),
          const SizedBox(height: 14),
          const FilterBar(),
          const SizedBox(height: 18),
          SectionTitle(
            title: 'Menu',
            trailing: Text(
              '${items.length} items',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const EmptyState(
              icon: Iconsax.search_normal,
              title: 'No matching items',
              body: 'Reset filters or search another dish.',
            )
          else
            for (final item in items) ...[
              MenuItemCard(item: item),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}