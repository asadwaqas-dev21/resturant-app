import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/phase_two_seed_data.dart';
import '../domain/phase_two_models.dart';

final ridersProvider = NotifierProvider<RidersController, List<RiderProfile>>(
  RidersController.new,
);

final deliveriesProvider =
    NotifierProvider<DeliveriesController, List<DeliveryTask>>(
      DeliveriesController.new,
    );

final branchesProvider =
    NotifierProvider<BranchesController, List<BranchSummary>>(
      BranchesController.new,
    );

final crmCustomersProvider = Provider<List<CrmCustomer>>(
  (ref) => demoCrmCustomers,
);

final campaignsProvider =
    NotifierProvider<CampaignsController, List<MarketingCampaign>>(
      CampaignsController.new,
    );

final reviewsProvider = NotifierProvider<ReviewsController, List<Review>>(
  ReviewsController.new,
);

final walletLedgerProvider =
    NotifierProvider<WalletLedgerController, List<WalletLedgerEntry>>(
      WalletLedgerController.new,
    );

final referralProgramProvider =
    NotifierProvider<ReferralProgramController, ReferralProgram>(
      ReferralProgramController.new,
    );

class RidersController extends Notifier<List<RiderProfile>> {
  @override
  List<RiderProfile> build() => List<RiderProfile>.from(demoRiders);

  void toggleOnline(String riderId) {
    state = [
      for (final rider in state)
        if (rider.id == riderId)
          rider.copyWith(
            availability: rider.availability == RiderAvailability.offline
                ? RiderAvailability.online
                : RiderAvailability.offline,
          )
        else
          rider,
    ];
  }

  void markBusy(String riderId) {
    state = [
      for (final rider in state)
        if (rider.id == riderId)
          rider.copyWith(availability: RiderAvailability.busy)
        else
          rider,
    ];
  }

  void markOnline(String riderId) {
    state = [
      for (final rider in state)
        if (rider.id == riderId)
          rider.copyWith(availability: RiderAvailability.online)
        else
          rider,
    ];
  }

  void completeDelivery(String riderId) {
    state = [
      for (final rider in state)
        if (rider.id == riderId)
          rider.copyWith(
            availability: RiderAvailability.online,
            completedToday: rider.completedToday + 1,
          )
        else
          rider,
    ];
  }
}

class DeliveriesController extends Notifier<List<DeliveryTask>> {
  @override
  List<DeliveryTask> build() => List<DeliveryTask>.from(demoDeliveries);

  void assign(String deliveryId, String riderId) {
    state = [
      for (final delivery in state)
        if (delivery.id == deliveryId)
          delivery.copyWith(
            riderId: riderId,
            status: DeliveryStatus.assigned,
            etaMinutes: delivery.etaMinutes == 0 ? 20 : delivery.etaMinutes,
          )
        else
          delivery,
    ];
    ref.read(ridersProvider.notifier).markBusy(riderId);
  }

  void advance(String deliveryId) {
    String? completedRiderId;
    state = [
      for (final delivery in state)
        if (delivery.id == deliveryId && delivery.status.next != null)
          _advanceTask(delivery, (riderId) => completedRiderId = riderId)
        else
          delivery,
    ];
    if (completedRiderId != null) {
      ref.read(ridersProvider.notifier).completeDelivery(completedRiderId!);
    }
  }

  void reject(String deliveryId) {
    state = [
      for (final delivery in state)
        if (delivery.id == deliveryId)
          delivery.copyWith(status: DeliveryStatus.rejected, etaMinutes: 0)
        else
          delivery,
    ];
  }

  DeliveryTask _advanceTask(
    DeliveryTask delivery,
    void Function(String riderId) onDelivered,
  ) {
    final next = delivery.status.next!;
    if (next == DeliveryStatus.delivered && delivery.riderId != null) {
      onDelivered(delivery.riderId!);
    }
    return delivery.copyWith(
      status: next,
      etaMinutes: next == DeliveryStatus.delivered
          ? 0
          : (delivery.etaMinutes - 6).clamp(6, 60),
    );
  }
}

class BranchesController extends Notifier<List<BranchSummary>> {
  @override
  List<BranchSummary> build() => List<BranchSummary>.from(demoBranches);

  void toggleOpen(String branchId) {
    state = [
      for (final branch in state)
        if (branch.id == branchId)
          branch.copyWith(isOpen: !branch.isOpen)
        else
          branch,
    ];
  }

  void toggleDelivery(String branchId) {
    state = [
      for (final branch in state)
        if (branch.id == branchId)
          branch.copyWith(deliveryEnabled: !branch.deliveryEnabled)
        else
          branch,
    ];
  }

  void togglePickup(String branchId) {
    state = [
      for (final branch in state)
        if (branch.id == branchId)
          branch.copyWith(pickupEnabled: !branch.pickupEnabled)
        else
          branch,
    ];
  }

  void toggleDineIn(String branchId) {
    state = [
      for (final branch in state)
        if (branch.id == branchId)
          branch.copyWith(dineInEnabled: !branch.dineInEnabled)
        else
          branch,
    ];
  }
}

class CampaignsController extends Notifier<List<MarketingCampaign>> {
  @override
  List<MarketingCampaign> build() =>
      List<MarketingCampaign>.from(demoCampaigns);

  void sendNow(String campaignId) {
    state = [
      for (final campaign in state)
        if (campaign.id == campaignId)
          campaign.copyWith(
            status: CampaignStatus.sent,
            sentAt: DateTime.now(),
            opens: campaign.opens == 0
                ? (campaign.recipients * 0.22).round()
                : campaign.opens,
          )
        else
          campaign,
    ];
  }

  void scheduleTomorrow(String campaignId) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    state = [
      for (final campaign in state)
        if (campaign.id == campaignId)
          campaign.copyWith(
            status: CampaignStatus.scheduled,
            scheduledAt: DateTime(
              tomorrow.year,
              tomorrow.month,
              tomorrow.day,
              11,
            ),
          )
        else
          campaign,
    ];
  }
}

class ReviewsController extends Notifier<List<Review>> {
  @override
  List<Review> build() => List<Review>.from(demoReviews);

  void respond(String reviewId, String response) {
    state = [
      for (final review in state)
        if (review.id == reviewId)
          review.copyWith(response: response)
        else
          review,
    ];
  }
}

class WalletLedgerController extends Notifier<List<WalletLedgerEntry>> {
  int _sequence = 4;

  @override
  List<WalletLedgerEntry> build() =>
      List<WalletLedgerEntry>.from(demoWalletLedger);

  void addTopUp(double amount) {
    final id = 'wallet-${_sequence++}';
    state = [
      WalletLedgerEntry(
        id: id,
        type: 'top_up',
        amount: amount,
        createdAt: DateTime.now(),
        note: 'Manual dashboard top-up',
      ),
      ...state,
    ];
  }
}

class ReferralProgramController extends Notifier<ReferralProgram> {
  @override
  ReferralProgram build() => demoReferralProgram;

  void sendInvite() {
    state = state.copyWith(invitesSent: state.invitesSent + 1);
  }

  void recordConversion() {
    state = state.copyWith(conversions: state.conversions + 1);
  }
}
