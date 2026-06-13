import 'package:flutter/material.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/ui/widgets/dashboard_card.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/status_pill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class OrderLane extends StatelessWidget {
  const OrderLane({super.key, required this.status, required this.orders});

  final OrderStatus status;
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: StatusPill(status: status)),
            Text('${orders.length}'),
          ],
        ),
        const SizedBox(height: 10),
        if (orders.isEmpty)
          Surface(
            padding: const EdgeInsets.all(12),
            color: AppColors.surfaceAlt,
            child: Text(
              'Clear',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          )
        else
          for (final order in orders) ...[
            DashboardOrderCard(order: order),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}
