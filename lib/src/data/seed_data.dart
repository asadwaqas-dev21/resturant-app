import '../domain/models.dart';

Map<int, DayHours> _openingHours({
  int weekdayOpenHour = 9,
  int weekdayCloseHour = 23,
  int weekendOpenHour = 10,
  int weekendCloseHour = 23,
}) {
  DayHours weekday() {
    return DayHours(
      openHour: weekdayOpenHour,
      openMinute: 0,
      closeHour: weekdayCloseHour,
      closeMinute: 59,
    );
  }

  DayHours weekend() {
    return DayHours(
      openHour: weekendOpenHour,
      openMinute: 0,
      closeHour: weekendCloseHour,
      closeMinute: 30,
    );
  }

  return {
    DateTime.monday: weekday(),
    DateTime.tuesday: weekday(),
    DateTime.wednesday: weekday(),
    DateTime.thursday: weekday(),
    DateTime.friday: weekday(),
    DateTime.saturday: weekend(),
    DateTime.sunday: weekend(),
  };
}

final demoRestaurant = RestaurantConfig(
  tenantId: 'demo-foods',
  restaurantId: 'demo-burger',
  branchId: 'demo-burger-gulshan',
  appName: 'Kurchu Restaurant',
  restaurantName: 'Demo Burger',
  branchName: 'Demo Burger - Gulshan',
  cuisine: 'Burgers, fast food',
  logoInitials: 'DB',
  primaryColorHex: '#FF6B35',
  secondaryColorHex: '#F7F3EC',
  currency: 'AED',
  timezone: 'Asia/Karachi',
  city: 'Karachi',
  rating: 4.8,
  deliveryRadiusKm: 10,
  deliveryFee: 99,
  estimatedDeliveryMin: 25,
  estimatedDeliveryMax: 40,
  minimumOrder: 500,
  bannerUrl:
      'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=1600&q=80',
  isDineInAvailable: true,
  openingHours: {
    DateTime.monday: DayHours(
      openHour: 9,
      openMinute: 0,
      closeHour: 23,
      closeMinute: 59,
    ),
    DateTime.tuesday: DayHours(
      openHour: 9,
      openMinute: 0,
      closeHour: 23,
      closeMinute: 59,
    ),
    DateTime.wednesday: DayHours(
      openHour: 9,
      openMinute: 0,
      closeHour: 23,
      closeMinute: 59,
    ),
    DateTime.thursday: DayHours(
      openHour: 9,
      openMinute: 0,
      closeHour: 23,
      closeMinute: 59,
    ),
    DateTime.friday: DayHours(
      openHour: 9,
      openMinute: 0,
      closeHour: 0,
      closeMinute: 30,
    ),
    DateTime.saturday: DayHours(
      openHour: 10,
      openMinute: 0,
      closeHour: 0,
      closeMinute: 30,
    ),
    DateTime.sunday: DayHours(
      openHour: 10,
      openMinute: 0,
      closeHour: 23,
      closeMinute: 0,
    ),
  },
);

final biryaniCentralRestaurant = RestaurantConfig(
  tenantId: 'tenant-biryani',
  restaurantId: 'biryani-central',
  branchId: 'biryani-central-saddar',
  appName: 'Biryani Central',
  restaurantName: 'Biryani Central',
  branchName: 'Biryani Central - Saddar',
  cuisine: 'Biryani, Pakistani',
  logoInitials: 'BC',
  primaryColorHex: '#9D2F2F',
  secondaryColorHex: '#FFF1E7',
  currency: 'AED',
  timezone: 'Asia/Karachi',
  city: 'Karachi',
  rating: 4.6,
  deliveryRadiusKm: 8,
  deliveryFee: 129,
  estimatedDeliveryMin: 30,
  estimatedDeliveryMax: 48,
  minimumOrder: 650,
  bannerUrl:
      'https://images.unsplash.com/photo-1701579231305-d84d8af9a3fd?auto=format&fit=crop&w=1600&q=80',
  isDineInAvailable: false,
  loyaltyEnabled: false,
  walletEnabled: false,
  campaignsEnabled: false,
  openingHours: _openingHours(weekdayOpenHour: 11, weekdayCloseHour: 23),
);

final cafeNorthRestaurant = RestaurantConfig(
  tenantId: 'tenant-cafe',
  restaurantId: 'cafe-north',
  branchId: 'cafe-north-blue-area',
  appName: 'Cafe North',
  restaurantName: 'Cafe North',
  branchName: 'Cafe North - Blue Area',
  cuisine: 'Coffee, bakery, brunch',
  logoInitials: 'CN',
  primaryColorHex: '#176B63',
  secondaryColorHex: '#EAF6F3',
  currency: 'AED',
  timezone: 'Asia/Karachi',
  city: 'Islamabad',
  rating: 4.9,
  deliveryRadiusKm: 6,
  deliveryFee: 149,
  estimatedDeliveryMin: 20,
  estimatedDeliveryMax: 32,
  minimumOrder: 400,
  bannerUrl:
      'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1600&q=80',
  isDineInAvailable: true,
  aiEnabled: true,
  qrOrderingEnabled: true,
  reservationsEnabled: true,
  cryptoEnabled: true,
  urduEnabled: true,
  openingHours: _openingHours(
    weekdayOpenHour: 7,
    weekdayCloseHour: 22,
    weekendOpenHour: 8,
    weekendCloseHour: 23,
  ),
);

