import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.surface,
    this.radius = 16,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: const BorderSide(color: AppColors.border, width: 0.5),
    );

    Widget content = Padding(padding: padding, child: child);

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }

    return Material(
      color: color,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

final _moneyFormat = NumberFormat.currency(
  locale: 'en_AE',
  symbol: 'AED ',
  decimalDigits: 2,
);

String money(num value) => _moneyFormat.format(value);
