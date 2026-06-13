enum ReservationStatus { pending, seated, completed, cancelled }

enum InventoryStatus { healthy, low, critical }

enum TenantStatus { active, trial, suspended }

extension ReservationStatusLabel on ReservationStatus {
  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.seated:
        return 'Seated';
      case ReservationStatus.completed:
        return 'Completed';
      case ReservationStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension InventoryStatusLabel on InventoryStatus {
  String get label {
    switch (this) {
      case InventoryStatus.healthy:
        return 'Healthy';
      case InventoryStatus.low:
        return 'Low';
      case InventoryStatus.critical:
        return 'Critical';
    }
  }
}

extension TenantStatusLabel on TenantStatus {
  String get label {
    switch (this) {
      case TenantStatus.active:
        return 'Active';
      case TenantStatus.trial:
        return 'Trial';
      case TenantStatus.suspended:
        return 'Suspended';
    }
  }
}

class AiRecommendation {
  const AiRecommendation({
    required this.id,
    required this.title,
    required this.reason,
    required this.confidence,
    required this.action,
  });

  final String id;
  final String title;
  final String reason;
  final double confidence;
  final String action;
}

class AdvancedInsight {
  const AdvancedInsight({
    required this.id,
    required this.title,
    required this.body,
    required this.impact,
  });

  final String id;
  final String title;
  final String body;
  final String impact;
}

class QrTable {
  const QrTable({
    required this.id,
    required this.label,
    required this.seats,
    required this.isActive,
    required this.ordersToday,
  });

  final String id;
  final String label;
  final int seats;
  final bool isActive;
  final int ordersToday;

  QrTable copyWith({bool? isActive}) {
    return QrTable(
      id: id,
      label: label,
      seats: seats,
      isActive: isActive ?? this.isActive,
      ordersToday: ordersToday,
    );
  }
}

class Reservation {
  const Reservation({
    required this.id,
    required this.customerName,
    required this.partySize,
    required this.time,
    required this.tableLabel,
    required this.status,
  });

  final String id;
  final String customerName;
  final int partySize;
  final DateTime time;
  final String tableLabel;
  final ReservationStatus status;

  Reservation copyWith({ReservationStatus? status}) {
    return Reservation(
      id: id,
      customerName: customerName,
      partySize: partySize,
      time: time,
      tableLabel: tableLabel,
      status: status ?? this.status,
    );
  }
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.reorderAt,
  });

  final String id;
  final String name;
  final String unit;
  final double quantity;
  final double reorderAt;

  InventoryStatus get status {
    if (quantity <= reorderAt * 0.45) return InventoryStatus.critical;
    if (quantity <= reorderAt) return InventoryStatus.low;
    return InventoryStatus.healthy;
  }

  InventoryItem copyWith({double? quantity}) {
    return InventoryItem(
      id: id,
      name: name,
      unit: unit,
      quantity: quantity ?? this.quantity,
      reorderAt: reorderAt,
    );
  }
}

class TenantSummary {
  const TenantSummary({
    required this.id,
    required this.name,
    required this.plan,
    required this.status,
    required this.branches,
    required this.monthlyRevenue,
  });

  final String id;
  final String name;
  final String plan;
  final TenantStatus status;
  final int branches;
  final double monthlyRevenue;

  TenantSummary copyWith({TenantStatus? status}) {
    return TenantSummary(
      id: id,
      name: name,
      plan: plan,
      status: status ?? this.status,
      branches: branches,
      monthlyRevenue: monthlyRevenue,
    );
  }
}

class WhiteLabelConfig {
  const WhiteLabelConfig({
    required this.appName,
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.logoReady,
    required this.customerAppEnabled,
    required this.urduEnabled,
    required this.cryptoEnabled,
  });

  final String appName;
  final String primaryColorHex;
  final String secondaryColorHex;
  final bool logoReady;
  final bool customerAppEnabled;
  final bool urduEnabled;
  final bool cryptoEnabled;

  WhiteLabelConfig copyWith({
    bool? customerAppEnabled,
    bool? urduEnabled,
    bool? cryptoEnabled,
  }) {
    return WhiteLabelConfig(
      appName: appName,
      primaryColorHex: primaryColorHex,
      secondaryColorHex: secondaryColorHex,
      logoReady: logoReady,
      customerAppEnabled: customerAppEnabled ?? this.customerAppEnabled,
      urduEnabled: urduEnabled ?? this.urduEnabled,
      cryptoEnabled: cryptoEnabled ?? this.cryptoEnabled,
    );
  }
}

class CryptoPayment {
  const CryptoPayment({
    required this.id,
    required this.orderNumber,
    required this.amountPkr,
    required this.asset,
    required this.status,
  });

  final String id;
  final String orderNumber;
  final double amountPkr;
  final String asset;
  final String status;

  CryptoPayment copyWith({String? status}) {
    return CryptoPayment(
      id: id,
      orderNumber: orderNumber,
      amountPkr: amountPkr,
      asset: asset,
      status: status ?? this.status,
    );
  }
}