final demoRestaurantPresets = [
  demoRestaurant,
  biryaniCentralRestaurant,
  cafeNorthRestaurant,
];

const demoCategories = [
  Category(id: 'burgers', name: 'Burgers', sortOrder: 1),
  Category(id: 'drinks', name: 'Drinks', sortOrder: 2),
  Category(id: 'sides', name: 'Sides', sortOrder: 3),
  Category(id: 'combos', name: 'Combos', sortOrder: 4),
];

const demoMenu = [
  MenuItem(
    id: 'classic-smash',
    categoryId: 'burgers',
    name: 'Classic Smash Burger',
    description:
        'Smashed beef patty, cheddar, house sauce, pickles, seeded bun.',
    basePrice: 599,
    discountedPrice: 549,
    preparationTimeMin: 12,
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80',
    totalOrders: 284,
    averageRating: 4.9,
    isFeatured: true,
    isBestSeller: true,
    calories: 640,
  ),
  MenuItem(
    id: 'double-cheese',
    categoryId: 'burgers',
    name: 'Double Cheese Burger',
    description: 'Two patties, double cheddar, caramelized onion, smoky mayo.',
    basePrice: 749,
    preparationTimeMin: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=900&q=80',
    totalOrders: 192,
    averageRating: 4.7,
    isHalal: true,
    calories: 790,
  ),
  MenuItem(
    id: 'spicy-zinger',
    categoryId: 'burgers',
    name: 'Spicy Zinger Stack',
    description:
        'Crispy chicken, jalapeno relish, lettuce, chili garlic glaze.',
    basePrice: 699,
    preparationTimeMin: 14,
    imageUrl:
        'https://images.unsplash.com/photo-1615297928064-24977384d0da?auto=format&fit=crop&w=900&q=80',
    totalOrders: 241,
    averageRating: 4.8,
    isBestSeller: true,
    isSpicy: true,
    spiceLevel: 3,
    calories: 720,
  ),
  MenuItem(
    id: 'garden-crunch',
    categoryId: 'burgers',
    name: 'Garden Crunch Burger',
    description: 'Crispy vegetable patty, herbed yogurt, tomato, fresh greens.',
    basePrice: 529,
    preparationTimeMin: 11,
    imageUrl:
        'https://images.unsplash.com/photo-1520072959219-c595dc870360?auto=format&fit=crop&w=900&q=80',
    totalOrders: 76,
    averageRating: 4.5,
    isVegetarian: true,
    isNew: true,
    calories: 510,
  ),
  MenuItem(
    id: 'loaded-combo',
    categoryId: 'combos',
    name: 'Loaded Duo Combo',
    description: 'Two smash burgers, large fries, onion rings, and two drinks.',
    basePrice: 1599,
    discountedPrice: 1399,
    preparationTimeMin: 18,
    imageUrl:
        'https://images.unsplash.com/photo-1610614819513-58e34989848b?auto=format&fit=crop&w=900&q=80',
    totalOrders: 118,
    averageRating: 4.6,
    isFeatured: true,
  ),
  MenuItem(
    id: 'crispy-fries',
    categoryId: 'sides',
    name: 'Crispy Fries',
    description: 'Skin-on fries tossed with sea salt and parsley.',
    basePrice: 199,
    preparationTimeMin: 8,
    imageUrl:
        'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?auto=format&fit=crop&w=900&q=80',
    totalOrders: 331,
    averageRating: 4.8,
    isBestSeller: true,
    isVegetarian: true,
    calories: 330,
  ),
  MenuItem(
    id: 'onion-rings',
    categoryId: 'sides',
    name: 'Onion Rings',
    description: 'Golden rings with smoked paprika dip.',
    basePrice: 249,
    preparationTimeMin: 10,
    imageUrl:
        'https://images.unsplash.com/photo-1639024471283-03518883512d?auto=format&fit=crop&w=900&q=80',
    totalOrders: 121,
    averageRating: 4.4,
    isVegetarian: true,
    calories: 370,
  ),
  MenuItem(
    id: 'thick-shake',
    categoryId: 'drinks',
    name: 'Thick Shake',
    description: 'Vanilla bean shake with caramel drizzle.',
    basePrice: 299,
    preparationTimeMin: 5,
    imageUrl:
        'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=900&q=80',
    totalOrders: 166,
    averageRating: 4.6,
    isVegetarian: true,
    calories: 420,
  ),
];

final demoCoupons = [
  Coupon(
    code: 'WELCOME20',
    discountType: DiscountType.percentage,
    discountValue: 20,
    minOrderAmount: 500,
    maxDiscountAmount: 500,
    validUntil: DateTime(2026, 7, 8),
  ),
  Coupon(
    code: 'COMBO150',
    discountType: DiscountType.fixed,
    discountValue: 150,
    minOrderAmount: 1200,
    maxDiscountAmount: 150,
    validUntil: DateTime(2026, 7, 8),
  ),
];

const demoCustomer = CustomerProfile(
  userId: 'demo-customer',
  fullName: 'Ayesha Khan',
  loyaltyPoints: 240,
  walletBalance: 1800,
  totalOrders: 8,
  totalSpent: 9860,
);
