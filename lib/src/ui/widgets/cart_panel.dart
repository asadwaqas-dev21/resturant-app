import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/widgets/check_summary.dart';
import 'package:restaurant_os_ai/src/ui/theme.dart';
import 'package:restaurant_os_ai/src/ui/widgets/choicepill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/empty_state.dart';
import 'package:restaurant_os_ai/src/ui/widgets/iconaction_button.dart';
import 'package:restaurant_os_ai/src/ui/widgets/section_title.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class CartPanel extends ConsumerStatefulWidget {
  const CartPanel({super.key, this.isStandalone = false});

  final bool isStandalone;

  @override
  ConsumerState<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends ConsumerState<CartPanel> {
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
    final paymentAvailable = restaurant.isPaymentMethodAvailable(
      cart.paymentMethod,
    );
    final canPayWithWallet = customer.walletBalance >= totals.total;
    final checkoutEnabled =
        !cart.isEmpty &&
        serviceAvailable &&
        paymentAvailable &&
        (cart.paymentMethod != PaymentMethod.wallet || canPayWithWallet);

    if (_couponController.text.isEmpty && cart.couponCode.isNotEmpty) {
      _couponController.text = cart.couponCode;
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Cart',
          trailing: cart.isEmpty
              ? null
              : TextButton.icon(
                  onPressed: () => ref.read(cartProvider.notifier).clear(),
                  icon: const Icon(Iconsax.trash, size: 17),
                  label: const Text('Clear'),
                ),
        ),
        const SizedBox(height: 12),
        if (cart.isEmpty)
          const EmptyState(
            icon: Iconsax.shopping_cart,
            title: 'Cart is empty',
            body: 'Add menu items to begin checkout.',
          )
        else ...[
          for (final line in cart.lines.values) ...[
            CartLineTile(line: line),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          _ChoiceSection<OrderType>(
            label: 'Order type',
            values: availableOrderTypes,
            selected: cart.orderType,
            onSelected: ref.read(cartProvider.notifier).setOrderType,
            labelFor: (value) => value.label,
            iconFor: (value) => value.icon,
          ),
          const SizedBox(height: 14),
          _ChoiceSection<PaymentMethod>(
            label: 'Payment',
            values: availablePaymentMethods,
            selected: cart.paymentMethod,
            onSelected: ref.read(cartProvider.notifier).setPaymentMethod,
            labelFor: (value) => value.label,
            iconFor: (value) => value.icon,
          ),
          if (cart.paymentMethod == PaymentMethod.wallet &&
              !canPayWithWallet) ...[
            const SizedBox(height: 8),
            Text(
              'Wallet balance is ${money(customer.walletBalance)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
          if (restaurant.couponsEnabled) ...[
            const SizedBox(height: 14),
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
          if (restaurant.loyaltyEnabled) ...[
            const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          TextField(
            minLines: 2,
            maxLines: 3,
            onChanged: ref.read(cartProvider.notifier).setNotes,
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.message_text),
              hintText: 'Special instructions',
            ),
          ),
          const SizedBox(height: 14),
          CheckoutSummary(totals: totals),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: checkoutEnabled ? () => _checkout(context) : null,
              icon: const Icon(Iconsax.receipt_add),
              label: Text('Place order • ${money(totals.total)}'),
            ),
          ),
        ],
      ],
    );

    if (widget.isStandalone) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: content,
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
        child: content,
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
    context.go('/orders');
  }
}

class CartLineTile extends ConsumerWidget {
  const CartLineTile({super.key, required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      padding: const EdgeInsets.all(10),
      color: AppColors.surfaceAlt,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: line.item.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.border),
              errorWidget: (_, _, _) => Container(color: AppColors.border),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  money(line.lineTotal),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconActionButton(
            icon: Iconsax.minus,
            tooltip: 'Decrease',
            onPressed: () =>
                ref.read(cartProvider.notifier).decrement(line.item.id),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text('${line.quantity}'),
          ),
          IconActionButton(
            icon: Iconsax.add,
            tooltip: 'Increase',
            onPressed: () => ref.read(cartProvider.notifier).add(line.item),
          ),
        ],
      ),
    );
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
