import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/widgets/insights_panel.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/label_pill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class DesktopNav extends ConsumerWidget {
  const DesktopNav({super.key, required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantProvider);
    final customer = ref.watch(customerProvider);
    final cart = ref.watch(cartProvider);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Logo(initials: restaurant.logoInitials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      restaurant.branchName,
                      maxLines: 1,
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
          const SizedBox(height: 26),
          _NavItem(
            label: 'Menu',
            icon: Iconsax.shop,
            path: '/',
            currentPath: currentPath,
          ),
          _NavItem(
            label: 'Orders',
            icon: Iconsax.receipt_text,
            path: '/orders',
            currentPath: currentPath,
          ),
          _NavItem(
            label: 'Operations',
            icon: Iconsax.chart_square,
            path: '/dashboard',
            currentPath: currentPath,
          ),
          _NavItem(
            label: 'Ops Hub',
            icon: Iconsax.cpu_setting,
            path: '/workspace',
            currentPath: currentPath,
          ),
          _NavItem(
            label: 'Cart',
            icon: Iconsax.shopping_cart,
            path: '/cart',
            currentPath: currentPath,
            count: cart.itemCount,
          ),
          const Spacer(),
          Surface(
            color: AppColors.surfaceAlt,
            child: Row(
              children: [
                const Icon(Iconsax.wallet, color: AppColors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${customer.loyaltyPoints} points • ${money(customer.walletBalance)}',
                        maxLines: 1,
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
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.path,
    required this.currentPath,
    this.count,
  });

  final String label;
  final IconData icon;
  final String path;
  final String currentPath;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final selected =
        currentPath == path || (path != '/' && currentPath.startsWith(path));
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go(path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: selected ? primary : AppColors.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? primary : AppColors.ink,
                    ),
                  ),
                ),
                if (count != null && count! > 0)
                  LabelPill(
                    label: '$count',
                    color: primary,
                    background: primary.withValues(alpha: 0.1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
