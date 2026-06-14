import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_os_ai/src/restaurant_os_app.dart';

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

    expect(find.text('Kitchen'), findsOneWidget);
    expect(find.text('Riders'), findsOneWidget);
    expect(find.text('Customers'), findsNothing);

    await tester.tap(find.text('Kitchen'));
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
}
