import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khedmalink/core/localization/app_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Locale _locale;
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString('locale') ?? 'ar';
    _locale = localeString == 'ar' ? Locale('ar') : Locale('fr');
    setState(() {});
    _localizations = AppLocalizations(_locale);
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    setState(() {});
  }

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'ar' ? Locale('fr') : Locale('ar');
      _saveLocale(_locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_localizations.home),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'ar') {
                _toggleLocale();
              } else if (value == 'fr') {
                _toggleLocale();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(value: 'ar', child: Text('العربية')),
              const PopupMenuItem<String>(value: 'fr', child: Text('Français')),
            ],
          ),
        ],
      ),
      body: Center(
        child: Text(
          _localizations.welcome,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
