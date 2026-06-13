import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/widgets/order_card.dart';
import 'package:restaurant_os_ai/src/ui/widgets/section_title.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final width = MediaQuery.sizeOf(context).width;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        width >= 700 ? 24 : 16,
        18,
        width >= 700 ? 24 : 16,
        96,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: 'Orders'),
              const SizedBox(height: 12),
              for (final order in orders) ...[
                OrderCard(order: order),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

