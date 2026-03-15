import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_constants.dart';
import 'edit_transaction_screen.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 48, color: c.divider),
            const SizedBox(height: 12),
            Text('No transactions yet',
                style: TextStyle(color: c.textSecondary, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Tap + Add to record one',
                style: TextStyle(color: c.textSecondary, fontSize: 12)),
          ],
        ),
      );
    }

    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final grouped = <DateTime, List<Transaction>>{};
    for (final t in sorted) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      grouped.putIfAbsent(day, () => []).add(t);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateHeader(date: day),
            ...grouped[day]!
                .map((t) => _TransactionTile(transaction: t))
                .toList(),
          ],
        );
      },
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  String _label() {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d         = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        _label(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: c.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final c         = Theme.of(context).extension<AppColors>()!;
    final settings  = context.watch<SettingsProvider>();
    final isIncome  = transaction.type == TransactionType.income;
    final typeColor = isIncome ? AppConstants.incomeColor : AppConstants.expenseColor;
    final icon = isIncome
        ? AppConstants.incomeCategories[transaction.category] ?? Icons.more_horiz
        : AppConstants.expenseCategories[transaction.category] ?? Icons.more_horiz;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.42,
          children: [
            SlidableAction(
              onPressed: (_) => _edit(context),
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
            SlidableAction(
              onPressed: (_) => _delete(context),
              backgroundColor: AppConstants.expenseColor,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _edit(context),
          child: Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border(left: BorderSide(color: typeColor, width: 3.5)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: typeColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transaction.category,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: c.text)),
                        if (transaction.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(transaction.description,
                              style: TextStyle(
                                  fontSize: 12, color: c.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              AppConstants.paymentMethodIcons[
                                  transaction.paymentMethod],
                              size: 12,
                              color: c.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              AppConstants.paymentMethodLabels[
                                      transaction.paymentMethod] ??
                                  '',
                              style: TextStyle(
                                  fontSize: 11, color: c.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}${settings.format(transaction.amount)}',
                    style: TextStyle(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _edit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              EditTransactionScreen(transaction: transaction)),
    );
  }

  void _delete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
            'Delete this ${transaction.type == TransactionType.income ? 'income' : 'expense'} transaction?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<TransactionProvider>()
                  .deleteTransaction(transaction.id!);
            },
            style: TextButton.styleFrom(
                foregroundColor: AppConstants.expenseColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
