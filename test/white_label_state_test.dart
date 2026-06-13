import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_os_ai/src/data/seed_data.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';

void main() {
  test('client preset switch updates active brand and clears cart', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(cartProvider.notifier).add(demoMenu.first);
    expect(container.read(cartProvider).isEmpty, isFalse);

    container.read(restaurantProvider.notifier).activatePreset('cafe-north');

    final restaurant = container.read(restaurantProvider);
    expect(restaurant.restaurantName, 'Cafe North');
    expect(restaurant.aiEnabled, isTrue);
    expect(container.read(cartProvider).isEmpty, isTrue);
  });

  test('feature toggles reconcile checkout-only cart state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final cart = container.read(cartProvider.notifier);
    cart.setPaymentMethod(PaymentMethod.wallet);
    cart.applyCoupon('WELCOME20');
    cart.toggleLoyalty();

    final restaurant = container.read(restaurantProvider.notifier);
    restaurant.toggleWallet();
    restaurant.toggleCoupons();
    restaurant.toggleLoyalty();

    final nextCart = container.read(cartProvider);
    expect(nextCart.paymentMethod, PaymentMethod.card);
    expect(nextCart.couponCode, isEmpty);
    expect(nextCart.useLoyalty, isFalse);
  });

  test('fulfillment toggles keep at least one order type available', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final restaurant = container.read(restaurantProvider.notifier);
    restaurant.toggleDelivery();
    restaurant.togglePickup();
    restaurant.toggleDineIn();

    final active = container.read(restaurantProvider);
    expect(active.availableOrderTypes, [OrderType.dineIn]);
    expect(container.read(cartProvider).orderType, OrderType.dineIn);
  });
}
