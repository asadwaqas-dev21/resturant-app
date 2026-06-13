import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/food_image.dart';
import 'package:restaurant_os_ai/src/ui/widgets/label_pill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class MenuItemCard extends ConsumerWidget {
  const MenuItemCard({super.key, required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      padding: const EdgeInsets.all(10),
      color: item.isAvailable ? AppColors.surface : AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FoodImage(url: item.imageUrl, height: 142),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (item.isBestSeller)
                const LabelPill(
                  label: 'Best seller',
                  icon: Iconsax.crown,
                  color: AppColors.saffron,
                ),
              if (item.isNew)
                const LabelPill(
                  label: 'New',
                  icon: Iconsax.flash,
                  color: AppColors.blue,
                ),
              if (item.isSpicy)
                const LabelPill(
                  label: 'Spicy',
                  icon: Iconsax.flash,
                  color: AppColors.primary,
                ),
              if (item.isVegetarian)
                const LabelPill(
                  label: 'Veg',
                  icon: Iconsax.tree,
                  color: AppColors.teal,
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      money(item.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if (item.hasDiscount)
                      Text(
                        money(item.basePrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 96),
                child: ElevatedButton.icon(
                  onPressed: item.isAvailable
                      ? () => ref.read(cartProvider.notifier).add(item)
                      : null,
                  icon: Icon(
                    item.isAvailable ? Iconsax.add : Iconsax.close_circle,
                    size: 17,
                  ),
                  label: Text(item.isAvailable ? 'Add' : 'Sold out'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
