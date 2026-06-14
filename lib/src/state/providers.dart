import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/seed_data.dart';
import '../domain/logic.dart';
import '../domain/models.dart';

final restaurantPresetsProvider = Provider<List<RestaurantConfig>>(
  (ref) => demoRestaurantPresets,
);

final restaurantProvider =
    NotifierProvider<RestaurantController, RestaurantConfig>(
      RestaurantController.new,
    );

final categoriesProvider = Provider<List<Category>>((ref) => demoCategories);
final couponsProvider = Provider<List<Coupon>>((ref) => demoCoupons);

final menuProvider = NotifierProvider<MenuController, List<MenuItem>>(
  MenuController.new,
);

final filtersProvider = NotifierProvider<FilterController, MenuFilters>(
  FilterController.new,
);

final filteredMenuProvider = Provider<List<MenuItem>>((ref) {
  return MenuFilterEngine.apply(
    items: ref.watch(menuProvider),
    filters: ref.watch(filtersProvider),
    restaurant: ref.watch(restaurantProvider),
    coupons: ref.watch(couponsProvider),
  );
});

final cartProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

enum UserRole { customer, owner, staff }

class UserRoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.customer;

  void setRole(UserRole role) {
    state = role;
  }
}

final userRoleProvider = NotifierProvider<UserRoleNotifier, UserRole>(
  UserRoleNotifier.new,
);

final customerProvider = NotifierProvider<CustomerController, CustomerProfile>(
  CustomerController.new,
);

final cartTotalsProvider = Provider<CartTotals>((ref) {
  return CartPricing.calculate(
    cart: ref.watch(cartProvider),
    restaurant: ref.watch(restaurantProvider),
    customer: ref.watch(customerProvider),
    coupons: ref.watch(couponsProvider),
  );
});

final ordersProvider = NotifierProvider<OrdersController, List<Order>>(
  OrdersController.new,
);

class RestaurantController extends Notifier<RestaurantConfig> {
  @override
  RestaurantConfig build() => ref.read(restaurantPresetsProvider).first;

  void activatePreset(String restaurantId) {
    final presets = ref.read(restaurantPresetsProvider);
    RestaurantConfig? next;
    for (final preset in presets) {
      if (preset.restaurantId == restaurantId) {
        next = preset;
        break;
      }
    }
    if (next == null) return;

    state = next;
    ref.read(cartProvider.notifier).clear();
  }

  void applyBrandColors(String primaryHex, String secondaryHex) {
    state = state.copyWith(
      primaryColorHex: primaryHex,
      secondaryColorHex: secondaryHex,
    );
  }

  void toggleDelivery() {
    _applyIfOrderable(
      state.copyWith(isDeliveryAvailable: !state.isDeliveryAvailable),
    );
  }

  void togglePickup() {
    _applyIfOrderable(
      state.copyWith(isPickupAvailable: !state.isPickupAvailable),
    );
  }

  void toggleDineIn() {
    _applyIfOrderable(
      state.copyWith(isDineInAvailable: !state.isDineInAvailable),
    );
  }

  void toggleCustomerApp() {
    state = state.copyWith(customerAppEnabled: !state.customerAppEnabled);
  }

  void toggleCoupons() {
    _applyAndReconcileCart(
      state.copyWith(couponsEnabled: !state.couponsEnabled),
    );
  }

  void toggleLoyalty() {
    _applyAndReconcileCart(
      state.copyWith(loyaltyEnabled: !state.loyaltyEnabled),
    );
  }

  void toggleWallet() {
    _applyAndReconcileCart(state.copyWith(walletEnabled: !state.walletEnabled));
  }

  void toggleUrdu() {
    state = state.copyWith(urduEnabled: !state.urduEnabled);
  }

  void toggleCampaigns() {
    state = state.copyWith(campaignsEnabled: !state.campaignsEnabled);
  }

  void toggleAi() {
    state = state.copyWith(aiEnabled: !state.aiEnabled);
  }

  void toggleQrOrdering() {
    state = state.copyWith(qrOrderingEnabled: !state.qrOrderingEnabled);
  }

  void toggleReservations() {
    state = state.copyWith(reservationsEnabled: !state.reservationsEnabled);
  }

  void toggleCrypto() {
    state = state.copyWith(cryptoEnabled: !state.cryptoEnabled);
  }

  void _applyIfOrderable(RestaurantConfig next) {
    if (next.availableOrderTypes.isEmpty) return;
    _applyAndReconcileCart(next);
  }

  void _applyAndReconcileCart(RestaurantConfig next) {
    state = next;
    ref.read(cartProvider.notifier).ensureConfigAllowed(next);
  }
}

