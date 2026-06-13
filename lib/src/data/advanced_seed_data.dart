import 'package:restaurant_os_ai/src/domain/advanced_models.dart';

const demoAiRecommendations = [
  AiRecommendation(
    id: 'rec-combo',
    title: 'Push Loaded Duo Combo',
    reason: 'Combo buyers have 31% higher basket value after 7 PM.',
    confidence: 0.89,
    action: 'Create dinner offer',
  ),
  AiRecommendation(
    id: 'rec-shake',
    title: 'Upsell Thick Shake',
    reason: 'Shake attach rate rises when shown after spicy items.',
    confidence: 0.78,
    action: 'Pin as checkout add-on',
  ),
  AiRecommendation(
    id: 'rec-fries',
    title: 'Restock fries early',
    reason: 'Fries stock may run low before the evening rush.',
    confidence: 0.84,
    action: 'Prepare reorder',
  ),
];

const demoAdvancedInsights = [
  AdvancedInsight(
    id: 'insight-peak',
    title: 'Peak window',
    body:
        'Order volume spikes between 7 PM and 9 PM with slower prep on combo tickets.',
    impact: '+12% speed opportunity',
  ),
  AdvancedInsight(
    id: 'insight-retention',
    title: 'Retention',
    body:
        '142 one-order customers are likely to respond to a limited comeback offer.',
    impact: 'Win-back audience ready',
  ),
  AdvancedInsight(
    id: 'insight-rating',
    title: 'Packaging',
    body:
        'Shake leakage appears in recent reviews; packaging audit is recommended.',
    impact: 'Protect rating',
  ),
];

const demoQrTables = [
  QrTable(
    id: 'table-1',
    label: 'T-01',
    seats: 2,
    isActive: true,
    ordersToday: 9,
  ),
  QrTable(
    id: 'table-2',
    label: 'T-02',
    seats: 4,
    isActive: true,
    ordersToday: 13,
  ),
  QrTable(
    id: 'table-3',
    label: 'T-03',
    seats: 6,
    isActive: false,
    ordersToday: 0,
  ),
  QrTable(
    id: 'table-4',
    label: 'Patio-01',
    seats: 4,
    isActive: true,
    ordersToday: 5,
  ),
];

final demoReservations = [
  Reservation(
    id: 'reservation-1',
    customerName: 'Ali Raza',
    partySize: 4,
    time: DateTime(2026, 6, 9, 19, 30),
    tableLabel: 'T-02',
    status: ReservationStatus.pending,
  ),
  Reservation(
    id: 'reservation-2',
    customerName: 'Mariam Shah',
    partySize: 2,
    time: DateTime(2026, 6, 9, 20, 15),
    tableLabel: 'T-01',
    status: ReservationStatus.seated,
  ),
  Reservation(
    id: 'reservation-3',
    customerName: 'Danish Khan',
    partySize: 6,
    time: DateTime(2026, 6, 10, 18, 45),
    tableLabel: 'T-03',
    status: ReservationStatus.pending,
  ),
];

const demoInventory = [
  InventoryItem(
    id: 'inv-beef',
    name: 'Beef patties',
    unit: 'pcs',
    quantity: 180,
    reorderAt: 90,
  ),
  InventoryItem(
    id: 'inv-fries',
    name: 'Frozen fries',
    unit: 'kg',
    quantity: 32,
    reorderAt: 35,
  ),
  InventoryItem(
    id: 'inv-buns',
    name: 'Brioche buns',
    unit: 'pcs',
    quantity: 58,
    reorderAt: 80,
  ),
  InventoryItem(
    id: 'inv-shake',
    name: 'Shake mix',
    unit: 'liters',
    quantity: 14,
    reorderAt: 30,
  ),
];

const demoTenants = [
  TenantSummary(
    id: 'tenant-demo',
    name: 'Demo Foods',
    plan: 'Growth',
    status: TenantStatus.active,
    branches: 3,
    monthlyRevenue: 1820000,
  ),
  TenantSummary(
    id: 'tenant-biryani',
    name: 'Biryani Central',
    plan: 'Starter',
    status: TenantStatus.trial,
    branches: 1,
    monthlyRevenue: 420000,
  ),
  TenantSummary(
    id: 'tenant-cafe',
    name: 'Cafe North',
    plan: 'Enterprise',
    status: TenantStatus.suspended,
    branches: 8,
    monthlyRevenue: 0,
  ),
];

const demoWhiteLabelConfig = WhiteLabelConfig(
  appName: 'Demo Burger',
  primaryColorHex: '#FF6B35',
  secondaryColorHex: '#F7F3EC',
  logoReady: true,
  customerAppEnabled: true,
  urduEnabled: true,
  cryptoEnabled: false,
);

const demoCryptoPayments = [
  CryptoPayment(
    id: 'crypto-1',
    orderNumber: '1090',
    amountPkr: 3290,
    asset: 'USDT',
    status: 'pending',
  ),
  CryptoPayment(
    id: 'crypto-2',
    orderNumber: '1087',
    amountPkr: 1890,
    asset: 'BTC',
    status: 'confirmed',
  ),
];
