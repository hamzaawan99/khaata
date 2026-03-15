import 'package:flutter/material.dart';

class AppConstants {
  // ── Expense Categories ──────────────────────────────────────────────────────
  static const Map<String, IconData> expenseCategories = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_bus,
    'Shopping': Icons.shopping_bag,
    'Health': Icons.local_hospital,
    'Entertainment': Icons.movie,
    'Home': Icons.home,
    'Utilities': Icons.electrical_services,
    'Education': Icons.school,
    'Travel': Icons.flight,
    'Car': Icons.directions_car,
    'Clothing': Icons.checkroom,
    'Personal Care': Icons.spa,
    'Insurance': Icons.security,
    'Taxes': Icons.receipt_long,
    'Gifts': Icons.card_giftcard,
    'Sports': Icons.sports_soccer,
    'Technology': Icons.computer,
    'Communications': Icons.phone,
    'Books': Icons.book,
    'Pet': Icons.pets,
    'Other': Icons.more_horiz,
  };

  // ── Income Categories ───────────────────────────────────────────────────────
  static const Map<String, IconData> incomeCategories = {
    'Salary': Icons.work,
    'Business': Icons.business,
    'Freelance': Icons.laptop,
    'Investment': Icons.trending_up,
    'Deposits': Icons.account_balance,
    'Rental': Icons.home_work,
    'Bonus': Icons.star,
    'Refund': Icons.replay,
    'Gift': Icons.card_giftcard,
    'Carry Over': Icons.swap_horiz,
    'Loan': Icons.account_balance_wallet,
    'Other': Icons.more_horiz,
  };

  // ── Payment Methods ─────────────────────────────────────────────────────────
  static const Map<PaymentMethod, String> paymentMethodLabels = {
    PaymentMethod.cash: 'Cash',
    PaymentMethod.debitCard: 'Debit',
    PaymentMethod.creditCard: 'Credit',
  };

  static const Map<PaymentMethod, IconData> paymentMethodIcons = {
    PaymentMethod.cash: Icons.money,
    PaymentMethod.debitCard: Icons.credit_card,
    PaymentMethod.creditCard: Icons.credit_card,
  };

  // ── Brand Colors (constant across light/dark) ───────────────────────────────
  // Primary — deep teal (sober, professional, finance-appropriate)
  static const Color primaryColor = Color(0xFF0D9488);
  static const Color primaryDark  = Color(0xFF0F766E);

  // Income — emerald green
  static const Color incomeColor = Color(0xFF16A34A);
  static const Color incomeDark  = Color(0xFF15803D);

  // Expense — warm red
  static const Color expenseColor = Color(0xFFE53E3E);
  static const Color expenseDark  = Color(0xFFC53030);

  // ── Chart Colors ─────────────────────────────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF0D9488),
    Color(0xFFE53E3E),
    Color(0xFF16A34A),
    Color(0xFFED8936),
    Color(0xFF805AD5),
    Color(0xFF3182CE),
    Color(0xFFDD6B20),
    Color(0xFF38B2AC),
    Color(0xFF718096),
    Color(0xFFD53F8C),
  ];
}

enum PaymentMethod { cash, debitCard, creditCard }

// ─── AppColors — ThemeExtension for dark/light neutral colors ─────────────────

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color divider;

  const AppColors({
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.divider,
  });

  static const light = AppColors(
    background:    Color(0xFFF2F6F8),
    surface:       Color(0xFFFFFFFF),
    text:          Color(0xFF1A202C),
    textSecondary: Color(0xFF718096),
    divider:       Color(0xFFE8EDF2),
  );

  static const dark = AppColors(
    background:    Color(0xFF0F1117),
    surface:       Color(0xFF1C1F2A),
    text:          Color(0xFFECEEFF),
    textSecondary: Color(0xFF7B82A0),
    divider:       Color(0xFF252836),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? text,
    Color? textSecondary,
    Color? divider,
  }) => AppColors(
    background:    background    ?? this.background,
    surface:       surface       ?? this.surface,
    text:          text          ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
    divider:       divider       ?? this.divider,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background:    Color.lerp(background,    other.background,    t)!,
      surface:       Color.lerp(surface,       other.surface,       t)!,
      text:          Color.lerp(text,          other.text,          t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider:       Color.lerp(divider,       other.divider,       t)!,
    );
  }
}
