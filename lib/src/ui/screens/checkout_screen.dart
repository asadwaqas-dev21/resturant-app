import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/check_summary.dart';
import 'package:restaurant_os_ai/src/ui/widgets/choicepill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final totals = ref.watch(cartTotalsProvider);
    final customer = ref.watch(customerProvider);
    final restaurant = ref.watch(restaurantProvider);

    final availableOrderTypes = restaurant.availableOrderTypes;
    final availablePaymentMethods = restaurant.availablePaymentMethods;
    final serviceAvailable = restaurant.isOrderTypeAvailable(cart.orderType);
    final paymentAvailable = restaurant.isPaymentMethodAvailable(cart.paymentMethod);
    final canPayWithWallet = customer.walletBalance >= totals.total;

    final checkoutEnabled =
        !cart.isEmpty &&
        serviceAvailable &&
        paymentAvailable &&
        (cart.paymentMethod != PaymentMethod.wallet || canPayWithWallet);

    if (_couponController.text.isEmpty && cart.couponCode.isNotEmpty) {
      _couponController.text = cart.couponCode;
    }

    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.faint,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.go('/cart'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width >= 390 ? 20 : 16,
            vertical: 20,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChoiceSection<OrderType>(
                  label: 'Order type',
                  values: availableOrderTypes,
                  selected: cart.orderType,
                  onSelected: ref.read(cartProvider.notifier).setOrderType,
                  labelFor: (value) => value.label,
                  iconFor: (value) => value.icon,
                ),
                const SizedBox(height: 16),
                _ChoiceSection<PaymentMethod>(
                  label: 'Payment',
                  values: availablePaymentMethods,
                  selected: cart.paymentMethod,
                  onSelected: ref.read(cartProvider.notifier).setPaymentMethod,
                  labelFor: (value) => value.label,
                  iconFor: (value) => value.icon,
                ),
                if (cart.paymentMethod == PaymentMethod.wallet && !canPayWithWallet) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Wallet balance is ${money(customer.walletBalance)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.danger),
                  ),
                ],
                if (restaurant.couponsEnabled) ...[
                  const SizedBox(height: 16),
                  Text('Coupon Discount', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.ticket_discount),
                            hintText: 'Coupon code',
                          ),
                          onSubmitted: (value) {
                            ref.read(cartProvider.notifier).applyCoupon(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(cartProvider.notifier)
                              .applyCoupon(_couponController.text);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
                if (totals.hasCouponIssue) ...[
                  const SizedBox(height: 6),
                  Text(
                    totals.couponMessage!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.danger),
                  ),
                ],
                if (restaurant.loyaltyEnabled) ...[
                  const SizedBox(height: 16),
                  Text('Redeem Points', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Surface(
                    color: AppColors.surfaceAlt,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Iconsax.crown, color: AppColors.saffron),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${customer.loyaltyPoints} points available',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ChoicePill(
                          label: cart.useLoyalty ? 'Using' : 'Redeem',
                          selected: cart.useLoyalty,
                          onTap: ref.read(cartProvider.notifier).toggleLoyalty,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text('Instructions', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  minLines: 2,
                  maxLines: 3,
                  onChanged: ref.read(cartProvider.notifier).setNotes,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.message_text),
                    hintText: 'Special instructions (e.g. no onions)',
                  ),
                ),
                const SizedBox(height: 20),
                CheckoutSummary(totals: totals),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: checkoutEnabled ? () => _checkout(context) : null,
                    icon: const Icon(Iconsax.receipt_add),
                    label: Text('Place order • ${money(totals.total)}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkout(BuildContext context) {
    final cart = ref.read(cartProvider);
    final totals = ref.read(cartTotalsProvider);
    final restaurant = ref.read(restaurantProvider);
    final order = ref
        .read(ordersProvider.notifier)
        .placeOrder(cart, totals, restaurant);
    ref.read(customerProvider.notifier).settleOrder(totals, cart.paymentMethod);
    ref.read(cartProvider.notifier).clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order #${order.orderNumber} placed')),
    );
    context.go('/thank-you?number=${order.orderNumber}');
  }
}

class _ChoiceSection<T> extends StatelessWidget {
  const _ChoiceSection({
    required this.label,
    required this.values,
    required this.selected,
    required this.onSelected,
    required this.labelFor,
    required this.iconFor,
  });

  final String label;
  final List<T> values;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T value) labelFor;
  final IconData Function(T value) iconFor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              ChoicePill(
                label: labelFor(value),
                icon: iconFor(value),
                selected: value == selected,
                onTap: () => onSelected(value),
                compact: true,
              ),
          ],
        ),
      ],
    );
  }
}
