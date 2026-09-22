import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/provider/screens/categories_list_screen.dart';
import '../../features/provider/screens/providers_list_screen.dart';
import '../../features/provider/screens/provider_detail_screen.dart';
import '../../features/provider/screens/provider_profile_management_screen.dart';

/// Application router configuration
///
/// Uses GoRouter for type-safe navigation and deep linking.
/// Defines all app routes and their corresponding screens.
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  /// Root navigator key for the app
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  /// Shell navigator key for nested navigation
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();

  /// GoRouter configuration
  static final GoRouter router = GoRouter(
    // Navigator keys
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: AppConfig.enableDebugLogging,

    // Redirect unauthenticated users to login
    redirect: (context, state) async {
      final authService = AuthService();
      final isAuthenticated = await authService.isAuthenticated();

      // Public routes that don't require authentication
      final publicRoutes = ['/login', '/register'];

      if (!isAuthenticated && !publicRoutes.contains(state.uri.toString())) {
        return '/login';
      }

      // Redirect authenticated users away from login/register
      if (isAuthenticated && publicRoutes.contains(state.uri.toString())) {
        return '/home';
      }

      return null;
    },

    // Error builder for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Route: ${state.uri}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),

    // Route configuration
    routes: [
      // Authentication routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Home route (protected)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen('Home'),
      ),

      // Onboarding route (protected)
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const _PlaceholderScreen('Onboarding'),
      ),

      // Categories list (protected)
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesListScreen(),
      ),

      // Providers list (protected)
      GoRoute(
        path: '/providers',
        name: 'providers',
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['category_id'];
          final city = state.uri.queryParameters['city'];
          final wilaya = state.uri.queryParameters['wilaya'];
          return ProvidersListScreen(
            categoryId: categoryId,
            city: city,
            wilaya: wilaya,
          );
        },
      ),

      // Provider detail (protected)
      GoRoute(
        path: '/providers/:providerId',
        name: 'provider_detail',
        builder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          return ProviderDetailScreen(providerId: providerId);
        },
      ),

      // Provider profile management (protected)
      GoRoute(
        path: '/provider/profile',
        name: 'provider_profile',
        builder: (context, state) => const ProviderProfileManagementScreen(),
      ),
    ],
  );
}

/// Placeholder screen for routes not yet implemented
///
/// This will be replaced with actual screens as features are implemented
/// in subsequent milestones.
class _PlaceholderScreen extends StatelessWidget {
  final String routeName;

  const _PlaceholderScreen(this.routeName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(routeName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '$routeName Screen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'This screen will be implemented in a future milestone',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
