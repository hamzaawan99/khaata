// Copyright (c) 2024-2026 Hamza Awan. All rights reserved.
// Licensed under AGPL-3.0. See LICENSE for details.
// Commercial use requires a separate license. See COMMERCIAL.md.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType initialType;
  final bool showTypeToggle;
  const AddTransactionScreen({
    super.key,
    this.initialType = TransactionType.expense,
    this.showTypeToggle = true,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController      = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryScrollCtrl    = ScrollController();

  late TransactionType _selectedType;
  String          _selectedCategory      = '';
  PaymentMethod   _selectedPaymentMethod = PaymentMethod.cash;
  DateTime        _selectedDate          = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _updateDefaultCategory();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _categoryScrollCtrl.dispose();
    super.dispose();
  }

  void _updateDefaultCategory() {
    final cats = _selectedType == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;
    _selectedCategory = cats.keys.first;
  }

  Color get _typeColor => _selectedType == TransactionType.expense
      ? AppConstants.expenseColor
      : AppConstants.incomeColor;

  Color get _typeDark => _selectedType == TransactionType.expense
      ? AppConstants.expenseDark
      : AppConstants.incomeDark;

  @override
  Widget build(BuildContext context) {
    final c        = Theme.of(context).extension<AppColors>()!;
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: c.background,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          _buildHeader(c, settings),
          _buildCategoryGrid(c),
          Expanded(child: _buildDetailsCard(c)),
          _buildBottomBar(c),
        ],
      ),
    );
  }

  // ── Gradient header ─────────────────────────────────────────────────────────

  Widget _buildHeader(AppColors c, SettingsProvider settings) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_typeColor, _typeDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    widget.showTypeToggle
                        ? 'New Transaction'
                        : 'Add ${_selectedType == TransactionType.expense ? 'Expense' : 'Income'}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (widget.showTypeToggle)
                    TypeToggle(
                      selected: _selectedType,
                      activeColor: _typeColor,
                      onChanged: (t) => setState(() {
                        _selectedType = t;
                        _updateDefaultCategory();
                        _categoryScrollCtrl.animateTo(0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut);
                      }),
                    ),
                ],
              ),
              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    settings.currencySymbol,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 26,
                        fontWeight: FontWeight.w300),
                  ),
                  SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _amountController,
                      autofocus: true,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: false,
                      ),
                      cursorColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3-row horizontal category grid ──────────────────────────────────────────

  Widget _buildCategoryGrid(AppColors c) {
    final categories = _selectedType == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;

    return Container(
      color: c.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Text(
              'CATEGORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: c.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: GridView.builder(
              controller: _categoryScrollCtrl,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories.keys.elementAt(index);
                final icon     = categories[category]!;
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected ? _typeColor : c.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _typeColor : c.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            color: isSelected ? Colors.white : c.textSecondary,
                            size: 20),
                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected ? Colors.white : c.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: c.divider),
        ],
      ),
    );
  }

  // ── Details card ─────────────────────────────────────────────────────────────

  Widget _buildDetailsCard(AppColors c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: TextField(
                controller: _descriptionController,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: c.text, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.edit_note_rounded,
                      color: c.textSecondary),
                  hintText: 'Description (optional)',
                  hintStyle:
                      TextStyle(color: c.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            Divider(height: 1, color: c.divider, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.payments_rounded,
                      color: c.textSecondary, size: 22),
                  const SizedBox(width: 12),
                  Text('Payment',
                      style:
                          TextStyle(color: c.textSecondary, fontSize: 14)),
                  const Spacer(),
                  PaymentPills(
                    selected: _selectedPaymentMethod,
                    activeColor: _typeColor,
                    onChanged: (m) =>
                        setState(() => _selectedPaymentMethod = m),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.divider, indent: 16, endIndent: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        color: c.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Text('Date',
                        style: TextStyle(
                            color: c.textSecondary, fontSize: 14)),
                    const Spacer(),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: c.text,
                          fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        color: c.textSecondary, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pinned save button ────────────────────────────────────────────────────

  Widget _buildBottomBar(AppColors c) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final safePad = MediaQuery.of(context).padding.bottom;
    return Container(
      color: c.background,
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom > 0 ? bottom : (safePad > 0 ? safePad : 12)),
      child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_typeColor, _typeDark]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: _typeColor.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _save,
                borderRadius: BorderRadius.circular(16),
                child: const Center(
                  child: Text(
                    'Save Transaction',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _typeColor)),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _save() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid amount'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    context.read<TransactionProvider>().addTransaction(Transaction(
          amount: amount,
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          type: _selectedType,
          paymentMethod: _selectedPaymentMethod,
          date: _selectedDate,
        ));
    Navigator.pop(context);
  }
}

// ─── Shared widgets (exported for EditTransactionScreen) ──────────────────────

class TypeToggle extends StatelessWidget {
  final TransactionType selected;
  final Color activeColor;
  final ValueChanged<TransactionType> onChanged;

  const TypeToggle({
    super.key,
    required this.selected,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(context, TransactionType.expense, 'Expense'),
          _pill(context, TransactionType.income, 'Income'),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, TransactionType type, String label) {
    final isSelected = selected == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.white.withOpacity(0.8),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class PaymentPills extends StatelessWidget {
  final PaymentMethod selected;
  final Color activeColor;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentPills({
    super.key,
    required this.selected,
    required this.activeColor,
    required this.onChanged,
  });

  static const _labels = {
    PaymentMethod.cash:       'Cash',
    PaymentMethod.debitCard:  'Debit',
    PaymentMethod.creditCard: 'Credit',
  };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: PaymentMethod.values.map((method) {
        final isSelected = selected == method;
        return GestureDetector(
          onTap: () => onChanged(method),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : c.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _labels[method]!,
              style: TextStyle(
                color: isSelected ? Colors.white : c.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