class MenuController extends Notifier<List<MenuItem>> {
  @override
  List<MenuItem> build() => List<MenuItem>.from(demoMenu);

  void toggleAvailability(String itemId) {
    state = [
      for (final item in state)
        if (item.id == itemId)
          item.copyWith(isAvailable: !item.isAvailable)
        else
          item,
    ];
  }

  void addItem(MenuItem item) {
    state = [...state, item];
  }
}

class FilterController extends Notifier<MenuFilters> {
  @override
  MenuFilters build() => const MenuFilters();

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void selectCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void toggleOpenNow() {
    state = state.copyWith(isOpenNow: !state.isOpenNow);
  }

  void toggleHalal() {
    state = state.copyWith(isHalal: !state.isHalal);
  }

  void toggleVegetarian() {
    state = state.copyWith(isVegetarian: !state.isVegetarian);
  }

  void toggleVegan() {
    state = state.copyWith(isVegan: !state.isVegan);
  }

  void toggleSpicy() {
    state = state.copyWith(isSpicy: !state.isSpicy);
  }

  void toggleBestSeller() {
    state = state.copyWith(isBestSeller: !state.isBestSeller);
  }

  void toggleOffers() {
    state = state.copyWith(hasOffers: !state.hasOffers);
  }

  void setMaxPrice(double? value) {
    state = state.copyWith(maxPrice: value);
  }

  void setSort(SortOption option) {
    state = state.copyWith(sortBy: option);
  }

