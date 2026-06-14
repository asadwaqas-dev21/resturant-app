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
    final role = ref.watch(userRoleProvider);
    final isCustomer = role == UserRole.customer;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 66,
        titleSpacing: 16,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/aaplogo.jpeg',
                width: 38,
                height: 38,
                fit: BoxFit.cover,
              ),
            ),
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
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Iconsax.notification),
          ),
          if (isCustomer && path != '/cart')
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
          constraints: BoxConstraints(
            maxWidth: isCustomer ? 560 : double.infinity,
          ),
          child: child,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex(path, role),
        onDestinationSelected: (index) => context.go(navPath(index, role)),
        destinations: [
          if (role == UserRole.customer)
            const NavigationDestination(icon: Icon(Iconsax.shop), label: 'Menu'),
          NavigationDestination(
            icon: Icon(
              role == UserRole.owner
                  ? Iconsax.status_up
                  : (role == UserRole.staff ? Iconsax.monitor : Iconsax.receipt_text),
            ),
            label: role == UserRole.owner
                ? 'Insights'
                : (role == UserRole.staff ? 'Kitchen' : 'Orders'),
          ),
          if (role != UserRole.customer)
            const NavigationDestination(icon: Icon(Iconsax.cpu_setting), label: 'Ops'),
          if (role == UserRole.customer || role == UserRole.owner || role == UserRole.staff)
            const NavigationDestination(
              icon: Icon(Iconsax.message),
              label: 'Chat',
            ),
          const NavigationDestination(
            icon: Icon(Iconsax.user),
            label: 'Account',
          ),
        ],
      ),
    );
  }

}
