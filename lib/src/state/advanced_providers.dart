import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/advanced_seed_data.dart';
import '../domain/advanced_models.dart';

final aiRecommendationsProvider = Provider<List<AiRecommendation>>(
  (ref) => demoAiRecommendations,
);

final advancedInsightsProvider = Provider<List<AdvancedInsight>>(
  (ref) => demoAdvancedInsights,
);

final qrTablesProvider = NotifierProvider<QrTablesController, List<QrTable>>(
  QrTablesController.new,
);

final reservationsProvider =
    NotifierProvider<ReservationsController, List<Reservation>>(
      ReservationsController.new,
    );

final inventoryProvider =
    NotifierProvider<InventoryController, List<InventoryItem>>(
      InventoryController.new,
    );

final tenantsProvider =
    NotifierProvider<TenantsController, List<TenantSummary>>(
      TenantsController.new,
    );

final whiteLabelConfigProvider =
    NotifierProvider<WhiteLabelConfigController, WhiteLabelConfig>(
      WhiteLabelConfigController.new,
    );

final cryptoPaymentsProvider =
    NotifierProvider<CryptoPaymentsController, List<CryptoPayment>>(
      CryptoPaymentsController.new,
    );

class QrTablesController extends Notifier<List<QrTable>> {
  @override
  List<QrTable> build() => List<QrTable>.from(demoQrTables);

  void toggle(String tableId) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          table.copyWith(isActive: !table.isActive)
        else
          table,
    ];
  }
}

class ReservationsController extends Notifier<List<Reservation>> {
  @override
  List<Reservation> build() => List<Reservation>.from(demoReservations);

  void seat(String reservationId) {
    state = [
      for (final reservation in state)
        if (reservation.id == reservationId)
          reservation.copyWith(status: ReservationStatus.seated)
        else
          reservation,
    ];
  }

  void complete(String reservationId) {
    state = [
      for (final reservation in state)
        if (reservation.id == reservationId)
          reservation.copyWith(status: ReservationStatus.completed)
        else
          reservation,
    ];
  }
}

class InventoryController extends Notifier<List<InventoryItem>> {
  @override
  List<InventoryItem> build() => List<InventoryItem>.from(demoInventory);

  void reorder(String itemId) {
    state = [
      for (final item in state)
        if (item.id == itemId)
          item.copyWith(quantity: item.reorderAt * 2)
        else
          item,
    ];
  }
}

class TenantsController extends Notifier<List<TenantSummary>> {
  @override
  List<TenantSummary> build() => List<TenantSummary>.from(demoTenants);

  void toggleSuspension(String tenantId) {
    state = [
      for (final tenant in state)
        if (tenant.id == tenantId)
          tenant.copyWith(
            status: tenant.status == TenantStatus.suspended
                ? TenantStatus.active
                : TenantStatus.suspended,
          )
        else
          tenant,
    ];
  }
}

class WhiteLabelConfigController extends Notifier<WhiteLabelConfig> {
  @override
  WhiteLabelConfig build() => demoWhiteLabelConfig;

  void toggleCustomerApp() {
    state = state.copyWith(customerAppEnabled: !state.customerAppEnabled);
  }

  void toggleUrdu() {
    state = state.copyWith(urduEnabled: !state.urduEnabled);
  }

  void toggleCrypto() {
    state = state.copyWith(cryptoEnabled: !state.cryptoEnabled);
  }
}

class CryptoPaymentsController extends Notifier<List<CryptoPayment>> {
  @override
  List<CryptoPayment> build() => List<CryptoPayment>.from(demoCryptoPayments);

  void confirm(String paymentId) {
    state = [
      for (final payment in state)
        if (payment.id == paymentId)
          payment.copyWith(status: 'confirmed')
        else
          payment,
    ];
  }
}
