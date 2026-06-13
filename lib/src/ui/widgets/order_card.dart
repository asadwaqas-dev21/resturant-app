import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/ui/theme.dart';
import 'package:restaurant_os_ai/src/ui/widgets/label_pill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/status_pill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('h:mm a').format(order.createdAt);
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.orderNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LabelPill(
                label: time,
                icon: Iconsax.timer,
                color: AppColors.blue,
              ),
              LabelPill(
                label: order.orderType.label,
                icon: order.orderType.icon,
                color: AppColors.teal,
              ),
              LabelPill(
                label: order.paymentStatus,
                icon: order.paymentMethod.icon,
                color: AppColors.primary,
              ),
              if (order.riderName != null)
                LabelPill(
                  label: order.riderName!,
                  icon: Iconsax.truck_fast,
                  color: AppColors.muted,
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final line in order.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${line.quantity}× ${line.item.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(money(line.lineTotal)),
                ],
              ),
            ),
          if (order.specialInstructions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              order.specialInstructions,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Est. ${DateFormat('h:mm a').format(order.estimatedReadyAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ),
              Text(
                money(order.total),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



