import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/widgets/choicepill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/insights_panel.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantProvider);
    final presets = ref.watch(restaurantPresetsProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Logo(initials: restaurant.logoInitials, size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.appName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
                            ),
                            Text(
                              restaurant.branchName,
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
                  const SizedBox(height: 28),
                  Text(
                    'RestaurantOS AI',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'White-label restaurant app',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Surface(
                      color: AppColors.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client brand',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final preset in presets)
                                ChoicePill(
                                  label: preset.restaurantName,
                                  icon: Iconsax.shop,
                                  selected:
                                      restaurant.restaurantId ==
                                      preset.restaurantId,
                                  compact: true,
                                  onTap: () => ref
                                      .read(restaurantProvider.notifier)
                                      .activatePreset(preset.restaurantId),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _OnboardingAction(
                    icon: Iconsax.shop,
                    title: 'Order food',
                    body: 'Customer login, menu, cart, and tracking',
                    color: primary,
                    onTap: () => context.go('/signin?role=customer'),
                  ),
                  const SizedBox(height: 10),
                  _OnboardingAction(
                    icon: Iconsax.brush_2,
                    title: 'Set up restaurant',
                    body: 'Brand, services, package, and launch checklist',
                    color: AppColors.blue,
                    onTap: () => context.go('/brand-setup'),
                  ),
                  const SizedBox(height: 10),
                  _OnboardingAction(
                    icon: Iconsax.cpu_setting,
                    title: 'Staff operations',
                    body: 'Owner, kitchen, rider, and manager access',
                    color: AppColors.teal,
                    onTap: () => context.go('/signin?role=staff'),
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

class _OnboardingAction extends StatelessWidget {
  const _OnboardingAction({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Surface(
      onTap: onTap,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Icon(icon, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, color: AppColors.muted),
        ],
      ),
    );
  }
}

