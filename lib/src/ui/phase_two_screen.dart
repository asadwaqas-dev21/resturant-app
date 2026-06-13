import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_os_ai/src/domain/advanced_models.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/domain/phase_two_models.dart';
import 'package:restaurant_os_ai/src/state/advanced_providers.dart';
import 'package:restaurant_os_ai/src/state/phase_two_providers.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/choicepill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/empty_state.dart';
import 'package:restaurant_os_ai/src/ui/widgets/iconaction_button.dart';
import 'package:restaurant_os_ai/src/ui/widgets/label_pill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/matric_tile.dart';
import 'package:restaurant_os_ai/src/ui/widgets/section_title.dart';
import 'package:restaurant_os_ai/src/ui/widgets/status_pill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class PhaseTwoScreen extends ConsumerStatefulWidget {
  const PhaseTwoScreen({super.key});

  @override
  ConsumerState<PhaseTwoScreen> createState() => _PhaseTwoScreenState();
}

class _PhaseTwoScreenState extends ConsumerState<PhaseTwoScreen> {
  _HubModule? _selectedModule;

  @override
  Widget build(BuildContext context) {
    final module = _selectedModule;
    if (module == null) {
      return _OperationsHubHome(
        onOpen: (next) {
          setState(() => _selectedModule = next);
        },
      );
    }

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconActionButton(
                  icon: Iconsax.arrow_left_2,
                  tooltip: 'Back',
                  onPressed: () => setState(() => _selectedModule = null),
                ),
                const SizedBox(width: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: module.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(module.icon, color: module.color),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        module.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: module.body),
      ],
    );
  }
}

class _OperationsHubHome extends ConsumerWidget {
  const _OperationsHubHome({required this.onOpen});

  final ValueChanged<_HubModule> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final riders = ref.watch(ridersProvider);
    final customers = ref.watch(crmCustomersProvider);
    final campaigns = ref.watch(campaignsProvider);
    final branches = ref.watch(branchesProvider);
    final recommendations = ref.watch(aiRecommendationsProvider);

    final kitchenTickets = orders
        .where(
          (order) => {
            OrderStatus.pending,
            OrderStatus.confirmed,
            OrderStatus.preparing,
            OrderStatus.ready,
          }.contains(order.status),
        )
        .length;

    final modules = [
      _HubModule(
        title: 'Kitchen',
        caption: '$kitchenTickets active tickets',
        icon: Iconsax.monitor,
        color: AppColors.primary,
        body: const KitchenDisplayTab(),
      ),
      _HubModule(
        title: 'Riders',
        caption:
            '${riders.where((rider) => rider.availability != RiderAvailability.offline).length} online riders',
        icon: Iconsax.truck_fast,
        color: AppColors.teal,
        body: const RiderDispatchTab(),
      ),
      _HubModule(
        title: 'Customers',
        caption: '${customers.length} CRM profiles',
        icon: Iconsax.profile_2user,
        color: AppColors.blue,
        body: const CustomerCrmTab(),
      ),
      _HubModule(
        title: 'Growth',
        caption: '${campaigns.length} campaigns and reviews',
        icon: Iconsax.notification,
        color: AppColors.saffron,
        body: const GrowthTab(),
      ),
      _HubModule(
        title: 'Branches',
        caption: '${branches.length} service locations',
        icon: Iconsax.buildings,
        color: AppColors.success,
        body: const BranchManagementTab(),
      ),
      _HubModule(
        title: 'Intelligence',
        caption: '${recommendations.length} actions and brand tools',
        icon: Iconsax.lamp_on,
        color: AppColors.danger,
        body: const IntelligenceTab(),
      ),
    ];

    return _PhaseScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.cpu_setting, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Operations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Open one module at a time.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          for (final module in modules) ...[
            _HubModuleCard(module: module, onTap: () => onOpen(module)),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _HubModule {
  const _HubModule({
    required this.title,
    required this.caption,
    required this.icon,
    required this.color,
    required this.body,
  });

  final String title;
  final String caption;
  final IconData icon;
  final Color color;
  final Widget body;
}

class _HubModuleCard extends StatelessWidget {
  const _HubModuleCard({required this.module, required this.onTap});

  final _HubModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Surface(
      onTap: onTap,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: module.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Icon(module.icon, color: module.color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  module.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Iconsax.arrow_right_3, color: AppColors.muted),
        ],
      ),
    );
  }
}

