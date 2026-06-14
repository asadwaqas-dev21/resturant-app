import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';

enum SortOption {
  recommended,
  mostPopular,
  highestRated,
  fastestDelivery,
  lowestPrice,
  highestPrice,
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
}

enum OrderType { delivery, pickup, dineIn }

enum PaymentMethod { card, cash, wallet, applePay, googlePay }

enum DiscountType { percentage, fixed }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.recommended:
        return 'Recommended';
      case SortOption.mostPopular:
        return 'Popular';
      case SortOption.highestRated:
        return 'Highest rated';
      case SortOption.fastestDelivery:
        return 'Fastest';
      case SortOption.lowestPrice:
        return 'Lowest price';
      case SortOption.highestPrice:
        return 'Highest price';
    }
  }
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.outForDelivery:
        return 'Out for delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get actionLabel {
    switch (this) {
      case OrderStatus.pending:
        return 'Confirm';
      case OrderStatus.confirmed:
        return 'Start cooking';
      case OrderStatus.preparing:
        return 'Mark ready';
      case OrderStatus.ready:
        return 'Dispatch';
      case OrderStatus.outForDelivery:
        return 'Deliver';
      case OrderStatus.delivered:
        return 'Complete';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  OrderStatus? get next {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.ready;
      case OrderStatus.ready:
        return OrderStatus.outForDelivery;
      case OrderStatus.outForDelivery:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }
}

extension OrderTypeLabel on OrderType {
  String get label {
    switch (this) {
      case OrderType.delivery:
        return 'Delivery';
      case OrderType.pickup:
        return 'Pickup';
      case OrderType.dineIn:
        return 'Dine in';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderType.delivery:
        return Iconsax.truck_fast;
      case OrderType.pickup:
        return Iconsax.shop;
      case OrderType.dineIn:
        return Iconsax.reserve;
    }
  }
}

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.card:
        return Iconsax.card;
      case PaymentMethod.cash:
        return Iconsax.receipt_text;
      case PaymentMethod.wallet:
        return Iconsax.wallet;
      case PaymentMethod.applePay:
      case PaymentMethod.googlePay:
        return Iconsax.card_tick;
    }
  }
}

class RestaurantConfig {
  const RestaurantConfig({
    required this.tenantId,
    required this.restaurantId,
    required this.branchId,
    required this.appName,
    required this.restaurantName,
    required this.branchName,
    required this.cuisine,
    required this.logoInitials,
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.currency,
    required this.timezone,
    required this.city,
    required this.rating,
    required this.deliveryRadiusKm,
    required this.deliveryFee,
    required this.estimatedDeliveryMin,
    required this.estimatedDeliveryMax,
    required this.minimumOrder,
    required this.openingHours,
    required this.bannerUrl,
    this.isDeliveryAvailable = true,
    this.isPickupAvailable = true,
    this.isDineInAvailable = false,
    this.loyaltyEnabled = true,
    this.couponsEnabled = true,
    this.walletEnabled = true,
    this.customerAppEnabled = true,
    this.urduEnabled = false,
    this.campaignsEnabled = true,
    this.aiEnabled = false,
    this.qrOrderingEnabled = false,
    this.reservationsEnabled = false,
    this.cryptoEnabled = false,
  });

  final String tenantId;
  final String restaurantId;
  final String branchId;
  final String appName;
  final String restaurantName;
  final String branchName;
  final String cuisine;
  final String logoInitials;
  final String primaryColorHex;
  final String secondaryColorHex;
  final String currency;
  final String timezone;
  final String city;
  final double rating;
  final double deliveryRadiusKm;
  final double deliveryFee;
  final int estimatedDeliveryMin;
  final int estimatedDeliveryMax;
  final double minimumOrder;
  final Map<int, DayHours> openingHours;
  final String bannerUrl;
  final bool isDeliveryAvailable;
  final bool isPickupAvailable;
  final bool isDineInAvailable;
  final bool loyaltyEnabled;
  final bool couponsEnabled;
  final bool walletEnabled;
  final bool customerAppEnabled;
  final bool urduEnabled;
  final bool campaignsEnabled;
  final bool aiEnabled;
  final bool qrOrderingEnabled;
  final bool reservationsEnabled;
  final bool cryptoEnabled;

