import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/widgets/insights_panel.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final cart = ref.watch(cartProvider);
    final restaurant = ref.watch(restaurantProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 66,
        titleSpacing: 16,
        title: Row(
          children: [
            Logo(initials: restaurant.logoInitials, size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    restaurant.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
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
        actions: [
          if (path != '/cart')
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Badge.count(
                count: cart.itemCount,
                isLabelVisible: cart.itemCount > 0,
                child: IconButton(
                  tooltip: 'Cart',
                  onPressed: () => context.go('/cart'),
                  icon: const Icon(Iconsax.shopping_cart),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: child,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex(path),
        onDestinationSelected: (index) => context.go(navPath(index)),
        destinations: const [
          NavigationDestination(icon: Icon(Iconsax.shop), label: 'Menu'),
          NavigationDestination(
            icon: Icon(Iconsax.receipt_text),
            label: 'Orders',
          ),
          NavigationDestination(icon: Icon(Iconsax.cpu_setting), label: 'Ops'),
          NavigationDestination(
            icon: Icon(Iconsax.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}
