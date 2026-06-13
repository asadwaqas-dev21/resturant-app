import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/ui/widgets/empty_state.dart';
import 'package:restaurant_os_ai/src/ui/widgets/order_lane.dart';
import 'package:restaurant_os_ai/src/ui/widgets/section_title.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class LiveOrderBoard extends StatelessWidget {
  const LiveOrderBoard({super.key, required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final lanes = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.outForDelivery,
    ];

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Live orders'),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const EmptyState(
              icon: Iconsax.receipt,
              title: 'No active orders',
              body: 'New checkout orders appear here.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final lane in lanes)
                    SizedBox(
                      width: 230,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: OrderLane(
                          status: lane,
                          orders: orders
                              .where((order) => order.status == lane)
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

