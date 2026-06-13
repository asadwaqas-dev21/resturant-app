import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/widgets/choicepill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/insights_panel.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class BrandSetupScreen extends ConsumerWidget {
  const BrandSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantProvider);
    final presets = ref.watch(restaurantPresetsProvider);
    final controller = ref.read(restaurantProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.go('/onboarding'),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        title: const Text('Brand setup', style: TextStyle(fontSize: 19)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Surface(
                    child: Row(
                      children: [
                        Logo(initials: restaurant.logoInitials, size: 52),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.appName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '${restaurant.currency} | ${restaurant.timezone}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SetupSection(
                    title: 'Client preset',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final preset in presets)
                          ChoicePill(
                            label: preset.restaurantName,
                            icon: Iconsax.shop,
                            selected:
                                restaurant.restaurantId == preset.restaurantId,
                            onTap: () =>
                                controller.activatePreset(preset.restaurantId),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SetupSection(
                    title: 'Brand palette',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PaletteChoice(
                          label: 'Amber',
                          color: AppColors.primary,
                          onTap: () =>
                              controller.applyBrandColors('#FF6B35', '#F7F3EC'),
                        ),
                        _PaletteChoice(
                          label: 'Spice',
                          color: AppColors.danger,
                          onTap: () =>
                              controller.applyBrandColors('#9D2F2F', '#FFF1E7'),
                        ),
                        _PaletteChoice(
                          label: 'Mint',
                          color: AppColors.teal,
                          onTap: () =>
                              controller.applyBrandColors('#176B63', '#EAF6F3'),
                        ),
                        _PaletteChoice(
                          label: 'Royal',
                          color: AppColors.blue,
                          onTap: () =>
                              controller.applyBrandColors('#3457D5', '#EEF2FF'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SetupSection(
                    title: 'Services',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoicePill(
                          label: 'Delivery',
                          icon: Iconsax.truck_fast,
                          selected: restaurant.isDeliveryAvailable,
                          onTap: controller.toggleDelivery,
                        ),
                        ChoicePill(
                          label: 'Pickup',
                          icon: Iconsax.shop,
                          selected: restaurant.isPickupAvailable,
                          onTap: controller.togglePickup,
                        ),
                        ChoicePill(
                          label: 'Dine in',
                          icon: Iconsax.reserve,
                          selected: restaurant.isDineInAvailable,
                          onTap: controller.toggleDineIn,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SetupSection(
                    title: 'Package flags',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoicePill(
                          label: 'Coupons',
                          icon: Iconsax.ticket_discount,
                          selected: restaurant.couponsEnabled,
                          onTap: controller.toggleCoupons,
                        ),
                        ChoicePill(
                          label: 'Loyalty',
                          icon: Iconsax.crown,
                          selected: restaurant.loyaltyEnabled,
                          onTap: controller.toggleLoyalty,
                        ),
                        ChoicePill(
                          label: 'Wallet',
                          icon: Iconsax.wallet,
                          selected: restaurant.walletEnabled,
                          onTap: controller.toggleWallet,
                        ),
                        ChoicePill(
                          label: 'AI',
                          icon: Iconsax.lamp_on,
                          selected: restaurant.aiEnabled,
                          onTap: controller.toggleAi,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LaunchChecklist(restaurant: restaurant),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/signin?role=owner'),
                      icon: const Icon(Iconsax.login),
                      label: const Text('Continue as owner'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupSection extends StatelessWidget {
  const _SetupSection({required this.title, required this.child});

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

class _PaletteChoice extends StatelessWidget {
  const _PaletteChoice({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const SizedBox.square(dimension: 14),
      ),
      label: Text(label),
    );
  }
}

class _LaunchChecklist extends StatelessWidget {
  const _LaunchChecklist({required this.restaurant});

  final RestaurantConfig restaurant;

  @override
  Widget build(BuildContext context) {
    final checks = [
      ('Brand selected', restaurant.appName.isNotEmpty),
      ('At least one service', restaurant.availableOrderTypes.isNotEmpty),
      ('Customer app enabled', restaurant.customerAppEnabled),
      ('Payments planned', true),
    ];

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Launch checklist',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          for (final check in checks) ...[
            Row(
              children: [
                Icon(
                  check.$2 ? Iconsax.tick_circle : Iconsax.close_circle,
                  color: check.$2 ? AppColors.success : AppColors.muted,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(check.$1)),
              ],
            ),
            if (check != checks.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}


// ignore: unused_element






