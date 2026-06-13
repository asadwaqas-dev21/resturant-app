import '../domain/phase_two_models.dart';

final demoRiders = [
  const RiderProfile(
    id: 'rider-hamza',
    name: 'Hamza R.',
    phone: '+92 300 111 2233',
    availability: RiderAvailability.online,
    completedToday: 9,
    rating: 4.8,
    currentLatitude: 24.9281,
    currentLongitude: 67.0970,
  ),
  const RiderProfile(
    id: 'rider-sara',
    name: 'Sara M.',
    phone: '+92 300 444 1188',
    availability: RiderAvailability.busy,
    completedToday: 7,
    rating: 4.9,
    currentLatitude: 24.9210,
    currentLongitude: 67.1031,
  ),
  const RiderProfile(
    id: 'rider-bilal',
    name: 'Bilal A.',
    phone: '+92 301 882 4400',
    availability: RiderAvailability.offline,
    completedToday: 3,
    rating: 4.6,
    currentLatitude: 24.9340,
    currentLongitude: 67.0924,
  ),
];

const demoDeliveries = [
  DeliveryTask(
    id: 'delivery-1086',
    orderNumber: '1086',
    pickupBranch: 'Demo Burger - Gulshan',
    dropoffAddress: 'Block 7, Gulshan-e-Iqbal',
    distanceKm: 2.4,
    status: DeliveryStatus.pending,
    etaMinutes: 23,
  ),
  DeliveryTask(
    id: 'delivery-1085',
    orderNumber: '1085',
    pickupBranch: 'Demo Burger - Gulshan',
    dropoffAddress: 'Federal B Area, Karachi',
    distanceKm: 4.8,
    status: DeliveryStatus.accepted,
    etaMinutes: 31,
    riderId: 'rider-hamza',
  ),
  DeliveryTask(
    id: 'delivery-1083',
    orderNumber: '1083',
    pickupBranch: 'Demo Burger - Gulshan',
    dropoffAddress: 'PECHS Block 2',
    distanceKm: 8.1,
    status: DeliveryStatus.delivered,
    etaMinutes: 0,
    riderId: 'rider-sara',
  ),
];

const demoBranches = [
  BranchSummary(
    id: 'branch-gulshan',
    name: 'Demo Burger - Gulshan',
    city: 'Karachi',
    isOpen: true,
    deliveryEnabled: true,
    pickupEnabled: true,
    dineInEnabled: true,
    ordersToday: 42,
    revenueToday: 68350,
    avgPrepMinutes: 14,
  ),
  BranchSummary(
    id: 'branch-clifton',
    name: 'Demo Burger - Clifton',
    city: 'Karachi',
    isOpen: true,
    deliveryEnabled: true,
    pickupEnabled: true,
    dineInEnabled: false,
    ordersToday: 31,
    revenueToday: 51980,
    avgPrepMinutes: 16,
  ),
  BranchSummary(
    id: 'branch-lahore',
    name: 'Demo Burger - Gulberg',
    city: 'Lahore',
    isOpen: false,
    deliveryEnabled: false,
    pickupEnabled: true,
    dineInEnabled: true,
    ordersToday: 18,
    revenueToday: 30740,
    avgPrepMinutes: 19,
  ),
];

const demoCrmCustomers = [
  CrmCustomer(
    id: 'crm-ayesha',
    name: 'Ayesha Khan',
    segment: 'VIP',
    orders: 8,
    totalSpent: 9860,
    loyaltyPoints: 0,
    lastOrderDaysAgo: 1,
    walletBalance: 0,
  ),
  CrmCustomer(
    id: 'crm-omar',
    name: 'Omar Siddiqui',
    segment: 'At risk',
    orders: 1,
    totalSpent: 1199,
    loyaltyPoints: 40,
    lastOrderDaysAgo: 29,
    walletBalance: 0,
  ),
  CrmCustomer(
    id: 'crm-hina',
    name: 'Hina Ahmed',
    segment: 'Loyal',
    orders: 14,
    totalSpent: 18240,
    loyaltyPoints: 510,
    lastOrderDaysAgo: 4,
    walletBalance: 650,
  ),
  CrmCustomer(
    id: 'crm-zain',
    name: 'Zain Malik',
    segment: 'New',
    orders: 2,
    totalSpent: 1880,
    loyaltyPoints: 92,
    lastOrderDaysAgo: 6,
    walletBalance: 250,
  ),
];

final demoCampaigns = [
  MarketingCampaign(
    id: 'campaign-winback',
    title: 'Win back single-order customers',
    message: 'Come back for WELCOME20 on your next combo.',
    audience: 'At risk',
    status: CampaignStatus.draft,
    recipients: 142,
    opens: 0,
  ),
  MarketingCampaign(
    id: 'campaign-lunch',
    title: 'Lunch rush combo',
    message: 'Loaded Duo Combo is 150 off until 3 PM.',
    audience: 'Lunch buyers',
    status: CampaignStatus.scheduled,
    recipients: 318,
    opens: 0,
    scheduledAt: DateTime(2026, 6, 9, 11),
  ),
  MarketingCampaign(
    id: 'campaign-loyalty',
    title: 'Double points weekend',
    message: 'VIP customers earn double loyalty points this weekend.',
    audience: 'VIP',
    status: CampaignStatus.sent,
    recipients: 76,
    opens: 39,
    sentAt: DateTime(2026, 6, 8, 18),
  ),
];

final demoReviews = [
  Review(
    id: 'review-1',
    customerName: 'Hina Ahmed',
    rating: 5,
    comment: 'The spicy zinger stack arrived hot and the rider was fast.',
    itemName: 'Spicy Zinger Stack',
    createdAt: DateTime(2026, 6, 9, 13, 12),
  ),
  Review(
    id: 'review-2',
    customerName: 'Omar Siddiqui',
    rating: 3,
    comment: 'Fries were great, but the shake packaging leaked a little.',
    itemName: 'Thick Shake',
    createdAt: DateTime(2026, 6, 8, 20, 40),
  ),
  Review(
    id: 'review-3',
    customerName: 'Zain Malik',
    rating: 4,
    comment: 'Good value combo. Please add extra sauce options.',
    itemName: 'Loaded Duo Combo',
    createdAt: DateTime(2026, 6, 8, 17, 5),
    response: 'Thanks, Zain. Extra sauce add-ons are coming soon.',
  ),
];

final demoWalletLedger = [
  WalletLedgerEntry(
    id: 'wallet-1',
    type: 'top_up',
    amount: 1000,
    createdAt: DateTime(2026, 6, 8, 12),
    note: 'Stripe card top-up',
  ),
  WalletLedgerEntry(
    id: 'wallet-2',
    type: 'order_payment',
    amount: -1411,
    createdAt: DateTime(2026, 6, 8, 18),
    note: 'Order #1083',
  ),
  WalletLedgerEntry(
    id: 'wallet-3',
    type: 'refund',
    amount: 250,
    createdAt: DateTime(2026, 6, 7, 21),
    note: 'Partial refund',
  ),
];

const demoReferralProgram = ReferralProgram(
  code: 'AYESHA240',
  rewardAmount: 150,
  invitesSent: 18,
  conversions: 5,
);
