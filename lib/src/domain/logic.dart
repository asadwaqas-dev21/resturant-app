import 'dart:math' as math;

import 'models.dart';

class CartPricing {
  const CartPricing._();

  static CartTotals calculate({
    required CartState cart,
    required RestaurantConfig restaurant,
    required CustomerProfile customer,
    required List<Coupon> coupons,
    DateTime? now,
  }) {
    final subtotal = cart.subtotal;
    final deliveryFee = cart.orderType == OrderType.delivery
        ? restaurant.deliveryFee
        : 0.0;
    final matchingCoupon = coupons
        .where(
          (coupon) =>
              coupon.code.toUpperCase() == cart.couponCode.toUpperCase(),
        )
        .firstOrNull;

    double discount = 0;
    String? couponMessage;
    if (restaurant.couponsEnabled && cart.couponCode.trim().isNotEmpty) {
      if (matchingCoupon == null) {
        couponMessage = 'Coupon not found';
      } else {
        final validation = matchingCoupon.validate(
          subtotal,
          now ?? DateTime.now(),
        );
        discount = validation.discount;
        couponMessage = validation.message;
      }
    }

    final taxableAmount = math.max(0.0, subtotal - discount);
    final tax = taxableAmount * 0.05;
    final loyaltyCap = math.min(500.0, taxableAmount * 0.2);
    final canRedeem =
        restaurant.loyaltyEnabled &&
        cart.useLoyalty &&
        customer.loyaltyPoints >= 50;
    final loyaltyDiscount = canRedeem
        ? math
              .min(customer.loyaltyPoints.toDouble(), loyaltyCap)
              .floorToDouble()
        : 0.0;
    final total = math.max(
      0.0,
      taxableAmount + deliveryFee + tax - loyaltyDiscount,
    );

    return CartTotals(
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      tax: tax,
      loyaltyDiscount: loyaltyDiscount,
      total: total,
      loyaltyPointsRedeemed: loyaltyDiscount.toInt(),
      loyaltyPointsEarned: (total / 10).floor(),
      couponMessage: couponMessage,
    );
  }
}

class MenuFilterEngine {
  const MenuFilterEngine._();

  static List<MenuItem> apply({
    required List<MenuItem> items,
    required MenuFilters filters,
    required RestaurantConfig restaurant,
    required List<Coupon> coupons,
    DateTime? now,
  }) {
    final query = filters.query.trim().toLowerCase();
    final restaurantOpen = restaurant.isOpenAt(now ?? DateTime.now());
    final hasActiveOffer = coupons.any((coupon) => coupon.isActive);

    final filtered = items.where((item) {
      if (query.isNotEmpty) {
        final searchable = '${item.name} ${item.description}'.toLowerCase();
        if (!searchable.contains(query)) return false;
      }
      if (filters.categoryId != null && item.categoryId != filters.categoryId) {
        return false;
      }
      if (filters.isOpenNow && !restaurantOpen) return false;
      if (filters.isHalal && !item.isHalal) return false;
      if (filters.isVegetarian && !item.isVegetarian) return false;
      if (filters.isVegan && !item.isVegan) return false;
      if (filters.isSpicy && !item.isSpicy) return false;
      if (filters.isBestSeller && !item.isBestSeller) return false;
      if (filters.hasOffers && !(item.hasDiscount || hasActiveOffer)) {
        return false;
      }
      if (filters.maxPrice != null && item.price > filters.maxPrice!) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (filters.sortBy) {
        case SortOption.recommended:
          final aScore =
              (a.isFeatured ? 100 : 0) + a.averageRating + a.totalOrders / 100;
          final bScore =
              (b.isFeatured ? 100 : 0) + b.averageRating + b.totalOrders / 100;
          return bScore.compareTo(aScore);
        case SortOption.mostPopular:
          return b.totalOrders.compareTo(a.totalOrders);
        case SortOption.highestRated:
          return b.averageRating.compareTo(a.averageRating);
        case SortOption.fastestDelivery:
          return a.preparationTimeMin.compareTo(b.preparationTimeMin);
        case SortOption.lowestPrice:
          return a.price.compareTo(b.price);
        case SortOption.highestPrice:
          return b.price.compareTo(a.price);
      }
    });

    return filtered;
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