  bool isOrderTypeAvailable(OrderType type) {
    switch (type) {
      case OrderType.delivery:
        return isDeliveryAvailable;
      case OrderType.pickup:
        return isPickupAvailable;
      case OrderType.dineIn:
        return isDineInAvailable;
    }
  }

  List<OrderType> get availableOrderTypes {
    return [
      if (isDeliveryAvailable) OrderType.delivery,
      if (isPickupAvailable) OrderType.pickup,
      if (isDineInAvailable) OrderType.dineIn,
    ];
  }

  bool isPaymentMethodAvailable(PaymentMethod method) {
    if (method == PaymentMethod.wallet) return walletEnabled;
    return true;
  }

  List<PaymentMethod> get availablePaymentMethods {
    return [
      PaymentMethod.card,
      PaymentMethod.cash,
      if (walletEnabled) PaymentMethod.wallet,
      PaymentMethod.applePay,
      PaymentMethod.googlePay,
    ];
  }

  RestaurantConfig copyWith({
    String? appName,
    String? restaurantName,
    String? branchName,
    String? cuisine,
    String? logoInitials,
    String? primaryColorHex,
    String? secondaryColorHex,
    String? currency,
    String? timezone,
    String? city,
    double? rating,
    double? deliveryRadiusKm,
    double? deliveryFee,
    int? estimatedDeliveryMin,
    int? estimatedDeliveryMax,
    double? minimumOrder,
    String? bannerUrl,
    bool? isDeliveryAvailable,
    bool? isPickupAvailable,
    bool? isDineInAvailable,
    bool? loyaltyEnabled,
    bool? couponsEnabled,
    bool? walletEnabled,
    bool? customerAppEnabled,
    bool? urduEnabled,
    bool? campaignsEnabled,
    bool? aiEnabled,
    bool? qrOrderingEnabled,
    bool? reservationsEnabled,
    bool? cryptoEnabled,
  }) {
    return RestaurantConfig(
      tenantId: tenantId,
      restaurantId: restaurantId,
      branchId: branchId,
      appName: appName ?? this.appName,
      restaurantName: restaurantName ?? this.restaurantName,
      branchName: branchName ?? this.branchName,
      cuisine: cuisine ?? this.cuisine,
      logoInitials: logoInitials ?? this.logoInitials,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      estimatedDeliveryMin: estimatedDeliveryMin ?? this.estimatedDeliveryMin,
      estimatedDeliveryMax: estimatedDeliveryMax ?? this.estimatedDeliveryMax,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      openingHours: openingHours,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isDeliveryAvailable: isDeliveryAvailable ?? this.isDeliveryAvailable,
      isPickupAvailable: isPickupAvailable ?? this.isPickupAvailable,
      isDineInAvailable: isDineInAvailable ?? this.isDineInAvailable,
      loyaltyEnabled: loyaltyEnabled ?? this.loyaltyEnabled,
      couponsEnabled: couponsEnabled ?? this.couponsEnabled,
      walletEnabled: walletEnabled ?? this.walletEnabled,
      customerAppEnabled: customerAppEnabled ?? this.customerAppEnabled,
      urduEnabled: urduEnabled ?? this.urduEnabled,
      campaignsEnabled: campaignsEnabled ?? this.campaignsEnabled,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      qrOrderingEnabled: qrOrderingEnabled ?? this.qrOrderingEnabled,
      reservationsEnabled: reservationsEnabled ?? this.reservationsEnabled,
      cryptoEnabled: cryptoEnabled ?? this.cryptoEnabled,
    );
  }

  bool isOpenAt(DateTime dateTime) {
    final hours = openingHours[dateTime.weekday];
    if (hours == null || hours.isClosed) return false;
    final minutesNow = dateTime.hour * 60 + dateTime.minute;
    final open = hours.openHour * 60 + hours.openMinute;
    final close = hours.closeHour * 60 + hours.closeMinute;
    if (close < open) {
      return minutesNow >= open || minutesNow <= close;
    }
    return minutesNow >= open && minutesNow <= close;
  }
}

