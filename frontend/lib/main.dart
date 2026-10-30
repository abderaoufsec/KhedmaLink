import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localization.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

/// Main entry point for the KhedmaLink Flutter application
///
/// This function initializes the app with proper configuration,
/// routing, theming, and localization support for Arabic and French.
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Read saved locale from shared preferences (default to Arabic)
  final prefs = await SharedPreferences.getInstance();
  final localeString = prefs.getString('locale') ?? 'ar';
  final savedLocale = localeString == 'ar'
      ? const Locale('ar')
      : const Locale('fr');

  // Run the app with configured settings
  runApp(KhedmaLinkApp(locale: savedLocale));
}

/// Root widget of the KhedmaLink application
///
/// Sets up the material app with:
/// - Custom theme configuration
/// - Routing system
/// - Localization support (Arabic RTL, French LTR)
/// - Responsive design
class KhedmaLinkApp extends StatelessWidget {
  final Locale locale;

  const KhedmaLinkApp({super.key, required this.locale});

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
      locale: locale,
    );
  }
}
