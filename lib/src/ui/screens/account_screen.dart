import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/phase_two_providers.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/insights_panel.dart';
import 'package:restaurant_os_ai/src/ui/widgets/label_pill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/section_title.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';
import 'package:restaurant_os_ai/src/ui/widgets/status_pill.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerProvider);
    final orders = ref.watch(ordersProvider);
    final restaurant = ref.watch(restaurantProvider);

    final primaryColor = colorFromHex(
      restaurant.primaryColorHex,
      fallback: AppColors.primary,
    );
    final secondaryColor = colorFromHex(
      restaurant.secondaryColorHex,
      fallback: AppColors.faint,
    );

    // Calculate loyalty tier
    final int points = customer.loyaltyPoints;
    String tierName = 'Bronze Member';
    double tierProgress = 0.0;
    Color tierColor = AppColors.muted;
    if (points >= 500) {
      tierName = 'Gold Member';
      tierProgress = 1.0;
      tierColor = AppColors.saffron;
    } else if (points >= 150) {
      tierName = 'Silver Member';
      tierProgress = (points - 150) / 350;
      tierColor = AppColors.blue;
    } else {
      tierProgress = points / 150;
      tierColor = const Color(0XFFA0522D); // Bronze sienna
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header section
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Logo(
                  initials: customer.fullName.isNotEmpty
                      ? customer.fullName
                            .split(' ')
                            .map((e) => e.isNotEmpty ? e[0] : '')
                            .join()
                            .toUpperCase()
                      : 'C',
                  size: 64,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Iconsax.verify5, color: primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          tierName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: tierColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Digital Credit Card Wallet
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withValues(alpha: 0.8),
                  AppColors.ink.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.appName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Text(
                          'DIGITAL WALLET',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Iconsax.wifi, color: Colors.white, size: 22),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'BALANCE',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  money(customer.walletBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      customer.fullName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      '•••• 2026',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Loyalty Progress Card
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.crown, color: tierColor, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Loyalty Rewards',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${customer.loyaltyPoints} PTS',
                        style: TextStyle(
                          color: tierColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: tierProgress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tierName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tierColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (points < 500)
                      Text(
                        '${500 - points} pts to Gold Member',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      )
                    else
                      const Text(
                        'Max Tier unlocked!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Settings Actions List
          const SectionTitle(title: 'Account Settings'),
          const SizedBox(height: 12),
          Surface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Iconsax.location,
                  title: 'Delivery Addresses',
                  subtitle: 'Manage home, work, and saved places',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Iconsax.translate,
                  title: 'App Language',
                  subtitle: restaurant.urduEnabled
                      ? 'Switch between English / Urdu'
                      : 'English default',
                  trailing: restaurant.urduEnabled
                      ? Consumer(
                          builder: (context, ref, _) {
                            final restNotifier = ref.read(
                              restaurantProvider.notifier,
                            );
                            return Switch.adaptive(
                              value: restaurant.urduEnabled,
                              activeColor: primaryColor,
                              onChanged: (_) => restNotifier.toggleUrdu(),
                            );
                          },
                        )
                      : null,
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Iconsax.logout,
                  title: 'Logout',
                  subtitle: 'Sign out or switch accounts',
                  onTap: () => context.go('/onboarding'),
                  iconColor: AppColors.danger,
                  textColor: AppColors.danger,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activity / Order history preview
          const SectionTitle(title: 'Recent Orders'),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const Surface(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No orders placed yet.'),
                ),
              ),
            )
          else
            for (final order in orders.take(3)) ...[
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Iconsax.box,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${order.orderNumber}',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${order.lines.length} items • ${money(order.total)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        StatusPill(status: order.status),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(order.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            // Reorder shortcut
                            final cartNotifier = ref.read(
                              cartProvider.notifier,
                            );
                            cartNotifier.clear();
                            for (final line in order.lines) {
                              cartNotifier.add(line.item);
                            }
                            context.go('/cart');
                          },
                          icon: const Icon(Iconsax.repeat, size: 14),
                          label: const Text(
                            'Reorder',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  void _topUp(WidgetRef ref, double amount) {
    ref.read(customerProvider.notifier).topUpWallet(amount);
    ref.read(walletLedgerProvider.notifier).addTopUp(amount);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _TopUpButton extends StatelessWidget {
  const _TopUpButton({
    required this.amount,
    required this.primaryColor,
    required this.onPressed,
  });

  final double amount;
  final Color primaryColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor.withValues(alpha: 0.3), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        '+${amount.toStringAsFixed(0)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.ink).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.muted, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      trailing:
          trailing ??
          const Icon(Iconsax.arrow_right_3, color: AppColors.muted, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