class DayHours {
  const DayHours({
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
    this.isClosed = false,
  });

  final int openHour;
  final int openMinute;
  final int closeHour;
  final int closeMinute;
  final bool isClosed;

  String get label {
    if (isClosed) return 'Closed';
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(openHour)}:${two(openMinute)}-${two(closeHour)}:${two(closeMinute)}';
  }
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final int sortOrder;
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.preparationTimeMin,
    required this.imageUrl,
    required this.totalOrders,
    required this.averageRating,
    this.discountedPrice,
    this.isAvailable = true,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.isNew = false,
    this.isHalal = true,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isSpicy = false,
    this.spiceLevel = 0,
    this.isGlutenFree = false,
    this.isDairyFree = false,
    this.calories,
  });

  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double basePrice;
  final double? discountedPrice;
  final int preparationTimeMin;
  final String imageUrl;
  final int totalOrders;
  final double averageRating;
  final bool isAvailable;
  final bool isFeatured;
  final bool isBestSeller;
  final bool isNew;
  final bool isHalal;
  final bool isVegetarian;
  final bool isVegan;
  final bool isSpicy;
  final int spiceLevel;
  final bool isGlutenFree;
  final bool isDairyFree;
  final int? calories;

  double get price => discountedPrice ?? basePrice;
  bool get hasDiscount =>
      discountedPrice != null && discountedPrice! < basePrice;

  MenuItem copyWith({bool? isAvailable}) {
    return MenuItem(
      id: id,
      categoryId: categoryId,
      name: name,
      description: description,
      basePrice: basePrice,
      discountedPrice: discountedPrice,
      preparationTimeMin: preparationTimeMin,
      imageUrl: imageUrl,
      totalOrders: totalOrders,
      averageRating: averageRating,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured,
      isBestSeller: isBestSeller,
      isNew: isNew,
      isHalal: isHalal,
      isVegetarian: isVegetarian,
      isVegan: isVegan,
      isSpicy: isSpicy,
      spiceLevel: spiceLevel,
      isGlutenFree: isGlutenFree,
      isDairyFree: isDairyFree,
      calories: calories,
    );
  }
}

class Coupon {
  const Coupon({
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.maxDiscountAmount,
    required this.validUntil,
    this.isActive = true,
    this.maxUses = 100,
    this.currentUses = 0,
  });

  final String code;
  final DiscountType discountType;
  final double discountValue;
  final double minOrderAmount;
  final double maxDiscountAmount;
  final DateTime validUntil;
  final bool isActive;
  final int maxUses;
  final int currentUses;

  CouponValidation validate(double subtotal, DateTime now) {
    if (!isActive) return const CouponValidation.invalid('Coupon is inactive');
    if (now.isAfter(validUntil)) {
      return const CouponValidation.invalid('Coupon expired');
    }
    if (currentUses >= maxUses) {
      return const CouponValidation.invalid('Coupon use limit reached');
    }
    if (subtotal < minOrderAmount) {
      return CouponValidation.invalid(
        'Minimum order is PKR ${minOrderAmount.toStringAsFixed(0)}',
      );
    }
    final rawDiscount = discountType == DiscountType.percentage
        ? subtotal * discountValue / 100
        : discountValue;
    final discount = math.min(rawDiscount, maxDiscountAmount);
    return CouponValidation.valid(math.min(discount, subtotal));
  }
}

class CouponValidation {
  const CouponValidation.valid(this.discount) : message = null, isValid = true;
  const CouponValidation.invalid(this.message) : discount = 0, isValid = false;

  final bool isValid;
  final double discount;
  final String? message;
}

class CartLine {
  const CartLine({required this.item, required this.quantity});

  final MenuItem item;
  final int quantity;

  double get lineTotal => item.price * quantity;

  CartLine copyWith({int? quantity, MenuItem? item}) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  const CartState({
    this.lines = const {},
    this.couponCode = '',
    this.orderType = OrderType.delivery,
    this.paymentMethod = PaymentMethod.card,
    this.useLoyalty = false,
    this.notes = '',
  });

  final Map<String, CartLine> lines;
  final String couponCode;
  final OrderType orderType;
  final PaymentMethod paymentMethod;
  final bool useLoyalty;
  final String notes;

