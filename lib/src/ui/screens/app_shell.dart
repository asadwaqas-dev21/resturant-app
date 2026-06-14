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
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showNotificationsBottomSheet(context),
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
        selectedIndex: selectedIndex(path, isCustomer: isCustomer),
        onDestinationSelected: (index) =>
            context.go(navPath(index, isCustomer: isCustomer)),
        destinations: [
          if (isCustomer)
            const NavigationDestination(
              icon: Icon(Iconsax.shop),
              label: 'Menu',
            ),
          const NavigationDestination(
            icon: Icon(Iconsax.receipt_text),
            label: 'Orders',
          ),
          if (!isCustomer)
            const NavigationDestination(
              icon: Icon(Iconsax.cpu_setting),
              label: 'Ops',
            ),
          const NavigationDestination(
            icon: Icon(Iconsax.user),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF7A7A7A)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _NotificationTile(
                  icon: Iconsax.discount_shape,
                  title: 'Special Discount!',
                  body:
                      'Get 20% off on your next order. Use coupon code WELCOME20.',
                  time: '5 mins ago',
                ),
                const Divider(height: 24, color: Color(0xFFF5F5F5)),
                const _NotificationTile(
                  icon: Iconsax.shop,
                  title: 'New Branch Open!',
                  body:
                      'We are now serving at Gulshan. Order now for fast delivery!',
                  time: '2 hours ago',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF2EC), // Soft orange accent
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFFF5E00), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  color: Color(0xFF7A7A7A),
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
