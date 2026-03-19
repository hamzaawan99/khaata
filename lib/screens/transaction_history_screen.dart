import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_constants.dart';
import '../models/transaction.dart';
import '../widgets/transaction_list.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  // null = All, TransactionType.income, TransactionType.expense
  TransactionType? _filter;

  @override
  Widget build(BuildContext context) {
    final c        = Theme.of(context).extension<AppColors>()!;
    final settings = context.watch<SettingsProvider>();
    final provider = context.watch<TransactionProvider>();

    final all = List<Transaction>.from(provider.currentMonthTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final monthLabel = DateFormat('MMMM yyyy').format(provider.selectedDate);

    final filtered = _filter == null
        ? all
        : all.where((t) => t.type == _filter).toList();

    final totalIncome = all
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final totalExpenses = all
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppConstants.primaryColor, AppConstants.primaryDark],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '· $monthLabel',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatPill(
                              label: '$monthLabel Income',
                              value: settings.format(totalIncome),
                              color: AppConstants.incomeColor,
                              icon: Icons.arrow_upward_rounded,
                            ),
                          ),
                          Container(
                              width: 1,
                              height: 36,
                              color: Colors.white.withValues(alpha: 0.2)),
                          Expanded(
                            child: _StatPill(
                              label: '$monthLabel Expenses',
                              value: settings.format(totalExpenses),
                              color: const Color(0xFFFC8181),
                              icon: Icons.arrow_downward_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Curved bottom edge
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: c.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Filter pills ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  count: all.length,
                  selected: _filter == null,
                  color: AppConstants.primaryColor,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Income',
                  count: all
                      .where((t) => t.type == TransactionType.income)
                      .length,
                  selected: _filter == TransactionType.income,
                  color: AppConstants.incomeColor,
                  onTap: () => setState(() => _filter = TransactionType.income),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Expense',
                  count: all
                      .where((t) => t.type == TransactionType.expense)
                      .length,
                  selected: _filter == TransactionType.expense,
                  color: AppConstants.expenseColor,
                  onTap: () =>
                      setState(() => _filter = TransactionType.expense),
                ),
              ],
            ),
          ),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            size: 52,
                            color: c.divider),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                              color: c.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: TransactionList(transactions: filtered),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatPill(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 13),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.count,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : c.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : c.textSecondary,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : c.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : c.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