  void reset() {
    state = const MenuFilters();
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void add(MenuItem item) {
    if (!item.isAvailable) return;
    final nextLines = Map<String, CartLine>.from(state.lines);
    final existing = nextLines[item.id];
    nextLines[item.id] = existing == null
        ? CartLine(item: item, quantity: 1)
        : existing.copyWith(quantity: existing.quantity + 1, item: item);
    state = state.copyWith(lines: nextLines);
  }

  void decrement(String itemId) {
    final existing = state.lines[itemId];
    if (existing == null) return;
    final nextLines = Map<String, CartLine>.from(state.lines);
    if (existing.quantity <= 1) {
      nextLines.remove(itemId);
    } else {
      nextLines[itemId] = existing.copyWith(quantity: existing.quantity - 1);
    }
    state = state.copyWith(lines: nextLines);
  }

  void remove(String itemId) {
    final nextLines = Map<String, CartLine>.from(state.lines)..remove(itemId);
    state = state.copyWith(lines: nextLines);
  }

  void applyCoupon(String code) {
    state = state.copyWith(couponCode: code.trim().toUpperCase());
  }

  void setOrderType(OrderType type) {
    state = state.copyWith(orderType: type);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void toggleLoyalty() {
    state = state.copyWith(useLoyalty: !state.useLoyalty);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void clear() {
    state = const CartState();
  }

  void ensureConfigAllowed(RestaurantConfig restaurant) {
    var next = state;
    final orderTypes = restaurant.availableOrderTypes;
    final paymentMethods = restaurant.availablePaymentMethods;

    if (orderTypes.isNotEmpty &&
        !restaurant.isOrderTypeAvailable(next.orderType)) {
      next = next.copyWith(orderType: orderTypes.first);
    }
    if (paymentMethods.isNotEmpty &&
        !restaurant.isPaymentMethodAvailable(next.paymentMethod)) {
      next = next.copyWith(paymentMethod: paymentMethods.first);
    }
    if (!restaurant.loyaltyEnabled && next.useLoyalty) {
      next = next.copyWith(useLoyalty: false);
    }
    if (!restaurant.couponsEnabled && next.couponCode.isNotEmpty) {
      next = next.copyWith(couponCode: '');
    }

    state = next;
  }
}

class CustomerController extends Notifier<CustomerProfile> {
  @override
  CustomerProfile build() => demoCustomer;

  void settleOrder(CartTotals totals, PaymentMethod paymentMethod) {
    final walletCharge = paymentMethod == PaymentMethod.wallet
        ? totals.total
        : 0.0;
    final points = math.max(
      0,
      state.loyaltyPoints -
          totals.loyaltyPointsRedeemed +
          totals.loyaltyPointsEarned,
    );
    state = state.copyWith(
      loyaltyPoints: points,
      walletBalance: math.max(0, state.walletBalance - walletCharge),
      totalOrders: state.totalOrders + 1,
      totalSpent: state.totalSpent + totals.total,
    );
  }

  void topUpWallet(double amount) {
    state = state.copyWith(walletBalance: state.walletBalance + amount);
  }

  void updateProfileName(String fullName) {
    state = CustomerProfile(
      userId: state.userId,
      fullName: fullName,
      loyaltyPoints: state.loyaltyPoints,
      walletBalance: state.walletBalance,
      totalOrders: state.totalOrders,
      totalSpent: state.totalSpent,
    );
  }
}

class OrdersController extends Notifier<List<Order>> {
  int _nextOrderNumber = 1086;

  @override
  List<Order> build() {
    final now = DateTime.now();
    return [
      Order(
        id: 'order-1085',
        orderNumber: '1085',
        createdAt: now.subtract(const Duration(minutes: 8)),
        status: OrderStatus.preparing,
        orderType: OrderType.delivery,
        paymentMethod: PaymentMethod.card,
        paymentStatus: 'paid',
        lines: [
          CartLine(item: demoMenu[0], quantity: 1),
          CartLine(item: demoMenu[5], quantity: 1),
        ],
        subtotal: demoMenu[0].price + demoMenu[5].price,
        discount: 100,
        deliveryFee: demoRestaurant.deliveryFee,
        tax: 32.4,
        total:
            demoMenu[0].price +
            demoMenu[5].price -
            100 +
            demoRestaurant.deliveryFee +
            32.4,
        estimatedReadyAt: now.add(const Duration(minutes: 18)),
        riderName: 'Hamza R.',
        specialInstructions: 'No onions on the burger.',
        customerId: 'demo-customer',
      ),
      Order(
        id: 'order-1084',
        orderNumber: '1084',
        createdAt: now.subtract(const Duration(minutes: 24)),
        status: OrderStatus.ready,
        orderType: OrderType.pickup,
        paymentMethod: PaymentMethod.cash,
        paymentStatus: 'pending',
        lines: [
          CartLine(item: demoMenu[2], quantity: 1),
          CartLine(item: demoMenu[7], quantity: 2),
        ],
        subtotal: demoMenu[2].price + demoMenu[7].price * 2,
        discount: 0,
        deliveryFee: 0,
        tax: 34.9,
        total: demoMenu[2].price + demoMenu[7].price * 2 + 34.9,
        estimatedReadyAt: now.add(const Duration(minutes: 4)),
        customerId: 'other-customer',
      ),
      Order(
        id: 'order-1083',
        orderNumber: '1083',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 10)),
        status: OrderStatus.delivered,
        orderType: OrderType.delivery,
        paymentMethod: PaymentMethod.wallet,
        paymentStatus: 'paid',
        lines: [CartLine(item: demoMenu[4], quantity: 1)],
        subtotal: demoMenu[4].price,
        discount: 150,
        deliveryFee: demoRestaurant.deliveryFee,
        tax: 62.45,
        total: demoMenu[4].price - 150 + demoRestaurant.deliveryFee + 62.45,
        estimatedReadyAt: now.subtract(const Duration(hours: 1, minutes: 30)),
        riderName: 'Sara M.',
        customerId: 'demo-customer',
      ),
    ];
  }

  Order placeOrder(
    CartState cart,
    CartTotals totals,
    RestaurantConfig restaurant,
  ) {
    final now = DateTime.now();
    final orderNumber = (_nextOrderNumber++).toString();
    final paymentStatus = cart.paymentMethod == PaymentMethod.cash
        ? 'pending'
        : 'paid';
    final customer = ref.read(customerProvider);
    final order = Order(
      id: 'order-$orderNumber',
      orderNumber: orderNumber,
      createdAt: now,
      status: OrderStatus.pending,
      orderType: cart.orderType,
      paymentMethod: cart.paymentMethod,
      paymentStatus: paymentStatus,
      lines: cart.lines.values.toList(growable: false),
      subtotal: totals.subtotal,
      discount: totals.discount + totals.loyaltyDiscount,
      deliveryFee: totals.deliveryFee,
      tax: totals.tax,
      total: totals.total,
      estimatedReadyAt: now.add(
        Duration(minutes: restaurant.estimatedDeliveryMax),
      ),
      riderName: cart.orderType == OrderType.delivery ? 'Unassigned' : null,
      specialInstructions: cart.notes,
      customerId: customer.userId,
    );
    state = [order, ...state];
    return order;
  }

  void advance(String orderId) {
    state = [
      for (final order in state)
        if (order.id == orderId && order.status.next != null)
          order.copyWith(
            status: order.status.next,
            paymentStatus: order.status.next == OrderStatus.delivered
                ? 'paid'
                : order.paymentStatus,
            riderName: order.status.next == OrderStatus.outForDelivery
                ? 'Hamza R.'
                : order.riderName,
          )
        else
          order,
    ];
  }

  void cancel(String orderId) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: OrderStatus.cancelled)
        else
          order,
    ];
  }
}
