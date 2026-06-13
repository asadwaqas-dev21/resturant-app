import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_os_ai/src/data/seed_data.dart';
import 'package:restaurant_os_ai/src/domain/logic.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';

void main() {
  test('cart totals apply percentage coupon cap', () {
    final cart = CartState(
      lines: {demoMenu[4].id: CartLine(item: demoMenu[4], quantity: 1)},
      couponCode: 'WELCOME20',
    );

    final totals = CartPricing.calculate(
      cart: cart,
      restaurant: demoRestaurant,
      customer: demoCustomer,
      coupons: demoCoupons,
      now: DateTime(2026, 6, 8),
    );

    expect(totals.discount, 279.8);
    expect(totals.couponMessage, isNull);
  });

  test('expired coupon returns validation message', () {
    final coupon = Coupon(
      code: 'OLD',
      discountType: DiscountType.fixed,
      discountValue: 100,
      minOrderAmount: 100,
      maxDiscountAmount: 100,
      validUntil: DateTime(2026, 1, 1),
    );

    final validation = coupon.validate(500, DateTime(2026, 6, 8));

    expect(validation.isValid, isFalse);
    expect(validation.message, 'Coupon expired');
  });

  test('filters combine category and vegetarian constraints', () {
    final filtered = MenuFilterEngine.apply(
      items: demoMenu,
      filters: const MenuFilters(categoryId: 'sides', isVegetarian: true),
      restaurant: demoRestaurant,
      coupons: demoCoupons,
      now: DateTime(2026, 6, 8, 12),
    );

    expect(
      filtered.map((item) => item.name),
      containsAll(['Crispy Fries', 'Onion Rings']),
    );
    expect(filtered.every((item) => item.categoryId == 'sides'), isTrue);
  });

  test('loyalty redemption is capped at twenty percent of taxable amount', () {
    final cart = CartState(
      lines: {demoMenu[0].id: CartLine(item: demoMenu[0], quantity: 1)},
      useLoyalty: true,
    );

    final totals = CartPricing.calculate(
      cart: cart,
      restaurant: demoRestaurant,
      customer: demoCustomer,
      coupons: demoCoupons,
      now: DateTime(2026, 6, 8),
    );

    expect(totals.loyaltyDiscount, 109);
  });
}
