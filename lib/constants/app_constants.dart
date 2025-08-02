import 'package:flutter/material.dart';

class AppConstants {
  // Expense Categories
  static const Map<String, IconData> expenseCategories = {
    'Home': Icons.home,
    'House': Icons.home,
    'Pet': Icons.pets,
    'Car': Icons.directions_car,
    'Transport': Icons.directions_bus,
    'Health': Icons.local_hospital,
    'Food': Icons.restaurant,
    'Eating out': Icons.restaurant,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Education': Icons.school,
    'Utilities': Icons.electrical_services,
    'Insurance': Icons.security,
    'Taxes': Icons.receipt_long,
    'Gifts': Icons.card_giftcard,
    'Travel': Icons.flight,
    'Personal Care': Icons.spa,
    'Sports': Icons.sports_soccer,
    'Books': Icons.book,
    'Technology': Icons.computer,
    'Clothing': Icons.checkroom,
    'Communications': Icons.phone,
    'Toiletry': Icons.face,
    'Other': Icons.more_horiz,
  };

  // Income Categories
  static const Map<String, IconData> incomeCategories = {
    'Salary': Icons.work,
    'Deposits': Icons.account_balance,
    'Loan': Icons.account_balance_wallet,
    'Carry Over': Icons.swap_horiz,
    'Investment': Icons.trending_up,
    'Freelance': Icons.laptop,
    'Bonus': Icons.star,
    'Refund': Icons.replay,
    'Gift': Icons.card_giftcard,
    'Rental': Icons.home_work,
    'Business': Icons.business,
    'Other': Icons.more_horiz,
  };

  // Payment Methods
  static const Map<PaymentMethod, String> paymentMethodLabels = {
    PaymentMethod.cash: 'Cash',
    PaymentMethod.debitCard: 'Debit Card',
    PaymentMethod.creditCard: 'Credit Card',
  };

  static const Map<PaymentMethod, IconData> paymentMethodIcons = {
    PaymentMethod.cash: Icons.money,
    PaymentMethod.debitCard: Icons.credit_card,
    PaymentMethod.creditCard: Icons.credit_card,
  };

  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color expenseColor = Color(0xFFE57373);
  static const Color incomeColor = Color(0xFF81C784);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2196F3),
    Color(0xFFE57373),
    Color(0xFF81C784),
    Color(0xFFFFB74D),
    Color(0xFFBA68C8),
    Color(0xFF4DD0E1),
    Color(0xFFFF8A65),
    Color(0xFFA1887F),
    Color(0xFF90A4AE),
    Color(0xFF4FC3F7),
  ];
}

enum PaymentMethod { cash, debitCard, creditCard } 