class KitchenDisplayTab extends ConsumerWidget {
  const KitchenDisplayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final kitchenOrders = orders
        .where(
          (order) => {
            OrderStatus.pending,
            OrderStatus.confirmed,
            OrderStatus.preparing,
            OrderStatus.ready,
          }.contains(order.status),
        )
        .toList();
    final columns = MediaQuery.sizeOf(context).width >= 1000 ? 3 : 1;

    return _PhaseScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhaseMetrics(
            metrics: [
              _PhaseMetric(
                'Tickets',
                '${kitchenOrders.length}',
                Iconsax.receipt_item,
                AppColors.primary,
              ),
              _PhaseMetric(
                'Preparing',
                '${kitchenOrders.where((order) => order.status == OrderStatus.preparing).length}',
                Iconsax.timer_start,
                AppColors.saffron,
              ),
              _PhaseMetric(
                'Ready',
                '${kitchenOrders.where((order) => order.status == OrderStatus.ready).length}',
                Iconsax.tick_circle,
                AppColors.teal,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Kitchen display'),
          const SizedBox(height: 12),
          if (kitchenOrders.isEmpty)
            const EmptyState(
              icon: Iconsax.monitor,
              title: 'No kitchen tickets',
              body: 'Confirmed and preparing orders appear here.',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 1.85 : 1.05,
              ),
              itemCount: kitchenOrders.length,
              itemBuilder: (context, index) =>
                  KitchenTicketCard(order: kitchenOrders[index]),
            ),
        ],
      ),
    );
  }
}

