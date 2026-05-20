import 'package:flutter/material.dart';

import '../../../db/app_db.dart';
import '../../../di/injector.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider() {
    final code = Injector.instance<AppDB>().languageCode;
    _locale = code.isNotEmpty ? Locale(code) : null;
  }

  Locale? _locale;
  Locale? get locale => _locale;

  void setLocale(String languageCode) {
    _locale = Locale(languageCode);
    Injector.instance<AppDB>().languageCode = languageCode;
    notifyListeners();
  }
}
