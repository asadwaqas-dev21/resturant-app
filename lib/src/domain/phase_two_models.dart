enum RiderAvailability { online, busy, offline }

enum DeliveryStatus {
  pending,
  assigned,
  accepted,
  pickedUp,
  outForDelivery,
  delivered,
  rejected,
}

enum CampaignStatus { draft, scheduled, sent }

extension RiderAvailabilityLabel on RiderAvailability {
  String get label {
    switch (this) {
      case RiderAvailability.online:
        return 'Online';
      case RiderAvailability.busy:
        return 'Busy';
      case RiderAvailability.offline:
        return 'Offline';
    }
  }
}

extension DeliveryStatusLabel on DeliveryStatus {
  String get label {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.assigned:
        return 'Assigned';
      case DeliveryStatus.accepted:
        return 'Accepted';
      case DeliveryStatus.pickedUp:
        return 'Picked up';
      case DeliveryStatus.outForDelivery:
        return 'On the way';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.rejected:
        return 'Rejected';
    }
  }

  String get actionLabel {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Assign';
      case DeliveryStatus.assigned:
        return 'Accept';
      case DeliveryStatus.accepted:
        return 'Pick up';
      case DeliveryStatus.pickedUp:
        return 'Start route';
      case DeliveryStatus.outForDelivery:
        return 'Deliver';
      case DeliveryStatus.delivered:
        return 'Done';
      case DeliveryStatus.rejected:
        return 'Reassign';
    }
  }

  DeliveryStatus? get next {
    switch (this) {
      case DeliveryStatus.pending:
        return DeliveryStatus.assigned;
      case DeliveryStatus.assigned:
        return DeliveryStatus.accepted;
      case DeliveryStatus.accepted:
        return DeliveryStatus.pickedUp;
      case DeliveryStatus.pickedUp:
        return DeliveryStatus.outForDelivery;
      case DeliveryStatus.outForDelivery:
        return DeliveryStatus.delivered;
      case DeliveryStatus.delivered:
        return null;
      case DeliveryStatus.rejected:
        return DeliveryStatus.assigned;
    }
  }
}

extension CampaignStatusLabel on CampaignStatus {
  String get label {
    switch (this) {
      case CampaignStatus.draft:
        return 'Draft';
      case CampaignStatus.scheduled:
        return 'Scheduled';
      case CampaignStatus.sent:
        return 'Sent';
    }
  }
}

class RiderProfile {
  const RiderProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.availability,
    required this.completedToday,
    required this.rating,
    required this.currentLatitude,
    required this.currentLongitude,
  });

  final String id;
  final String name;
  final String phone;
  final RiderAvailability availability;
  final int completedToday;
  final double rating;
  final double currentLatitude;
  final double currentLongitude;

  RiderProfile copyWith({
    RiderAvailability? availability,
    int? completedToday,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return RiderProfile(
      id: id,
      name: name,
      phone: phone,
      availability: availability ?? this.availability,
      completedToday: completedToday ?? this.completedToday,
      rating: rating,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }
}

class DeliveryTask {
  const DeliveryTask({
    required this.id,
    required this.orderNumber,
    required this.pickupBranch,
    required this.dropoffAddress,
    required this.distanceKm,
    required this.status,
    required this.etaMinutes,
    this.riderId,
  });

  final String id;
  final String orderNumber;
  final String pickupBranch;
  final String dropoffAddress;
  final double distanceKm;
  final DeliveryStatus status;
  final int etaMinutes;
  final String? riderId;

  DeliveryTask copyWith({
    DeliveryStatus? status,
    String? riderId,
    int? etaMinutes,
  }) {
    return DeliveryTask(
      id: id,
      orderNumber: orderNumber,
      pickupBranch: pickupBranch,
      dropoffAddress: dropoffAddress,
      distanceKm: distanceKm,
      status: status ?? this.status,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      riderId: riderId ?? this.riderId,
    );
  }
}

class BranchSummary {
  const BranchSummary({
    required this.id,
    required this.name,
    required this.city,
    required this.isOpen,
    required this.deliveryEnabled,
    required this.pickupEnabled,
    required this.dineInEnabled,
    required this.ordersToday,
    required this.revenueToday,
    required this.avgPrepMinutes,
  });

  final String id;
  final String name;
  final String city;
  final bool isOpen;
  final bool deliveryEnabled;
  final bool pickupEnabled;
  final bool dineInEnabled;
  final int ordersToday;
  final double revenueToday;
  final int avgPrepMinutes;

  BranchSummary copyWith({
    bool? isOpen,
    bool? deliveryEnabled,
    bool? pickupEnabled,
    bool? dineInEnabled,
  }) {
    return BranchSummary(
      id: id,
      name: name,
      city: city,
      isOpen: isOpen ?? this.isOpen,
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
      pickupEnabled: pickupEnabled ?? this.pickupEnabled,
      dineInEnabled: dineInEnabled ?? this.dineInEnabled,
      ordersToday: ordersToday,
      revenueToday: revenueToday,
      avgPrepMinutes: avgPrepMinutes,
    );
  }
}

class CrmCustomer {
  const CrmCustomer({
    required this.id,
    required this.name,
    required this.segment,
    required this.orders,
    required this.totalSpent,
    required this.loyaltyPoints,
    required this.lastOrderDaysAgo,
    required this.walletBalance,
  });

  final String id;
  final String name;
  final String segment;
  final int orders;
  final double totalSpent;
  final int loyaltyPoints;
  final int lastOrderDaysAgo;
  final double walletBalance;
}

class MarketingCampaign {
  const MarketingCampaign({
    required this.id,
    required this.title,
    required this.message,
    required this.audience,
    required this.status,
    required this.recipients,
    required this.opens,
    this.scheduledAt,
    this.sentAt,
  });

  final String id;
  final String title;
  final String message;
  final String audience;
  final CampaignStatus status;
  final int recipients;
  final int opens;
  final DateTime? scheduledAt;
  final DateTime? sentAt;

  MarketingCampaign copyWith({
    CampaignStatus? status,
    DateTime? scheduledAt,
    DateTime? sentAt,
    int? opens,
  }) {
    return MarketingCampaign(
      id: id,
      title: title,
      message: message,
      audience: audience,
      status: status ?? this.status,
      recipients: recipients,
      opens: opens ?? this.opens,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}

class Review {
  const Review({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.itemName,
    required this.createdAt,
    this.response,
  });

  final String id;
  final String customerName;
  final int rating;
  final String comment;
  final String itemName;
  final DateTime createdAt;
  final String? response;

  Review copyWith({String? response}) {
    return Review(
      id: id,
      customerName: customerName,
      rating: rating,
      comment: comment,
      itemName: itemName,
      createdAt: createdAt,
      response: response ?? this.response,
    );
  }
}

class WalletLedgerEntry {
  const WalletLedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
    required this.note,
  });

  final String id;
  final String type;
  final double amount;
  final DateTime createdAt;
  final String note;
}

class ReferralProgram {
  const ReferralProgram({
    required this.code,
    required this.rewardAmount,
    required this.invitesSent,
    required this.conversions,
  });

  final String code;
  final double rewardAmount;
  final int invitesSent;
  final int conversions;

  double get conversionRate => invitesSent == 0 ? 0 : conversions / invitesSent;

  ReferralProgram copyWith({int? invitesSent, int? conversions}) {
    return ReferralProgram(
      code: code,
      rewardAmount: rewardAmount,
      invitesSent: invitesSent ?? this.invitesSent,
      conversions: conversions ?? this.conversions,
    );
  }
}
