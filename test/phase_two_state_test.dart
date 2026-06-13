import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_os_ai/src/domain/phase_two_models.dart';
import 'package:restaurant_os_ai/src/state/phase_two_providers.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';

void main() {
  test('delivery can be assigned and advanced', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(deliveriesProvider.notifier)
        .assign('delivery-1086', 'rider-hamza');
    var delivery = container
        .read(deliveriesProvider)
        .firstWhere((task) => task.id == 'delivery-1086');

    expect(delivery.riderId, 'rider-hamza');
    expect(delivery.status, DeliveryStatus.assigned);

    container.read(deliveriesProvider.notifier).advance('delivery-1086');
    delivery = container
        .read(deliveriesProvider)
        .firstWhere((task) => task.id == 'delivery-1086');

    expect(delivery.status, DeliveryStatus.accepted);
  });

  test('wallet top-up updates customer and ledger', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final before = container.read(customerProvider).walletBalance;
    container.read(customerProvider.notifier).topUpWallet(500);
    container.read(walletLedgerProvider.notifier).addTopUp(500);

    expect(container.read(customerProvider).walletBalance, before + 500);
    expect(container.read(walletLedgerProvider).first.amount, 500);
  });

  test('branch service flags toggle independently', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(branchesProvider.notifier).toggleDelivery('branch-gulshan');
    final branch = container
        .read(branchesProvider)
        .firstWhere((candidate) => candidate.id == 'branch-gulshan');

    expect(branch.deliveryEnabled, isFalse);
    expect(branch.pickupEnabled, isTrue);
  });

  test('campaign send, review response, and referral changes persist', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(campaignsProvider.notifier).sendNow('campaign-winback');
    expect(
      container
          .read(campaignsProvider)
          .firstWhere((campaign) => campaign.id == 'campaign-winback')
          .status,
      CampaignStatus.sent,
    );

    container.read(reviewsProvider.notifier).respond('review-1', 'Thanks!');
    expect(
      container
          .read(reviewsProvider)
          .firstWhere((review) => review.id == 'review-1')
          .response,
      'Thanks!',
    );

    final beforeInvites = container.read(referralProgramProvider).invitesSent;
    container.read(referralProgramProvider.notifier).sendInvite();
    expect(
      container.read(referralProgramProvider).invitesSent,
      beforeInvites + 1,
    );
  });
}
