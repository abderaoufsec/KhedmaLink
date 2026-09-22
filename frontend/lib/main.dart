import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localization.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

/// Main entry point for the KhedmaLink Flutter application
///
/// This function initializes the app with proper configuration,
/// routing, theming, and localization support for Arabic and French.
void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app with configured settings
  runApp(const KhedmaLinkApp());
}

/// Root widget of the KhedmaLink application
///
/// Sets up the material app with:
/// - Custom theme configuration
/// - Routing system
/// - Localization support (Arabic RTL, French LTR)
/// - Responsive design
class KhedmaLinkApp extends StatelessWidget {
  const KhedmaLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App title
      title: AppConfig.appName,

      // Debug banner (hidden in production)
      debugShowCheckedModeBanner: AppConfig.showDebugBanner,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router configuration
      routerConfig: AppRouter.router,

      // Localization configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Supported locales
      supportedLocales: const [
        Locale('ar'), // Arabic
        Locale('fr'), // French
      ],

      // Current locale configuration
      locale: const Locale('ar'), // Default to Arabic
    );
  }
}
