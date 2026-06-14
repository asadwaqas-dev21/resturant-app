import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/empty_state.dart';
import 'package:restaurant_os_ai/src/ui/widgets/iconaction_button.dart';
import 'package:restaurant_os_ai/src/ui/widgets/section_title.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key, this.isStandalone = false});

  final bool isStandalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final totals = ref.watch(cartTotalsProvider);

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
          const SizedBox(height: 12),
          Surface(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${cart.itemCount} items)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  money(totals.subtotal),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/checkout'),
              icon: const Icon(Iconsax.arrow_right_3),
              label: const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ],
    );

    if (isStandalone) {
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
