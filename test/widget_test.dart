import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/restaurant_os_app.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

void main() {
  testWidgets('renders the RestaurantOS customer menu', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    expect(find.text('White-label restaurant app'), findsOneWidget);

    await tester.tap(find.text('Order food'));
    await tester.pumpAndSettle();

    expect(find.text('Customer sign in'), findsOneWidget);

    await tester.tap(find.text('Preview customer app'));
    await tester.pumpAndSettle();

    expect(find.text('Demo Burger'), findsAtLeastNWidgets(1));
    expect(find.text('Menu'), findsAtLeastNWidgets(1));
    expect(find.text('Classic Smash Burger'), findsOneWidget);
  });

  testWidgets('opens filters from bottom sheet', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Order food'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview customer app'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Filters'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('Sort'), findsAtLeastNWidgets(1));
    expect(find.text('Apply'), findsOneWidget);
  });

  testWidgets('opens hub modules one at a time', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Staff operations'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview operations'));
    await tester.pumpAndSettle();

    final kitchenModule = find.descendant(
      of: find.byType(Surface),
      matching: find.text('Kitchen'),
    );
    expect(kitchenModule, findsOneWidget);
    expect(find.text('Riders'), findsOneWidget);
    expect(find.text('Customers'), findsNothing);

    await tester.tap(kitchenModule);
    await tester.pumpAndSettle();

    expect(find.text('Kitchen display'), findsOneWidget);
    expect(find.text('Operations'), findsNothing);
  });

  testWidgets('owner sees all workspace modules', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Staff operations'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Owner'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview operations'));
    await tester.pumpAndSettle();

    expect(find.text('Revenue'), findsOneWidget);

    await tester.tap(find.text('Ops'));
    await tester.pumpAndSettle();

    expect(find.text('Kitchen'), findsOneWidget);
    expect(find.text('Riders'), findsOneWidget);
    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
    expect(find.text('Branches'), findsOneWidget);
    expect(find.text('Intelligence'), findsOneWidget);
  });

  testWidgets('opens restaurant brand setup', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set up restaurant'));
    await tester.pumpAndSettle();

    expect(find.text('Brand setup'), findsOneWidget);
    expect(find.text('Client preset'), findsOneWidget);
    expect(find.text('Launch checklist'), findsOneWidget);
  });

  testWidgets('owner/staff opens menu control from account screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Staff operations'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Owner'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview operations'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.text('Menu control'), findsOneWidget);
    await tester.tap(find.text('Menu control'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byTooltip('Add menu item'), findsOneWidget);
  });

  testWidgets('customer can access chat and send message', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Order food'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview customer app'));
    await tester.pumpAndSettle();

    expect(find.text('Chat'), findsOneWidget);
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Live Support Chat'), findsOneWidget);
    expect(find.text('Online Agents ready'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Hello testing message');
    await tester.tap(find.byIcon(Iconsax.send_1));
    await tester.pumpAndSettle();

    expect(find.text('Hello testing message'), findsOneWidget);
  });

  testWidgets('owner can access chat and send message in channel', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Staff operations'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Owner'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview operations'));
    await tester.pumpAndSettle();

    expect(find.text('Chat'), findsOneWidget);
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Kitchen Display team'), findsAtLeastNWidgets(1));
    expect(find.text('Rider team chat'), findsOneWidget);

    await tester.tap(find.text('Rider team chat'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Calling all riders');
    await tester.tap(find.byIcon(Iconsax.send_1));
    await tester.pumpAndSettle();

    expect(find.text('Calling all riders'), findsOneWidget);
  });

  testWidgets('staff can access chat and send message in channel', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Staff operations'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Staff'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview operations'));
    await tester.pumpAndSettle();

    expect(find.text('Chat'), findsOneWidget);
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Kitchen Display team'), findsAtLeastNWidgets(1));
    expect(find.text('Rider team chat'), findsOneWidget);

    await tester.tap(find.text('Rider team chat'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Staff checking in');
    await tester.tap(find.byIcon(Iconsax.send_1));
    await tester.pumpAndSettle();

    expect(find.text('Staff checking in'), findsOneWidget);
  });

  testWidgets('tapping notification icon opens notifications screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Order food'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview customer app'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Notifications'), findsOneWidget);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsAtLeastNWidgets(1));
    expect(find.text('Special Discount!'), findsOneWidget);

    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();

    await tester.drag(find.text('Special Discount!'), const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    expect(find.text('Special Discount!'), findsNothing);

    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();

    expect(find.text('All caught up!'), findsOneWidget);
  });

  testWidgets('owner on dashboard can tap notification bell icon to open notifications screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Staff operations'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Owner'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview operations'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Notifications'), findsOneWidget);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsAtLeastNWidgets(1));
    expect(find.text('Special Discount!'), findsOneWidget);
  });

  testWidgets('customer checkout redirects to thank you screen and goes back to menu', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantOsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Order food'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview customer app'));
    await tester.pumpAndSettle();

    // Add first menu item
    final addButton = find.text('Add').first;
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Navigate to Cart screen
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    // Find and tap Proceed to Checkout button
    final proceedToCheckoutBtn = find.textContaining('Proceed to Checkout');
    expect(proceedToCheckoutBtn, findsOneWidget);
    await tester.ensureVisible(proceedToCheckoutBtn);
    await tester.tap(proceedToCheckoutBtn);
    await tester.pumpAndSettle();

    // Verify redirected to Checkout screen and tap Place order button
    expect(find.text('Checkout'), findsAtLeastNWidgets(1));
    final placeOrderButton = find.textContaining('Place order');
    expect(placeOrderButton, findsOneWidget);
    await tester.ensureVisible(placeOrderButton);
    await tester.tap(placeOrderButton);
    await tester.pumpAndSettle();

    // Verify redirected to Thank You screen
    expect(find.text('Order Placed Successfully!'), findsOneWidget);
    expect(find.text('Track Order'), findsOneWidget);
    expect(find.text('Back to Menu'), findsOneWidget);

    // Tap Back to Menu
    final backToMenuButton = find.text('Back to Menu');
    await tester.ensureVisible(backToMenuButton);
    await tester.tap(backToMenuButton);
    await tester.pumpAndSettle();

    // Verify returned to the customer menu/booking screen
    expect(find.text('Menu'), findsAtLeastNWidgets(1));
  });
}
