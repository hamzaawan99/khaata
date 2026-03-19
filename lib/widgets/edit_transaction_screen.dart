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
import 'add_transaction_screen.dart' show TypeToggle, PaymentPills;

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;
  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  final _categoryScrollCtrl = ScrollController();

  late TransactionType _selectedType;
  late String          _selectedCategory;
  late PaymentMethod   _selectedPaymentMethod;
  late DateTime        _selectedDate;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController      = TextEditingController(text: t.amount.toStringAsFixed(2));
    _descriptionController = TextEditingController(text: t.description);
    _selectedType          = t.type;
    _selectedCategory      = t.category;
    _selectedPaymentMethod = t.paymentMethod;
    _selectedDate          = t.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _categoryScrollCtrl.dispose();
    super.dispose();
  }

  void _ensureCategoryValid() {
    final cats = _selectedType == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;
    if (!cats.containsKey(_selectedCategory)) {
      _selectedCategory = cats.keys.first;
    }
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
                  const Text(
                    'Edit Transaction',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TypeToggle(
                    selected: _selectedType,
                    activeColor: _typeColor,
                    onChanged: (t) => setState(() {
                      _selectedType = t;
                      _ensureCategoryValid();
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
                final category   = categories.keys.elementAt(index);
                final icon       = categories[category]!;
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
                      style: TextStyle(
                          color: c.textSecondary, fontSize: 14)),
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

  Widget _buildBottomBar(AppColors c) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final safePad = MediaQuery.of(context).padding.bottom;
    return Container(
      color: c.background,
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom > 0 ? bottom : (safePad > 0 ? safePad : 12)),
      child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Save
              AnimatedContainer(
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
                        'Save Changes',
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
              const SizedBox(height: 8),
              // Delete
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _confirmDelete,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppConstants.expenseColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: AppConstants.expenseColor, size: 18),
                          SizedBox(width: 6),
                          Text('Delete Transaction',
                              style: TextStyle(
                                  color: AppConstants.expenseColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
    context.read<TransactionProvider>().updateTransaction(Transaction(
          id: widget.transaction.id,
          amount: amount,
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          type: _selectedType,
          paymentMethod: _selectedPaymentMethod,
          date: _selectedDate,
          icon: _selectedCategory,
        ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Transaction updated'),
      backgroundColor: Colors.green,
    ));
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<TransactionProvider>()
                  .deleteTransaction(widget.transaction.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Transaction deleted'),
                backgroundColor: Colors.green,
              ));
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
