import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/widgets/insights_panel.dart';
import 'package:restaurant_os_ai/src/ui/theme.dart';
import 'package:restaurant_os_ai/src/ui/widgets/label_pill.dart';

class RestaurantHero extends ConsumerWidget {
  const RestaurantHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantProvider);
    final isOpen = restaurant.isOpenAt(DateTime.now());

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 244,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: restaurant.bannerUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.border),
              errorWidget: (_, _, _) => Container(color: AppColors.border),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Logo(initials: restaurant.logoInitials, size: 54),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.restaurantName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${restaurant.cuisine} • ${restaurant.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      LabelPill(
                        label: isOpen ? 'Open now' : 'Closed',
                        icon: isOpen
                            ? Iconsax.tick_circle
                            : Iconsax.close_circle,
                        color: isOpen ? AppColors.success : AppColors.danger,
                        background: Colors.white,
                      ),
                      LabelPill(
                        label:
                            '${restaurant.estimatedDeliveryMin}-${restaurant.estimatedDeliveryMax} min',
                        icon: Iconsax.timer,
                        color: AppColors.blue,
                        background: Colors.white,
                      ),
                      LabelPill(
                        label: restaurant.rating.toStringAsFixed(1),
                        icon: Iconsax.star,
                        color: AppColors.saffron,
                        background: Colors.white,
                      ),
                      LabelPill(
                        label:
                            '${restaurant.deliveryRadiusKm.toStringAsFixed(0)} km',
                        icon: Iconsax.routing,
                        color: AppColors.teal,
                        background: Colors.white,
                      ),
                    ],
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