import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_os_ai/src/domain/advanced_models.dart';
import 'package:restaurant_os_ai/src/state/advanced_providers.dart';

void main() {
  test('reservation and QR table controls update state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(qrTablesProvider.notifier).toggle('table-3');
    expect(
      container
          .read(qrTablesProvider)
          .firstWhere((table) => table.id == 'table-3')
          .isActive,
      isTrue,
    );

    container.read(reservationsProvider.notifier).seat('reservation-1');
    expect(
      container
          .read(reservationsProvider)
          .firstWhere((reservation) => reservation.id == 'reservation-1')
          .status,
      ReservationStatus.seated,
    );
  });

  test('inventory reorder restores low stock', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(inventoryProvider.notifier).reorder('inv-shake');
    final item = container
        .read(inventoryProvider)
        .firstWhere((candidate) => candidate.id == 'inv-shake');

    expect(item.quantity, item.reorderAt * 2);
    expect(item.status, InventoryStatus.healthy);
  });

  test('admin, white-label, and crypto controls update state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(tenantsProvider.notifier).toggleSuspension('tenant-biryani');
    expect(
      container
          .read(tenantsProvider)
          .firstWhere((tenant) => tenant.id == 'tenant-biryani')
          .status,
      TenantStatus.suspended,
    );

    final beforeCrypto = container.read(whiteLabelConfigProvider).cryptoEnabled;
    container.read(whiteLabelConfigProvider.notifier).toggleCrypto();
    expect(
      container.read(whiteLabelConfigProvider).cryptoEnabled,
      !beforeCrypto,
    );

    container.read(cryptoPaymentsProvider.notifier).confirm('crypto-1');
    expect(
      container
          .read(cryptoPaymentsProvider)
          .firstWhere((payment) => payment.id == 'crypto-1')
          .status,
      'confirmed',
    );
  });
}
