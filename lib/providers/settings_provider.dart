// Copyright (c) 2024-2026 Hamza Awan. All rights reserved.
// Licensed under AGPL-3.0. See LICENSE for details.
// Commercial use requires a separate license. See COMMERCIAL.md.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const _keyTheme    = 'theme_mode';
  static const _keyCurrency = 'currency_symbol';

  ThemeMode _themeMode      = ThemeMode.system;
  String    _currencySymbol = r'$';

  ThemeMode get themeMode      => _themeMode;
  String    get currencySymbol => _currencySymbol;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx   = prefs.getInt(_keyTheme) ?? ThemeMode.system.index;
    _themeMode      = ThemeMode.values[idx.clamp(0, ThemeMode.values.length - 1)];
    _currencySymbol = prefs.getString(_keyCurrency) ?? r'$';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
  }

  Future<void> setCurrencySymbol(String symbol) async {
    if (_currencySymbol == symbol) return;
    _currencySymbol = symbol;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, symbol);
  }

  /// Formats [amount] as a currency string, e.g. "$1,234.56" or "-$500.00".
  String format(double amount) {
    final isNeg  = amount < 0;
    final abs    = amount.abs();
    final parts  = abs.toStringAsFixed(2).split('.');
    final intStr = parts[0];
    final buf    = StringBuffer();
    for (int i = 0; i < intStr.length; i++) {
      if (i > 0 && (intStr.length - i) % 3 == 0) buf.write(',');
      buf.write(intStr[i]);
    }
    return '${isNeg ? '-' : ''}$_currencySymbol$buf.${parts[1]}';
  }
}
