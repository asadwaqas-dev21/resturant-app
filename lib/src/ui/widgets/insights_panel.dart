import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/theme.dart';
import 'package:restaurant_os_ai/src/ui/widgets/section_title.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class InsightsPanel extends ConsumerWidget {
  const InsightsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(menuProvider);
    final orders = ref.watch(ordersProvider);
    final topSeller = menu.reduce(
      (a, b) => a.totalOrders >= b.totalOrders ? a : b,
    );
    final slowSeller = menu.reduce(
      (a, b) => a.totalOrders <= b.totalOrders ? a : b,
    );
    final activeDelivery = orders
        .where((order) => order.status == OrderStatus.outForDelivery)
        .length;

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'AI insights'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InsightTile(
                icon: Iconsax.crown,
                color: AppColors.saffron,
                title: 'Best seller',
                body:
                    '${topSeller.name} leads with ${topSeller.totalOrders} orders.',
              ),
              _InsightTile(
                icon: Iconsax.lamp_on,
                color: AppColors.blue,
                title: 'Offer idea',
                body:
                    'Bundle ${slowSeller.name} with fries to lift slow movement.',
              ),
              _InsightTile(
                icon: Iconsax.truck_fast,
                color: AppColors.teal,
                title: 'Delivery load',
                body: '$activeDelivery orders are currently on the road.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: math.min(360, width - 64),
      child: Surface(
        color: AppColors.surfaceAlt,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
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

class Logo extends StatelessWidget {
  const Logo({super.key, required this.initials, this.size = 42});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(size / 3),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 0.5,
        ),
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

int selectedIndex(String path) {
  if (path.startsWith('/orders')) return 1;
  if (path.startsWith('/dashboard') ||
      path.startsWith('/workspace') ||
      path.startsWith('/phase2')) {
    return 2;
  }
  if (path.startsWith('/cart')) return 3;
  return 0;
}

String navPath(int index) {
  switch (index) {
    case 1:
      return '/orders';
    case 2:
      return '/workspace';
    case 3:
      return '/cart';
    case 0:
    default:
      return '/';
  }
}
