import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/widgets/insights_panel.dart';
import 'package:restaurant_os_ai/src/ui/screens/liveorder_board.dart';
import 'package:restaurant_os_ai/src/ui/widgets/manu_management.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/matric_tile.dart';
import 'package:restaurant_os_ai/src/ui/widgets/section_title.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final menu = ref.watch(menuProvider);
    final liveOrders = orders
        .where(
          (order) => !{
            OrderStatus.delivered,
            OrderStatus.cancelled,
          }.contains(order.status),
        )
        .toList();
    final revenue = orders
        .where((order) => order.status != OrderStatus.cancelled)
        .fold<double>(0, (sum, order) => sum + order.total);
    final availableItems = menu.where((item) => item.isAvailable).length;
    final width = MediaQuery.sizeOf(context).width;
    final metricColumns = width >= 1180
        ? 4
        : width >= 760
        ? 2
        : 1;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        width >= 700 ? 24 : 16,
        18,
        width >= 700 ? 24 : 16,
        96,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: 'Operations'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: metricColumns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: metricColumns == 1 ? 3.8 : 3.1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  MetricTile(
                    label: 'Live orders',
                    value: '${liveOrders.length}',
                    icon: Iconsax.receipt_item,
                    color: AppColors.primary,
                  ),
                  MetricTile(
                    label: 'Revenue',
                    value: money(revenue),
                    icon: Iconsax.status_up,
                    color: AppColors.teal,
                  ),
                  MetricTile(
                    label: 'Menu online',
                    value: '$availableItems/${menu.length}',
                    icon: Iconsax.menu_board,
                    color: AppColors.blue,
                  ),
                  MetricTile(
                    label: 'Avg rating',
                    value: '4.8',
                    icon: Iconsax.star,
                    color: AppColors.saffron,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumns = constraints.maxWidth >= 920;
                  final liveBoard = LiveOrderBoard(orders: liveOrders);
                  final menuManager = MenuManagement(menu: menu);
                  if (!twoColumns) {
                    return Column(
                      children: [
                        liveBoard,
                        const SizedBox(height: 14),
                        menuManager,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: liveBoard),
                      const SizedBox(width: 14),
                      Expanded(flex: 2, child: menuManager),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              const InsightsPanel(),
            ],
          ),
        ),
      ),
    );
  }
}