class KitchenTicketCard extends ConsumerWidget {
  const KitchenTicketCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = order.status.next;
    final minutesAgo = DateTime.now().difference(order.createdAt).inMinutes;
    return Surface(
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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              StatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          LabelPill(
            label: '$minutesAgo min in queue',
            icon: Iconsax.timer,
            color: minutesAgo > 18 ? AppColors.danger : AppColors.blue,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final line in order.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text(
                      '${line.quantity}x ${line.item.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (order.specialInstructions.isNotEmpty)
                  Text(
                    order.specialInstructions,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: next == null
                  ? null
                  : () => ref.read(ordersProvider.notifier).advance(order.id),
              icon: const Icon(Iconsax.tick_circle, size: 17),
              label: Text(order.status.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class RiderDispatchTab extends ConsumerWidget {
  const RiderDispatchTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riders = ref.watch(ridersProvider);
    final deliveries = ref.watch(deliveriesProvider);
    final activeDeliveries = deliveries
        .where((delivery) => delivery.status != DeliveryStatus.delivered)
        .toList();

    return _PhaseScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhaseMetrics(
            metrics: [
              _PhaseMetric(
                'Online riders',
                '${riders.where((rider) => rider.availability == RiderAvailability.online).length}',
                Iconsax.truck_fast,
                AppColors.teal,
              ),
              _PhaseMetric(
                'Active jobs',
                '${activeDeliveries.length}',
                Iconsax.routing,
                AppColors.primary,
              ),
              _PhaseMetric(
                'Avg ETA',
                '${_avgEta(activeDeliveries)} min',
                Iconsax.timer,
                AppColors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 960;
              final riderPanel = _RiderList(riders: riders);
              final deliveryPanel = _DeliveryList(
                deliveries: deliveries,
                riders: riders,
              );
              if (!twoColumns) {
                return Column(
                  children: [
                    riderPanel,
                    const SizedBox(height: 14),
                    deliveryPanel,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: riderPanel),
                  const SizedBox(width: 14),
                  Expanded(flex: 2, child: deliveryPanel),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  int _avgEta(List<DeliveryTask> deliveries) {
    if (deliveries.isEmpty) return 0;
    final total = deliveries.fold<int>(
      0,
      (sum, delivery) => sum + delivery.etaMinutes,
    );
    return (total / deliveries.length).round();
  }
}

class _RiderList extends ConsumerWidget {
  const _RiderList({required this.riders});

  final List<RiderProfile> riders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Riders'),
          const SizedBox(height: 12),
          for (final rider in riders) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rider.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${rider.completedToday} drops today | ${rider.rating.toStringAsFixed(1)} rating',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                ChoicePill(
                  label: rider.availability.label,
                  selected: rider.availability != RiderAvailability.offline,
                  onTap: () =>
                      ref.read(ridersProvider.notifier).toggleOnline(rider.id),
                  compact: true,
                  icon: rider.availability == RiderAvailability.offline
                      ? Iconsax.close_circle
                      : Iconsax.tick_circle,
                ),
              ],
            ),
            if (rider != riders.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _DeliveryList extends ConsumerWidget {
  const _DeliveryList({required this.deliveries, required this.riders});

  final List<DeliveryTask> deliveries;
  final List<RiderProfile> riders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Delivery tracking'),
          const SizedBox(height: 12),
          for (final delivery in deliveries) ...[
            DeliveryTaskCard(delivery: delivery, riders: riders),
            if (delivery != deliveries.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class DeliveryTaskCard extends ConsumerWidget {
  const DeliveryTaskCard({
    super.key,
    required this.delivery,
    required this.riders,
  });

  final DeliveryTask delivery;
  final List<RiderProfile> riders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rider = riders
        .where((candidate) => candidate.id == delivery.riderId)
        .firstOrNull;
    final onlineRider = riders
        .where(
          (candidate) => candidate.availability == RiderAvailability.online,
        )
        .firstOrNull;
    final canAssign = delivery.riderId == null && onlineRider != null;
    final canAdvance = delivery.status.next != null && delivery.riderId != null;

    return Surface(
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${delivery.orderNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              LabelPill(
                label: delivery.status.label,
                icon: Iconsax.routing,
                color: _deliveryColor(delivery.status),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LabelPill(
                label: '${delivery.distanceKm.toStringAsFixed(1)} km',
                icon: Iconsax.routing,
                color: AppColors.blue,
              ),
              LabelPill(
                label: '${delivery.etaMinutes} min ETA',
                icon: Iconsax.timer,
                color: AppColors.saffron,
              ),
              LabelPill(
                label: rider?.name ?? 'Unassigned',
                icon: Iconsax.user,
                color: AppColors.teal,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            delivery.dropoffAddress,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canAssign
                      ? () => ref
                            .read(deliveriesProvider.notifier)
                            .assign(delivery.id, onlineRider.id)
                      : canAdvance
                      ? () => ref
                            .read(deliveriesProvider.notifier)
                            .advance(delivery.id)
                      : null,
                  icon: const Icon(Iconsax.truck_fast, size: 17),
                  label: Text(
                    canAssign
                        ? 'Assign ${onlineRider.name}'
                        : delivery.status.actionLabel,
                  ),
                ),
              ),
              if (delivery.status != DeliveryStatus.delivered) ...[
                const SizedBox(width: 8),
                IconActionButton(
                  icon: Iconsax.close_circle,
                  tooltip: 'Reject delivery',
                  color: AppColors.danger,
                  onPressed: () =>
                      ref.read(deliveriesProvider.notifier).reject(delivery.id),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class CustomerCrmTab extends ConsumerWidget {
  const CustomerCrmTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(customerProvider);
    final ledger = ref.watch(walletLedgerProvider);
    final customers = ref.watch(crmCustomersProvider);
    final referral = ref.watch(referralProgramProvider);

    return _PhaseScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhaseMetrics(
            metrics: [
              _PhaseMetric(
                'Wallet',
                money(profile.walletBalance),
                Iconsax.wallet,
                AppColors.teal,
              ),
              _PhaseMetric(
                'Loyalty',
                '${profile.loyaltyPoints} pts',
                Iconsax.crown,
                AppColors.saffron,
              ),
              _PhaseMetric(
                'Referral rate',
                '${(referral.conversionRate * 100).round()}%',
                Iconsax.profile_2user,
                AppColors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 980;
              final wallet = WalletAndReferralPanel(
                profile: profile,
                ledger: ledger,
                referral: referral,
              );
              final crm = CrmCustomerPanel(customers: customers);
              if (!twoColumns) {
                return Column(
                  children: [wallet, const SizedBox(height: 14), crm],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: wallet),
                  const SizedBox(width: 14),
                  Expanded(child: crm),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class WalletAndReferralPanel extends ConsumerWidget {
  const WalletAndReferralPanel({
    super.key,
    required this.profile,
    required this.ledger,
    required this.referral,
  });

  final CustomerProfile profile;
  final List<WalletLedgerEntry> ledger;
  final ReferralProgram referral;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Wallet and referral'),
          const SizedBox(height: 12),
          Surface(
            color: AppColors.surfaceAlt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text('Balance ${money(profile.walletBalance)}'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _topUp(ref, 500),
                      icon: const Icon(Iconsax.wallet_add, size: 17),
                      label: const Text('Top up 500'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _topUp(ref, 1000),
                      icon: const Icon(Iconsax.wallet_add, size: 17),
                      label: const Text('Top up 1000'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Surface(
            color: AppColors.surfaceAlt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral ${referral.code}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  '${referral.invitesSent} invites | ${referral.conversions} conversions | ${money(referral.rewardAmount)} reward',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: ref
                          .read(referralProgramProvider.notifier)
                          .sendInvite,
                      icon: const Icon(Iconsax.sms, size: 17),
                      label: const Text('Send invite'),
                    ),
                    OutlinedButton.icon(
                      onPressed: ref
                          .read(referralProgramProvider.notifier)
                          .recordConversion,
                      icon: const Icon(Iconsax.tick_circle, size: 17),
                      label: const Text('Record conversion'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in ledger.take(4)) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  money(entry.amount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: entry.amount >= 0
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
              ],
            ),
            if (entry != ledger.take(4).last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }

  void _topUp(WidgetRef ref, double amount) {
    ref.read(customerProvider.notifier).topUpWallet(amount);
    ref.read(walletLedgerProvider.notifier).addTopUp(amount);
  }
}

class CrmCustomerPanel extends StatelessWidget {
  const CrmCustomerPanel({super.key, required this.customers});

  final List<CrmCustomer> customers;

  @override
  Widget build(BuildContext context) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Customer CRM'),
          const SizedBox(height: 12),
          for (final customer in customers) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${customer.orders} orders | ${money(customer.totalSpent)} | last ${customer.lastOrderDaysAgo}d',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                LabelPill(
                  label: customer.segment,
                  icon: Iconsax.user_tag,
                  color: customer.segment == 'At risk'
                      ? AppColors.danger
                      : AppColors.teal,
                ),
              ],
            ),
            if (customer != customers.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class GrowthTab extends ConsumerWidget {
  const GrowthTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);
    final reviews = ref.watch(reviewsProvider);
    final avgRating =
        reviews.fold<int>(0, (sum, review) => sum + review.rating) /
        reviews.length;

    return _PhaseScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhaseMetrics(
            metrics: [
              _PhaseMetric(
                'Campaigns',
                '${campaigns.length}',
                Iconsax.notification,
                AppColors.primary,
              ),
              _PhaseMetric(
                'Recipients',
                '${campaigns.fold<int>(0, (sum, campaign) => sum + campaign.recipients)}',
                Iconsax.sms,
                AppColors.blue,
              ),
              _PhaseMetric(
                'Reviews',
                avgRating.toStringAsFixed(1),
                Iconsax.star,
                AppColors.saffron,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 980;
              final campaignPanel = CampaignPanel(campaigns: campaigns);
              final reviewPanel = ReviewPanel(reviews: reviews);
              if (!twoColumns) {
                return Column(
                  children: [
                    campaignPanel,
                    const SizedBox(height: 14),
                    reviewPanel,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: campaignPanel),
                  const SizedBox(width: 14),
                  Expanded(child: reviewPanel),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class CampaignPanel extends ConsumerWidget {
  const CampaignPanel({super.key, required this.campaigns});

  final List<MarketingCampaign> campaigns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Push campaigns'),
          const SizedBox(height: 12),
          for (final campaign in campaigns) ...[
            Surface(
              color: AppColors.surfaceAlt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          campaign.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      LabelPill(
                        label: campaign.status.label,
                        icon: Iconsax.notification,
                        color: _campaignColor(campaign.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    campaign.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      LabelPill(
                        label: campaign.audience,
                        icon: Iconsax.profile_2user,
                        color: AppColors.blue,
                      ),
                      LabelPill(
                        label: '${campaign.recipients} recipients',
                        icon: Iconsax.sms,
                        color: AppColors.teal,
                      ),
                      LabelPill(
                        label: '${campaign.opens} opens',
                        icon: Iconsax.eye,
                        color: AppColors.saffron,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: campaign.status == CampaignStatus.sent
                            ? null
                            : () => ref
                                  .read(campaignsProvider.notifier)
                                  .sendNow(campaign.id),
                        icon: const Icon(Iconsax.send_1, size: 17),
                        label: const Text('Send now'),
                      ),
                      OutlinedButton.icon(
                        onPressed: campaign.status == CampaignStatus.sent
                            ? null
                            : () => ref
                                  .read(campaignsProvider.notifier)
                                  .scheduleTomorrow(campaign.id),
                        icon: const Icon(Iconsax.calendar_add, size: 17),
                        label: const Text('Schedule'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (campaign != campaigns.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class ReviewPanel extends ConsumerWidget {
  const ReviewPanel({super.key, required this.reviews});

  final List<Review> reviews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Reviews'),
          const SizedBox(height: 12),
          for (final review in reviews) ...[
            Surface(
              color: AppColors.surfaceAlt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          review.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      LabelPill(
                        label: '${review.rating}',
                        icon: Iconsax.star,
                        color: AppColors.saffron,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.itemName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.comment,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (review.response != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Response: ${review.response}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.teal),
                    ),
                  ],
                  if (review.response == null) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => ref
                          .read(reviewsProvider.notifier)
                          .respond(
                            review.id,
                            'Thanks for the feedback. We are sharing this with the branch team.',
                          ),
                      icon: const Icon(Iconsax.message_tick, size: 17),
                      label: const Text('Respond'),
                    ),
                  ],
                ],
              ),
            ),
            if (review != reviews.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class BranchManagementTab extends ConsumerWidget {
  const BranchManagementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(branchesProvider);
    final openBranches = branches.where((branch) => branch.isOpen).length;
    final revenue = branches.fold<double>(
      0,
      (sum, branch) => sum + branch.revenueToday,
    );

    return _PhaseScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhaseMetrics(
            metrics: [
              _PhaseMetric(
                'Branches',
                '${branches.length}',
                Iconsax.buildings,
                AppColors.blue,
              ),
              _PhaseMetric(
                'Open',
                '$openBranches',
                Iconsax.tick_circle,
                AppColors.teal,
              ),
              _PhaseMetric(
                'Revenue',
                money(revenue),
                Iconsax.status_up,
                AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Branch management'),
          const SizedBox(height: 12),
          for (final branch in branches) ...[
            BranchCard(branch: branch),
            if (branch != branches.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class BranchCard extends ConsumerWidget {
  const BranchCard({super.key, required this.branch});

  final BranchSummary branch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${branch.city} | ${branch.ordersToday} orders | avg prep ${branch.avgPrepMinutes} min',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              LabelPill(
                label: branch.isOpen ? 'Open' : 'Closed',
                icon: branch.isOpen
                    ? Iconsax.tick_circle
                    : Iconsax.close_circle,
                color: branch.isOpen ? AppColors.success : AppColors.danger,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoicePill(
                label: branch.isOpen ? 'Open' : 'Closed',
                icon: Iconsax.shop,
                selected: branch.isOpen,
                compact: true,
                onTap: () =>
                    ref.read(branchesProvider.notifier).toggleOpen(branch.id),
              ),
              ChoicePill(
                label: 'Delivery',
                icon: Iconsax.truck_fast,
                selected: branch.deliveryEnabled,
                compact: true,
                onTap: () => ref
                    .read(branchesProvider.notifier)
                    .toggleDelivery(branch.id),
              ),
              ChoicePill(
                label: 'Pickup',
                icon: Iconsax.bag_tick,
                selected: branch.pickupEnabled,
                compact: true,
                onTap: () =>
                    ref.read(branchesProvider.notifier).togglePickup(branch.id),
              ),
              ChoicePill(
                label: 'Dine in',
                icon: Iconsax.reserve,
                selected: branch.dineInEnabled,
                compact: true,
                onTap: () =>
                    ref.read(branchesProvider.notifier).toggleDineIn(branch.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            money(branch.revenueToday),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class IntelligenceTab extends ConsumerWidget {
  const IntelligenceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(aiRecommendationsProvider);
    final insights = ref.watch(advancedInsightsProvider);
    final tables = ref.watch(qrTablesProvider);
    final reservations = ref.watch(reservationsProvider);
    final inventory = ref.watch(inventoryProvider);
    final tenants = ref.watch(tenantsProvider);
    final crypto = ref.watch(cryptoPaymentsProvider);
    final criticalStock = inventory
        .where((item) => item.status != InventoryStatus.healthy)
        .length;

    return _PhaseScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhaseMetrics(
            metrics: [
              _PhaseMetric(
                'AI actions',
                '${recommendations.length}',
                Iconsax.lamp_on,
                AppColors.primary,
              ),
              _PhaseMetric(
                'QR tables',
                '${tables.where((table) => table.isActive).length}/${tables.length}',
                Iconsax.scan_barcode,
                AppColors.blue,
              ),
              _PhaseMetric(
                'Stock alerts',
                '$criticalStock',
                Iconsax.box_time,
                AppColors.saffron,
              ),
              _PhaseMetric(
                'Tenants',
                '${tenants.length}',
                Iconsax.buildings,
                AppColors.teal,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 980;
              final left = Column(
                children: [
                  AiActionPanel(
                    recommendations: recommendations,
                    insights: insights,
                  ),
                  const SizedBox(height: 14),
                  InventoryPanel(inventory: inventory),
                  const SizedBox(height: 14),
                  WhiteLabelPanel(crypto: crypto),
                ],
              );
              final right = Column(
                children: [
                  QrReservationPanel(
                    tables: tables,
                    reservations: reservations,
                  ),
                  const SizedBox(height: 14),
                  TenantAdminPanel(tenants: tenants),
                ],
              );
              if (!twoColumns) {
                return Column(
                  children: [left, const SizedBox(height: 14), right],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 14),
                  Expanded(child: right),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class AiActionPanel extends StatelessWidget {
  const AiActionPanel({
    super.key,
    required this.recommendations,
    required this.insights,
  });

  final List<AiRecommendation> recommendations;
  final List<AdvancedInsight> insights;

  @override
  Widget build(BuildContext context) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'AI action desk'),
          const SizedBox(height: 12),
          for (final recommendation in recommendations) ...[
            Surface(
              color: AppColors.surfaceAlt,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.lamp_on, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recommendation.reason,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            LabelPill(
                              label:
                                  '${(recommendation.confidence * 100).round()}% confidence',
                              icon: Iconsax.ranking,
                              color: AppColors.teal,
                            ),
                            LabelPill(
                              label: recommendation.action,
                              icon: Iconsax.tick_circle,
                              color: AppColors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (recommendation != recommendations.last)
              const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          const SectionTitle(title: 'Insights'),
          const SizedBox(height: 10),
          for (final insight in insights) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.chart_success, color: AppColors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(insight.title),
                      Text(
                        insight.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                LabelPill(label: insight.impact, color: AppColors.primary),
              ],
            ),
            if (insight != insights.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class QrReservationPanel extends ConsumerWidget {
  const QrReservationPanel({
    super.key,
    required this.tables,
    required this.reservations,
  });

  final List<QrTable> tables;
  final List<Reservation> reservations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'QR ordering and reservations'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final table in tables)
                ChoicePill(
                  label: '${table.label} (${table.ordersToday})',
                  icon: Iconsax.scan_barcode,
                  selected: table.isActive,
                  compact: true,
                  onTap: () =>
                      ref.read(qrTablesProvider.notifier).toggle(table.id),
                ),
            ],
          ),
          const SizedBox(height: 14),
          for (final reservation in reservations) ...[
            Surface(
              color: AppColors.surfaceAlt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reservation.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      LabelPill(
                        label: reservation.status.label,
                        icon: Iconsax.reserve,
                        color: _reservationColor(reservation.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${reservation.partySize} guests | ${reservation.tableLabel} | ${DateFormat('h:mm a').format(reservation.time)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            reservation.status == ReservationStatus.completed
                            ? null
                            : () => ref
                                  .read(reservationsProvider.notifier)
                                  .seat(reservation.id),
                        icon: const Icon(Iconsax.reserve, size: 17),
                        label: const Text('Seat'),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            reservation.status == ReservationStatus.completed
                            ? null
                            : () => ref
                                  .read(reservationsProvider.notifier)
                                  .complete(reservation.id),
                        icon: const Icon(Iconsax.tick_circle, size: 17),
                        label: const Text('Complete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (reservation != reservations.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class InventoryPanel extends ConsumerWidget {
  const InventoryPanel({super.key, required this.inventory});

  final List<InventoryItem> inventory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Inventory'),
          const SizedBox(height: 12),
          for (final item in inventory) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${item.quantity.toStringAsFixed(0)} ${item.unit} | reorder at ${item.reorderAt.toStringAsFixed(0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                LabelPill(
                  label: item.status.label,
                  icon: Iconsax.box,
                  color: _inventoryColor(item.status),
                ),
                const SizedBox(width: 8),
                IconActionButton(
                  icon: Iconsax.box_add,
                  tooltip: 'Reorder',
                  onPressed: () =>
                      ref.read(inventoryProvider.notifier).reorder(item.id),
                ),
              ],
            ),
            if (item != inventory.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class TenantAdminPanel extends ConsumerWidget {
  const TenantAdminPanel({super.key, required this.tenants});

  final List<TenantSummary> tenants;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Super admin'),
          const SizedBox(height: 12),
          for (final tenant in tenants) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${tenant.plan} | ${tenant.branches} branches | ${money(tenant.monthlyRevenue)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                ChoicePill(
                  label: tenant.status.label,
                  icon: Iconsax.buildings,
                  selected: tenant.status != TenantStatus.suspended,
                  compact: true,
                  onTap: () => ref
                      .read(tenantsProvider.notifier)
                      .toggleSuspension(tenant.id),
                ),
              ],
            ),
            if (tenant != tenants.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class WhiteLabelPanel extends ConsumerWidget {
  const WhiteLabelPanel({super.key, required this.crypto});

  final List<CryptoPayment> crypto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantProvider);
    final presets = ref.watch(restaurantPresetsProvider);
    final controller = ref.read(restaurantProvider.notifier);
    final primary = colorFromHex(
      restaurant.primaryColorHex,
      fallback: AppColors.primary,
    );
    final secondary = colorFromHex(
      restaurant.secondaryColorHex,
      fallback: AppColors.faint,
    );

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'White-label Studio'),
          const SizedBox(height: 12),
          Row(
            children: [
              _BrandSwatch(primary: primary, secondary: secondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${restaurant.branchName} | ${restaurant.currency} | ${restaurant.timezone}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Client preset', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in presets)
                ChoicePill(
                  label: preset.restaurantName,
                  icon: Iconsax.shop,
                  selected: restaurant.restaurantId == preset.restaurantId,
                  compact: true,
                  onTap: () => controller.activatePreset(preset.restaurantId),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Brand palette', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PaletteButton(
                label: 'Amber',
                primaryHex: '#FF6B35',
                secondaryHex: '#F7F3EC',
                onSelected: controller.applyBrandColors,
              ),
              _PaletteButton(
                label: 'Spice',
                primaryHex: '#9D2F2F',
                secondaryHex: '#FFF1E7',
                onSelected: controller.applyBrandColors,
              ),
              _PaletteButton(
                label: 'Mint',
                primaryHex: '#176B63',
                secondaryHex: '#EAF6F3',
                onSelected: controller.applyBrandColors,
              ),
              _PaletteButton(
                label: 'Royal',
                primaryHex: '#3457D5',
                secondaryHex: '#EEF2FF',
                onSelected: controller.applyBrandColors,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Fulfillment', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoicePill(
                label: 'Delivery',
                icon: Iconsax.truck_fast,
                selected: restaurant.isDeliveryAvailable,
                compact: true,
                onTap: controller.toggleDelivery,
              ),
              ChoicePill(
                label: 'Pickup',
                icon: Iconsax.shop,
                selected: restaurant.isPickupAvailable,
                compact: true,
                onTap: controller.togglePickup,
              ),
              ChoicePill(
                label: 'Dine in',
                icon: Iconsax.reserve,
                selected: restaurant.isDineInAvailable,
                compact: true,
                onTap: controller.toggleDineIn,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Feature flags', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoicePill(
                label: 'Customer app',
                icon: Iconsax.mobile,
                selected: restaurant.customerAppEnabled,
                compact: true,
                onTap: controller.toggleCustomerApp,
              ),
              ChoicePill(
                label: 'Coupons',
                icon: Iconsax.ticket_discount,
                selected: restaurant.couponsEnabled,
                compact: true,
                onTap: controller.toggleCoupons,
              ),
              ChoicePill(
                label: 'Loyalty',
                icon: Iconsax.crown,
                selected: restaurant.loyaltyEnabled,
                compact: true,
                onTap: controller.toggleLoyalty,
              ),
              ChoicePill(
                label: 'Wallet',
                icon: Iconsax.wallet,
                selected: restaurant.walletEnabled,
                compact: true,
                onTap: controller.toggleWallet,
              ),
              ChoicePill(
                label: 'Urdu',
                icon: Iconsax.translate,
                selected: restaurant.urduEnabled,
                compact: true,
                onTap: controller.toggleUrdu,
              ),
              ChoicePill(
                label: 'Campaigns',
                icon: Iconsax.notification,
                selected: restaurant.campaignsEnabled,
                compact: true,
                onTap: controller.toggleCampaigns,
              ),
              ChoicePill(
                label: 'AI',
                icon: Iconsax.lamp_on,
                selected: restaurant.aiEnabled,
                compact: true,
                onTap: controller.toggleAi,
              ),
              ChoicePill(
                label: 'QR',
                icon: Iconsax.scan_barcode,
                selected: restaurant.qrOrderingEnabled,
                compact: true,
                onTap: controller.toggleQrOrdering,
              ),
              ChoicePill(
                label: 'Reservations',
                icon: Iconsax.reserve,
                selected: restaurant.reservationsEnabled,
                compact: true,
                onTap: controller.toggleReservations,
              ),
              ChoicePill(
                label: 'Crypto',
                icon: Iconsax.bitcoin_card,
                selected: restaurant.cryptoEnabled,
                compact: true,
                onTap: controller.toggleCrypto,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SectionTitle(
            title: 'Crypto payments',
            trailing: LabelPill(
              label: restaurant.cryptoEnabled ? 'Enabled' : 'Disabled',
              icon: Iconsax.bitcoin_convert,
              color: restaurant.cryptoEnabled
                  ? AppColors.teal
                  : AppColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          if (restaurant.cryptoEnabled)
            for (final payment in crypto) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${payment.orderNumber} | ${payment.asset} | ${money(payment.amountPkr)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ChoicePill(
                    label: payment.status,
                    icon: Iconsax.bitcoin_convert,
                    selected: payment.status == 'confirmed',
                    compact: true,
                    onTap: () => ref
                        .read(cryptoPaymentsProvider.notifier)
                        .confirm(payment.id),
                  ),
                ],
              ),
              if (payment != crypto.last) const Divider(height: 18),
            ]
          else
            Text(
              'Not included in this client package.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}

class _BrandSwatch extends StatelessWidget {
  const _BrandSwatch({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: SizedBox(
        width: 52,
        height: 52,
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 28),
          ),
        ),
      ),
    );
  }
}

class _PaletteButton extends StatelessWidget {
  const _PaletteButton({
    required this.label,
    required this.primaryHex,
    required this.secondaryHex,
    required this.onSelected,
  });

  final String label;
  final String primaryHex;
  final String secondaryHex;
  final void Function(String primaryHex, String secondaryHex) onSelected;

  @override
  Widget build(BuildContext context) {
    final primary = colorFromHex(primaryHex, fallback: AppColors.primary);
    final secondary = colorFromHex(secondaryHex, fallback: AppColors.faint);

    return OutlinedButton.icon(
      onPressed: () => onSelected(primaryHex, secondaryHex),
      icon: DecoratedBox(
        decoration: BoxDecoration(
          color: secondary,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: DecoratedBox(
            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 12),
          ),
        ),
      ),
      label: Text(label),
    );
  }
}

class _PhaseScroll extends StatelessWidget {
  const _PhaseScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          constraints: const BoxConstraints(maxWidth: 1240),
          child: child,
        ),
      ),
    );
  }
}

class _PhaseMetrics extends StatelessWidget {
  const _PhaseMetrics({required this.metrics});

  final List<_PhaseMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1180
        ? metrics.length
        : width >= 760
        ? 2
        : 1;
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: columns == 1 ? 3.8 : 3.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final metric in metrics)
          MetricTile(
            label: metric.label,
            value: metric.value,
            icon: metric.icon,
            color: metric.color,
          ),
      ],
    );
  }
}

class _PhaseMetric {
  const _PhaseMetric(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

Color _deliveryColor(DeliveryStatus status) {
  switch (status) {
    case DeliveryStatus.pending:
      return AppColors.saffron;
    case DeliveryStatus.assigned:
    case DeliveryStatus.accepted:
      return AppColors.blue;
    case DeliveryStatus.pickedUp:
    case DeliveryStatus.outForDelivery:
      return AppColors.primary;
    case DeliveryStatus.delivered:
      return AppColors.success;
    case DeliveryStatus.rejected:
      return AppColors.danger;
  }
}

Color _campaignColor(CampaignStatus status) {
  switch (status) {
    case CampaignStatus.draft:
      return AppColors.muted;
    case CampaignStatus.scheduled:
      return AppColors.blue;
    case CampaignStatus.sent:
      return AppColors.success;
  }
}

Color _reservationColor(ReservationStatus status) {
  switch (status) {
    case ReservationStatus.pending:
      return AppColors.saffron;
    case ReservationStatus.seated:
      return AppColors.blue;
    case ReservationStatus.completed:
      return AppColors.success;
    case ReservationStatus.cancelled:
      return AppColors.danger;
  }
}

Color _inventoryColor(InventoryStatus status) {
  switch (status) {
    case InventoryStatus.healthy:
      return AppColors.success;
    case InventoryStatus.low:
      return AppColors.saffron;
    case InventoryStatus.critical:
      return AppColors.danger;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
