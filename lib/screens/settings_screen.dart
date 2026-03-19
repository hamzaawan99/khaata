// Copyright (c) 2024-2026 Hamza Awan. All rights reserved.
// Licensed under AGPL-3.0. See LICENSE for details.
// Commercial use requires a separate license. See COMMERCIAL.md.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_constants.dart';

/// Call this to slide up the settings sheet.
void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<SettingsProvider>(),
      child: const _SettingsSheet(),
    ),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final c        = Theme.of(context).extension<AppColors>()!;
    final settings = context.watch<SettingsProvider>();
    final bottom   = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle pill
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: c.text,
            ),
          ),
          const SizedBox(height: 28),

          // ── Appearance ─────────────────────────────────────────────────────
          _SectionLabel('APPEARANCE', c),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: ThemeMode.values.map((mode) {
                final label = {
                  ThemeMode.system: 'System',
                  ThemeMode.light:  'Light',
                  ThemeMode.dark:   'Dark',
                }[mode]!;
                final icon = {
                  ThemeMode.system: Icons.brightness_auto_rounded,
                  ThemeMode.light:  Icons.light_mode_rounded,
                  ThemeMode.dark:   Icons.dark_mode_rounded,
                }[mode]!;
                final isSelected = settings.themeMode == mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => settings.setThemeMode(mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppConstants.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            icon,
                            color: isSelected ? Colors.white : c.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : c.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 28),

          // ── Currency ───────────────────────────────────────────────────────
          _SectionLabel('CURRENCY', c),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kCurrencies.map((entry) {
              final isSelected = settings.currencySymbol == entry.symbol;
              return GestureDetector(
                onTap: () {
                  settings.setCurrencySymbol(entry.symbol);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppConstants.primaryColor
                        : c.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppConstants.primaryColor
                          : c.divider,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.symbol,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : c.text,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.code,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final AppColors c;
  const _SectionLabel(this.label, this.c);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: c.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _CurrencyEntry {
  final String symbol;
  final String code;
  const _CurrencyEntry(this.symbol, this.code);
}

const _kCurrencies = [
  _CurrencyEntry(r'$',  'USD'),
  _CurrencyEntry('€',   'EUR'),
  _CurrencyEntry('£',   'GBP'),
  _CurrencyEntry('₹',   'INR'),
  _CurrencyEntry('¥',   'JPY'),
  _CurrencyEntry('Rs',  'PKR'),
  _CurrencyEntry('د.إ', 'AED'),
  _CurrencyEntry('﷼',   'SAR'),
  _CurrencyEntry('C\$', 'CAD'),
  _CurrencyEntry('A\$', 'AUD'),
  _CurrencyEntry('Fr',  'CHF'),
  _CurrencyEntry('kr',  'SEK'),
];
