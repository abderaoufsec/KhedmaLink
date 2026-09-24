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
import '../../features/request/screens/create_request_screen.dart';
import '../../features/request/screens/request_list_screen.dart';
import '../../features/request/screens/request_detail_screen.dart';
import '../../features/quote/screens/quote_list_screen.dart';
import '../../features/quote/screens/quote_creation_screen.dart';
import '../../features/quote/screens/eligible_requests_screen.dart';
import '../../features/booking/screens/booking_list_screen.dart';
import '../../features/booking/screens/booking_detail_screen.dart';
import '../../features/messaging/screens/messaging_screen.dart';
import '../../features/messaging/screens/notifications_screen.dart';
import '../../features/review/screens/review_creation_screen.dart';
import '../../features/review/screens/provider_reviews_screen.dart';
import '../../features/dispute/screens/dispute_creation_screen.dart';
import '../../features/dispute/screens/dispute_list_screen.dart';
import '../../features/payment/screens/payment_list_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_verification_screen.dart';
import '../../features/admin/screens/admin_audit_logs_screen.dart';

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

      // Request list (protected)
      GoRoute(
        path: '/requests',
        name: 'requests',
        builder: (context, state) => const RequestListScreen(),
      ),

      // Create request (protected)
      GoRoute(
        path: '/requests/create',
        name: 'create_request',
        builder: (context, state) => const CreateRequestScreen(),
      ),

      // Request detail (protected)
      GoRoute(
        path: '/requests/:requestId',
        name: 'request_detail',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return RequestDetailScreen(requestId: requestId);
        },
      ),

      // Quote list for a request (protected)
      GoRoute(
        path: '/requests/:requestId/quotes',
        name: 'quote_list',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return QuoteListScreen(requestId: requestId);
        },
      ),

      // Create quote for a request (protected)
      GoRoute(
        path: '/requests/:requestId/quotes/create',
        name: 'quote_creation',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return QuoteCreationScreen(requestId: requestId);
        },
      ),

      // Eligible requests for providers (protected)
      GoRoute(
        path: '/eligible-requests',
        name: 'eligible_requests',
        builder: (context, state) {
          return const EligibleRequestsScreen();
        },
      ),

      // Booking list (protected)
      GoRoute(
        path: '/bookings',
        name: 'booking_list',
        builder: (context, state) {
          return const BookingListScreen();
        },
      ),

      // Booking detail (protected)
      GoRoute(
        path: '/bookings/:bookingId',
        name: 'booking_detail',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingDetailScreen(bookingId: bookingId);
        },
      ),

      // Messaging (protected)
      GoRoute(
        path: '/bookings/:bookingId/messages',
        name: 'messaging',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return MessagingScreen(bookingId: bookingId);
        },
      ),

      // Notifications (protected)
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) {
          return const NotificationsScreen();
        },
      ),

      // Review creation (protected)
      GoRoute(
        path: '/bookings/:bookingId/review',
        name: 'review_creation',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return ReviewCreationScreen(bookingId: bookingId);
        },
      ),

      // Provider reviews (public)
      GoRoute(
        path: '/providers/:providerId/reviews',
        name: 'provider_reviews',
        builder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          return ProviderReviewsScreen(providerId: providerId);
        },
      ),

      // Admin dashboard (protected, admin only)
      GoRoute(
        path: '/admin',
        name: 'admin_dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // Admin users list (protected, admin only)
      GoRoute(
        path: '/admin/users',
        name: 'admin_users',
        builder: (context, state) => const AdminUsersScreen(),
      ),

      // Admin verification queue (protected, admin only)
      GoRoute(
        path: '/admin/verification',
        name: 'admin_verification',
        builder: (context, state) => const AdminVerificationScreen(),
      ),

      // Admin audit logs (protected, admin only)
      GoRoute(
        path: '/admin/audit-logs',
        name: 'admin_audit_logs',
        builder: (context, state) => const AdminAuditLogsScreen(),
      ),

      // Dispute list (protected)
      GoRoute(
        path: '/disputes',
        name: 'dispute_list',
        builder: (context, state) => const DisputeListScreen(),
      ),

      // Dispute creation (protected)
      GoRoute(
        path: '/bookings/:bookingId/dispute',
        name: 'dispute_creation',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return DisputeCreationScreen(bookingId: bookingId);
        },
      ),

      // Payment list (protected)
      GoRoute(
        path: '/payments',
        name: 'payment_list',
        builder: (context, state) => const PaymentListScreen(),
      ),
    ],
  );
}

/// Placeholder screen for routes not yet implemented
///
/// This screen is used for features that are intentionally not yet implemented.
/// Status: NOT IMPLEMENTED - This is a placeholder, not a bug.
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
              'NOT IMPLEMENTED - This feature is not yet available',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
