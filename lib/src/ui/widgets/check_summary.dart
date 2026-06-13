import 'package:flutter/material.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class CheckoutSummary extends StatelessWidget {
  const CheckoutSummary({super.key, required this.totals});

  final CartTotals totals;

  @override
  Widget build(BuildContext context) {
    return Surface(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: money(totals.subtotal)),
          _SummaryRow(label: 'Discount', value: '-${money(totals.discount)}'),
          _SummaryRow(label: 'Delivery', value: money(totals.deliveryFee)),
          _SummaryRow(label: 'Tax', value: money(totals.tax)),
          _SummaryRow(
            label: 'Loyalty',
            value: '-${money(totals.loyaltyDiscount)}',
          ),
          const Divider(height: 18),
          _SummaryRow(
            label: 'Total',
            value: money(totals.total),
            prominent: true,
          ),
          _SummaryRow(
            label: 'Earns',
            value: '${totals.loyaltyPointsEarned} points',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.prominent = false,
  });

  final String label;
  final String value;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final style = prominent
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.muted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

