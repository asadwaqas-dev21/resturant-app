import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/theme.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class DashboardOrderCard extends ConsumerWidget {
  const DashboardOrderCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = order.status.next;
    return Surface(
      padding: const EdgeInsets.all(12),
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.orderNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${order.itemCount} items',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.lines
                .map((line) => '${line.quantity} ${line.item.name}')
                .join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          if (next != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(ordersProvider.notifier).advance(order.id),
                child: Text(order.status.actionLabel),
              ),
            ),
          if (order.status == OrderStatus.pending) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(ordersProvider.notifier).cancel(order.id),
                icon: const Icon(Iconsax.close_circle, size: 17),
                label: const Text('Cancel'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


