// Copyright (c) 2024-2026 Hamza Awan. All rights reserved.
// Licensed under AGPL-3.0. See LICENSE for details.
// Commercial use requires a separate license. See COMMERCIAL.md.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/premium_provider.dart';
import '../constants/app_constants.dart';

/// Call this to slide up the settings sheet.
void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: context.read<SettingsProvider>()),
        ChangeNotifierProvider.value(value: context.read<PremiumProvider>()),
      ],
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

          const SizedBox(height: 28),

          // ── Premium ────────────────────────────────────────────────────────
          _SectionLabel('PREMIUM', c),
          const SizedBox(height: 10),
          Consumer<PremiumProvider>(
            builder: (context, premium, _) {
              if (premium.isPremium) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppConstants.incomeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppConstants.incomeColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConstants.incomeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.workspace_premium_rounded,
                            color: AppConstants.incomeColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Premium Active',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: c.text)),
                            const SizedBox(height: 2),
                            Text('Ads removed — thank you!',
                                style: TextStyle(
                                    fontSize: 12, color: c.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded,
                          color: AppConstants.incomeColor, size: 22),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  GestureDetector(
                    onTap: premium.isLoading ? null : () => premium.purchaseRemoveAds(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppConstants.primaryColor, AppConstants.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.block_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Remove Ads',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('One-time purchase — enjoy ad-free forever',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          if (premium.isLoading)
                            const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.chevron_right_rounded,
                                color: Colors.white, size: 22),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: premium.isLoading ? null : () => premium.restorePurchases(),
                    child: Text(
                      'Restore Purchases',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
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