  int get itemCount => lines.values.fold(0, (sum, line) => sum + line.quantity);
  double get subtotal =>
      lines.values.fold(0, (sum, line) => sum + line.lineTotal);
  bool get isEmpty => lines.isEmpty;

  CartState copyWith({
    Map<String, CartLine>? lines,
    String? couponCode,
    OrderType? orderType,
    PaymentMethod? paymentMethod,
    bool? useLoyalty,
    String? notes,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      couponCode: couponCode ?? this.couponCode,
      orderType: orderType ?? this.orderType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      useLoyalty: useLoyalty ?? this.useLoyalty,
      notes: notes ?? this.notes,
    );
  }
}

class CartTotals {
  const CartTotals({
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.tax,
    required this.loyaltyDiscount,
    required this.total,
    required this.loyaltyPointsRedeemed,
    required this.loyaltyPointsEarned,
    this.couponMessage,
  });

  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double tax;
  final double loyaltyDiscount;
  final double total;
  final int loyaltyPointsRedeemed;
  final int loyaltyPointsEarned;
  final String? couponMessage;

  bool get hasCouponIssue => couponMessage != null;
}

class CustomerProfile {
  const CustomerProfile({
    required this.userId,
    required this.fullName,
    required this.loyaltyPoints,
    required this.walletBalance,
    required this.totalOrders,
    required this.totalSpent,
  });

  final String userId;
  final String fullName;
  final int loyaltyPoints;
  final double walletBalance;
  final int totalOrders;
  final double totalSpent;

  CustomerProfile copyWith({
    int? loyaltyPoints,
    double? walletBalance,
    int? totalOrders,
    double? totalSpent,
  }) {
    return CustomerProfile(
      userId: userId,
      fullName: fullName,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      walletBalance: walletBalance ?? this.walletBalance,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    required this.orderType,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.estimatedReadyAt,
    this.riderName,
    this.specialInstructions = '',
    this.customerId = '',
  });

  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final OrderStatus status;
  final OrderType orderType;
  final PaymentMethod paymentMethod;
  final String paymentStatus;
  final List<CartLine> lines;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double tax;
  final double total;
  final DateTime estimatedReadyAt;
  final String? riderName;
  final String specialInstructions;
  final String customerId;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  Order copyWith({
    OrderStatus? status,
    String? paymentStatus,
    String? riderName,
    String? customerId,
  }) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      createdAt: createdAt,
      status: status ?? this.status,
      orderType: orderType,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      lines: lines,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      tax: tax,
      total: total,
      estimatedReadyAt: estimatedReadyAt,
      riderName: riderName ?? this.riderName,
      specialInstructions: specialInstructions,
      customerId: customerId ?? this.customerId,
    );
  }
}

class MenuFilters {
  const MenuFilters({
    this.query = '',
    this.categoryId,
    this.isOpenNow = false,
    this.isHalal = false,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isSpicy = false,
    this.isBestSeller = false,
    this.hasOffers = false,
    this.maxPrice,
    this.sortBy = SortOption.recommended,
  });

  final String query;
  final String? categoryId;
  final bool isOpenNow;
  final bool isHalal;
  final bool isVegetarian;
  final bool isVegan;
  final bool isSpicy;
  final bool isBestSeller;
  final bool hasOffers;
  final double? maxPrice;
  final SortOption sortBy;

  MenuFilters copyWith({
    String? query,
    Object? categoryId = _unset,
    bool? isOpenNow,
    bool? isHalal,
    bool? isVegetarian,
    bool? isVegan,
    bool? isSpicy,
    bool? isBestSeller,
    bool? hasOffers,
    Object? maxPrice = _unset,
    SortOption? sortBy,
  }) {
    return MenuFilters(
      query: query ?? this.query,
      categoryId: categoryId == _unset
          ? this.categoryId
          : categoryId as String?,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      isHalal: isHalal ?? this.isHalal,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isSpicy: isSpicy ?? this.isSpicy,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      hasOffers: hasOffers ?? this.hasOffers,
      maxPrice: maxPrice == _unset ? this.maxPrice : maxPrice as double?,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

const Object _unset = Object();
