import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_os_ai/src/ui/screens/app_shell.dart';
import 'package:restaurant_os_ai/src/ui/screens/brandsetup_screen.dart';
import 'package:restaurant_os_ai/src/ui/screens/cart_screen.dart';
import 'package:restaurant_os_ai/src/ui/screens/customer_screen.dart';
import 'package:restaurant_os_ai/src/ui/screens/dashboard_screen.dart';
import 'package:restaurant_os_ai/src/ui/screens/onboarding_screen.dart';
import 'package:restaurant_os_ai/src/ui/screens/orders_screen.dart';
import 'package:restaurant_os_ai/src/ui/screens/signin_screen.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/phase_two_screen.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final uri = state.uri;
      final hasLegacyWorkspacePath = uri.pathSegments.any(
        (segment) => segment == 'phase2',
      );
      final hasLegacyWorkspaceHash = uri.fragment
          .split('/')
          .any((segment) => segment == 'phase2');

      if (hasLegacyWorkspacePath || hasLegacyWorkspaceHash) {
        return '/workspace';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OnboardingScreen()),
      ),
      GoRoute(
        path: '/signin',
        pageBuilder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'customer';
          return NoTransitionPage(child: SignInScreen(initialRole: role));
        },
      ),
      GoRoute(
        path: '/brand-setup',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: BrandSetupScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CustomerScreen()),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: OrdersScreen()),
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/workspace',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PhaseTwoScreen()),
          ),
          GoRoute(path: '/phase2', redirect: (context, state) => '/workspace'),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CartScreen()),
          ),
        ],
      ),
    ],
  );
});

class RestaurantOsApp extends ConsumerWidget {
  const RestaurantOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: restaurant.appName,
      theme: buildAppTheme(
        primaryColorHex: restaurant.primaryColorHex,
        secondaryColorHex: restaurant.secondaryColorHex,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
