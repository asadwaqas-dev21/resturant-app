import 'package:flutter/material.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          status.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ),
    );
  }
}

Color statusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return AppColors.saffron;
    case OrderStatus.confirmed:
      return AppColors.blue;
    case OrderStatus.preparing:
      return AppColors.primary;
    case OrderStatus.ready:
      return AppColors.teal;
    case OrderStatus.outForDelivery:
      return const Color(0xFF6E5DDC);
    case OrderStatus.delivered:
      return AppColors.success;
    case OrderStatus.cancelled:
      return AppColors.danger;
  }
}

