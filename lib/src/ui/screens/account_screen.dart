import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/state/phase_two_providers.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';

import 'package:restaurant_os_ai/src/ui/widgets/manu_management.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerProvider);
    final restaurant = ref.watch(restaurantProvider);
    final role = ref.watch(userRoleProvider);
    final isCustomer = role == UserRole.customer;

    final primaryColor = colorFromHex(
      restaurant.primaryColorHex,
      fallback: AppColors.primary,
    );

    final userName = customer.fullName.isNotEmpty
        ? customer.fullName
        : 'Asad Waqas';
    final initials = userName.isNotEmpty
        ? userName
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .join()
              .toUpperCase()
        : 'A';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFFDECE9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials.isNotEmpty ? initials.substring(0, 1) : 'A',
                style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      isCustomer ? '🇦🇪' : '🏢',
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCustomer
                          ? 'United Arab Emirates'
                          : restaurant.branchName,
                      style: const TextStyle(
                        color: Color(0xFF7A7A7A),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF1E1E1E),
              size: 22,
            ),
            onPressed: () {
              context.go('/settings');
            },
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E1E),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thick separator band
              Container(
                height: 8,
                color: const Color(0xFFF5F5F5),
                width: double.infinity,
              ),

              // List Items section
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: isCustomer
                    ? [
                        _FlatListTile(
                          icon: Iconsax.gift,
                          title: 'Rewards',
                          trailingText: '${customer.loyaltyPoints} points',
                          onTap: () {
                            _showLoyaltyInfo(context, customer.loyaltyPoints);
                          },
                        ),
                        _FlatListTile(
                          icon: Iconsax.receipt_item,
                          title: 'Your orders',
                          onTap: () {
                            context.go('/orders');
                          },
                        ),
                        _FlatListTile(
                          icon: Iconsax.wallet_3,
                          title: 'Kurchu pay',
                          trailingText:
                              'AED ${customer.walletBalance.toStringAsFixed(3)}',
                          onTap: () {
                            _showTopUpDialog(context, ref, primaryColor);
                          },
                        ),
                        _FlatListTile(
                          icon: Iconsax.ticket,
                          title: 'Vouchers',
                          onTap: () {
                            _showVouchersInfo(context);
                          },
                        ),
                        _FlatListTile(
                          customIcon: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8A3DFF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'pro',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: 'Kurchu pro',
                          onTap: () {
                            _showProJoinedDialog(context);
                          },
                        ),
                        _FlatListTile(
                          icon: Icons.help_outline_outlined,
                          title: 'Get help',
                          onTap: () {
                            _showHelpDialog(context);
                          },
                        ),
                        _FlatListTile(
                          icon: Icons.info_outline,
                          title: 'About app',
                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),
                        _FlatListTile(
                          icon: Iconsax.logout,
                          title: 'Logout',
                          titleColor: AppColors.danger,
                          iconColor: AppColors.danger,
                          onTap: () => context.go('/onboarding'),
                        ),
                      ]
                    : [
                        _FlatListTile(
                          icon: Iconsax.shop,
                          title: 'Brand setup',
                          onTap: () {
                            context.go('/brand-setup');
                          },
                        ),
                        _FlatListTile(
                          icon: Iconsax.cpu_setting,
                          title: 'Operations hub',
                          onTap: () {
                            context.go('/workspace');
                          },
                        ),
                        if (role == UserRole.owner)
                          _FlatListTile(
                            icon: Iconsax.status_up,
                            title: 'Analytics dashboard',
                            onTap: () {
                              context.go('/dashboard');
                            },
                          ),
                        _FlatListTile(
                          icon: Iconsax.menu_board,
                          title: 'Menu control',
                          onTap: () {
                            _showMenuControlBottomSheet(context);
                          },
                        ),
                        _FlatListTile(
                          icon: Icons.settings_outlined,
                          title: 'System settings',
                          onTap: () {
                            context.go('/settings');
                          },
                        ),
                        _FlatListTile(
                          icon: Icons.help_outline_outlined,
                          title: 'Get support',
                          onTap: () {
                            _showHelpDialog(context);
                          },
                        ),
                        _FlatListTile(
                          icon: Icons.info_outline,
                          title: 'About RestaurantOS',
                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),
                        _FlatListTile(
                          icon: Iconsax.logout,
                          title: 'Logout',
                          titleColor: AppColors.danger,
                          iconColor: AppColors.danger,
                          onTap: () => context.go('/onboarding'),
                        ),
                      ],
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }

  void _topUp(WidgetRef ref, double amount) {
    ref.read(customerProvider.notifier).topUpWallet(amount);
    ref.read(walletLedgerProvider.notifier).addTopUp(amount);
  }

  void _showLoyaltyInfo(BuildContext context, int points) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Rewards Program'),
        content: Text(
          'You currently have $points loyalty points. Keep ordering to earn more rewards!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVouchersInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Your Vouchers'),
        content: const Text(
          'You have no active vouchers at the moment. Check back soon for promotions!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProJoinedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Kurchu Pro'),
        content: const Text(
          'Enjoy free delivery and exclusive partner discounts. TOD access details will be sent via SMS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Support Center'),
        content: const Text(
          'Need help with your order? Our support agents are available 24/7. Contact us at support@restaurantos.io.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('About RestaurantOS'),
        content: const Text(
          'RestaurantOS v1.0.0\nPremium White-Label food ordering experience.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTopUpDialog(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Up Wallet',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select an amount to load onto your digital wallet.',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _TopUpButton(
                      amount: 500,
                      primaryColor: primaryColor,
                      onPressed: () {
                        _topUp(ref, 500);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TopUpButton(
                      amount: 1000,
                      primaryColor: primaryColor,
                      onPressed: () {
                        _topUp(ref, 1000);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TopUpButton(
                      amount: 2500,
                      primaryColor: primaryColor,
                      onPressed: () {
                        _topUp(ref, 2500);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showMenuControlBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final menu = ref.watch(menuProvider);
                return SafeArea(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: MenuManagement(menu: menu),
                  ),
                );
              },
            );
          },
        );
      },
    );
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

class _FlatListTile extends StatelessWidget {
  const _FlatListTile({
    required this.title,
    required this.onTap,
    this.icon,
    this.customIcon,
    this.trailingText,
    this.titleColor,
    this.iconColor,
  }) : trailing = null;

  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? customIcon;
  final String? trailingText;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: SizedBox(
            width: 25,
            height: 25,
            child: Center(
              child:
                  customIcon ??
                  Icon(
                    icon,
                    color: iconColor ?? const Color(0xFF424242),
                    size: 18,
                  ),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor ?? const Color(0xFF1E1E1E),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing:
              trailing ??
              (trailingText != null
                  ? Text(
                      trailingText!,
                      style: const TextStyle(
                        color: Color(0xFF7A7A7A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : null),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 56),
      ],
    );
  }
}
