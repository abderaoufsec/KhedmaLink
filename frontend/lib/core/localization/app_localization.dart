import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Application localization delegate
///
/// Provides localization support for Arabic (RTL) and French (LTR)
/// using Flutter's built-in localization system.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Helper method to access localization from context
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('ar'), // Arabic
    Locale('fr'), // French
  ];

  /// Localization delegate
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // =============================================================================
  // APP STRINGS - ARABIC
  // =============================================================================

  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // App
      'appName': 'خدمة لينك',
      'appTitle': 'خدمة لينك - سوق الخدمات المحلية الموثوقة',

      // Common
      'loading': 'جاري التحميل...',
      'error': 'حدث خطأ',
      'success': 'نجح',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'close': 'إغلاق',
      'search': 'بحث',
      'filter': 'تصفية',
      'sort': 'ترتيب',
      'refresh': 'تحديث',
      'next': 'التالي',
      'previous': 'السابق',
      'submit': 'إرسال',
      'back': 'رجوع',
      'skip': 'تخطي',
      'done': 'تم',

      // Navigation
      'home': 'الرئيسية',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'notifications': 'الإشعارات',
      'messages': 'الرسائل',
      'bookings': 'الحجوزات',
      'requests': 'الطلبات',
      'providers': 'مقدمي الخدمات',
      'categories': 'الفئات',

      // Auth
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'noAccount': 'ليس لديك حساب؟',
      'haveAccount': 'لديك حساب بالفعل؟',

      // Errors
      'errorGeneric': 'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
      'errorNetwork': 'خطأ في الشبكة. يرجى التحقق من اتصالك.',
      'errorTimeout': 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.',
      'errorUnauthorized': 'وصول غير مصرح به. يرجى تسجيل الدخول.',
      'errorNotFound': 'المورد غير موجود.',
      'errorValidation': 'إدخال غير صالح. يرجى التحقق من بياناتك.',
      'errorServer': 'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.',

      // Empty states
      'noData': 'لا توجد بيانات',
      'noResults': 'لا توجد نتائج',
      'noItems': 'لا توجد عناصر',
      'tryAgain': 'حاول مرة أخرى',

      // Welcome
      'welcome': 'مرحباً',
      'welcomeBack': 'مرحباً بعودتك',

      // Placeholder
      'notImplemented': 'هذه الميزة لم يتم تنفيذها بعد',
    },
    'fr': {
      // App
      'appName': 'KhedmaLink',
      'appTitle': 'KhedmaLink - Marché de services locaux de confiance',

      // Common
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'close': 'Fermer',
      'search': 'Rechercher',
      'filter': 'Filtrer',
      'sort': 'Trier',
      'refresh': 'Actualiser',
      'next': 'Suivant',
      'previous': 'Précédent',
      'submit': 'Soumettre',
      'back': 'Retour',
      'skip': 'Passer',
      'done': 'Terminé',

      // Navigation
      'home': 'Accueil',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'notifications': 'Notifications',
      'messages': 'Messages',
      'bookings': 'Réservations',
      'requests': 'Demandes',
      'providers': 'Prestataires',
      'categories': 'Catégories',

      // Auth
      'login': 'Connexion',
      'register': 'Inscription',
      'logout': 'Déconnexion',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'confirmPassword': 'Confirmer le mot de passe',
      'forgotPassword': 'Mot de passe oublié ?',
      'noAccount': 'Pas de compte ?',
      'haveAccount': 'Vous avez déjà un compte ?',

      // Errors
      'errorGeneric': 'Une erreur s\'est produite. Veuillez réessayer.',
      'errorNetwork': 'Erreur réseau. Vérifiez votre connexion.',
      'errorTimeout': 'Délai d\'attente dépassé. Veuillez réessayer.',
      'errorUnauthorized': 'Accès non autorisé. Veuillez vous connecter.',
      'errorNotFound': 'Ressource introuvable.',
      'errorValidation': 'Entrée invalide. Vérifiez vos données.',
      'errorServer': 'Erreur serveur. Veuillez réessayer plus tard.',

      // Empty states
      'noData': 'Aucune donnée',
      'noResults': 'Aucun résultat',
      'noItems': 'Aucun élément',
      'tryAgain': 'Réessayer',

      // Welcome
      'welcome': 'Bienvenue',
      'welcomeBack': 'Bon retour',

      // Placeholder
      'notImplemented': 'Cette fonctionnalité n\'est pas encore implémentée',
    },
  };

  // =============================================================================
  // GETTER METHODS
  // =============================================================================

  String get appName => _localizedValues[locale.languageCode]!['appName']!;
  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;

  // Common
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get filter => _localizedValues[locale.languageCode]!['filter']!;
  String get sort => _localizedValues[locale.languageCode]!['sort']!;
  String get refresh => _localizedValues[locale.languageCode]!['refresh']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get previous => _localizedValues[locale.languageCode]!['previous']!;
  String get submit => _localizedValues[locale.languageCode]!['submit']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  String get skip => _localizedValues[locale.languageCode]!['skip']!;
  String get done => _localizedValues[locale.languageCode]!['done']!;

  // Navigation
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get notifications =>
      _localizedValues[locale.languageCode]!['notifications']!;
  String get messages => _localizedValues[locale.languageCode]!['messages']!;
  String get bookings => _localizedValues[locale.languageCode]!['bookings']!;
  String get requests => _localizedValues[locale.languageCode]!['requests']!;
  String get providers => _localizedValues[locale.languageCode]!['providers']!;
  String get categories =>
      _localizedValues[locale.languageCode]!['categories']!;

  // Auth
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get confirmPassword =>
      _localizedValues[locale.languageCode]!['confirmPassword']!;
  String get forgotPassword =>
      _localizedValues[locale.languageCode]!['forgotPassword']!;
  String get noAccount => _localizedValues[locale.languageCode]!['noAccount']!;
  String get haveAccount =>
      _localizedValues[locale.languageCode]!['haveAccount']!;

  // Errors
  String get errorGeneric =>
      _localizedValues[locale.languageCode]!['errorGeneric']!;
  String get errorNetwork =>
      _localizedValues[locale.languageCode]!['errorNetwork']!;
  String get errorTimeout =>
      _localizedValues[locale.languageCode]!['errorTimeout']!;
  String get errorUnauthorized =>
      _localizedValues[locale.languageCode]!['errorUnauthorized']!;
  String get errorNotFound =>
      _localizedValues[locale.languageCode]!['errorNotFound']!;
  String get errorValidation =>
      _localizedValues[locale.languageCode]!['errorValidation']!;
  String get errorServer =>
      _localizedValues[locale.languageCode]!['errorServer']!;

  // Empty states
  String get noData => _localizedValues[locale.languageCode]!['noData']!;
  String get noResults => _localizedValues[locale.languageCode]!['noResults']!;
  String get noItems => _localizedValues[locale.languageCode]!['noItems']!;
  String get tryAgain => _localizedValues[locale.languageCode]!['tryAgain']!;

  // Welcome
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get welcomeBack =>
      _localizedValues[locale.languageCode]!['welcomeBack']!;

  // Placeholder
  String get notImplemented =>
      _localizedValues[locale.languageCode]!['notImplemented']!;

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Format date according to locale
  String formatDate(DateTime date) {
    return DateFormat.yMMMd(locale.languageCode).format(date);
  }

  /// Format time according to locale
  String formatTime(DateTime time) {
    return DateFormat.jm(locale.languageCode).format(time);
  }

  /// Format date and time according to locale
  String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd(locale.languageCode).add_jm().format(dateTime);
  }

  /// Format number according to locale
  String formatNumber(num number) {
    return NumberFormat.decimalPattern(locale.languageCode).format(number);
  }

  /// Format currency according to locale
  String formatCurrency(double amount, {String currencyCode = 'DZD'}) {
    return NumberFormat.currency(
      locale: locale.languageCode,
      symbol: currencyCode,
    ).format(amount);
  }
}

/// Localization delegate for AppLocalizations
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((supportedLocale) => supportedLocale.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Initialize intl for the locale (removed in newer intl versions)
    // await Intl.initialize(locale.languageCode);

    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
