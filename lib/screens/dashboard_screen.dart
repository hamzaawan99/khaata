import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/add_transaction_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../models/transaction.dart';
import 'package:file_picker/file_picker.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final PageController _pageController;
  int _currentPageIndex = _initialPage;

  static const int _initialPage = 12;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isCurrentMonth(TransactionProvider provider) {
    final now = DateTime.now();
    return provider.selectedDate.year == now.year &&
        provider.selectedDate.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final c        = Theme.of(context).extension<AppColors>()!;
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: c.background,
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.initialize(),
            color: AppConstants.primaryColor,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPageIndex = index);
                final now = DateTime.now();
                final targetDate =
                    DateTime(now.year, now.month - _initialPage + index, 1);
                provider.setCurrentMonth(targetDate);
              },
              itemCount: _initialPage + 1,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(context, provider, c, settings),
                      _buildChartCard(context, provider, c),
                      _buildQuickActions(context, c),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, TransactionProvider provider,
      AppColors c, SettingsProvider settings) {
    final isNegative = provider.balance < 0;
    return Container(
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
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  const Text(
                    'Khaata',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.upload_rounded,
                        color: Colors.white70, size: 22),
                    onPressed: () => _showImportDialog(context),
                    tooltip: 'Import CSV',
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_rounded,
                        color: Colors.white70, size: 22),
                    onPressed: () => _showExportDialog(context),
                    tooltip: 'Export CSV',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded,
                        color: Colors.white70, size: 22),
                    onPressed: () => showSettingsSheet(context),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),

            // Month navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavArrowButton(
                    icon: Icons.chevron_left_rounded,
                    enabled: _currentPageIndex > 0,
                    onTap: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.monthYearString,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _NavArrowButton(
                    icon: Icons.chevron_right_rounded,
                    enabled: !_isCurrentMonth(provider),
                    onTap: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ],
              ),
            ),

            // Balance
            const SizedBox(height: 4),
            Text(
              'Total Balance',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            Text(
              settings.format(provider.balance),
              style: TextStyle(
                color: isNegative
                    ? const Color(0xFFFC8181)
                    : Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),

            const SizedBox(height: 20),

            // Income/Expense summary row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryPill(
                        label: 'Income',
                        amount: settings.format(provider.totalIncome),
                        icon: Icons.arrow_upward_rounded,
                        color: const Color(0xFF68D391),
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withOpacity(0.2)),
                    Expanded(
                      child: _SummaryPill(
                        label: 'Expenses',
                        amount: settings.format(provider.totalExpenses),
                        icon: Icons.arrow_downward_rounded,
                        color: const Color(0xFFFC8181),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

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
    );
  }

  // ─── Chart Card ────────────────────────────────────────────────────────────

  Widget _buildChartCard(
      BuildContext context, TransactionProvider provider, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4)),
          ],
        ),
        child: provider.expenseCategoryTotals.isEmpty
            ? _buildEmptyChart(c)
            : _buildPieChart(provider, c),
      ),
    );
  }

  Widget _buildEmptyChart(AppColors c) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Expense Breakdown',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: c.text),
          ),
        ),
        const SizedBox(height: 24),
        Icon(Icons.pie_chart_outline_rounded, size: 52, color: c.divider),
        const SizedBox(height: 12),
        Text('No expenses this month',
            style: TextStyle(color: c.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPieChart(TransactionProvider provider, AppColors c) {
    final settings = context.read<SettingsProvider>();
    final totals   = provider.expenseCategoryTotals;
    final keys     = totals.keys.toList();
    final sections = totals.entries.map((e) {
      final pct = e.value / provider.totalExpenses * 100;
      final ci  = keys.indexOf(e.key) % AppConstants.chartColors.length;
      return PieChartSectionData(
        value: e.value,
        title: pct >= 9 ? '${pct.toStringAsFixed(0)}%' : '',
        color: AppConstants.chartColors[ci],
        radius: 54,
        titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Expense Breakdown',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: c.text)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.expenseColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                settings.format(provider.totalExpenses),
                style: const TextStyle(
                    color: AppConstants.expenseColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 160,
                child: PieChart(PieChartData(
                  sections: sections,
                  centerSpaceRadius: 32,
                  sectionsSpace: 2,
                )),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildLegend(provider, c)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(TransactionProvider provider, AppColors c) {
    final totals = provider.expenseCategoryTotals;
    final keys   = totals.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: totals.entries.take(7).map((e) {
        final ci  = keys.indexOf(e.key) % AppConstants.chartColors.length;
        final pct = e.value / provider.totalExpenses * 100;
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppConstants.chartColors[ci],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(e.key,
                    style: TextStyle(fontSize: 11, color: c.text),
                    overflow: TextOverflow.ellipsis),
              ),
              Text('${pct.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 11, color: c.textSecondary)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          // Two add buttons
          Row(
            children: [
              Expanded(
                child: _QuickAddButton(
                  label: 'Expense',
                  symbol: '−',
                  color: AppConstants.expenseColor,
                  darkColor: AppConstants.expenseDark,
                  icon: Icons.arrow_downward_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(
                          initialType: TransactionType.expense),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAddButton(
                  label: 'Income',
                  symbol: '+',
                  color: AppConstants.incomeColor,
                  darkColor: AppConstants.incomeDark,
                  icon: Icons.arrow_upward_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(
                          initialType: TransactionType.income),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // History button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TransactionHistoryScreen()),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded,
                      color: AppConstants.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'View Transaction History',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: AppConstants.primaryColor, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs ───────────────────────────────────────────────────────────────

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose what to export:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportCurrentMonth(context);
            },
            child: const Text('Current Month'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportAllData(context);
            },
            child: const Text('All Data'),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _exportCurrentMonth(BuildContext context) async {
    try {
      final filePath =
          await context.read<TransactionProvider>().exportCurrentMonthToCsv();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Exported: ${filePath.split('/').last}'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  void _exportAllData(BuildContext context) async {
    try {
      final filePath =
          await context.read<TransactionProvider>().exportAllTransactionsToCsv();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Exported: ${filePath.split('/').last}'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
            'Choose a CSV file exported by Khaata to import transactions.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _importFromCsv(context);
            },
            child: const Text('Import CSV'),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _importFromCsv(BuildContext context) async {
    final provider = context.read<TransactionProvider>();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result != null && result.files.isNotEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Importing\u2026 please wait.')));
        }
        await provider.importFromCsv(result.files.first.path!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Data imported successfully!'),
            backgroundColor: Colors.green,
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _NavArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavArrowButton(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: enabled ? Colors.white : Colors.white.withOpacity(0.25),
            size: 24),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryPill(
      {required this.label,
      required this.amount,
      required this.icon,
      required this.color});

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
                color: color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 13),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 5),
        Text(amount,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _QuickAddButton extends StatelessWidget {
  final String label;
  final String symbol;
  final Color color;
  final Color darkColor;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.label,
    required this.symbol,
    required this.color,
    required this.darkColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, darkColor],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Large background symbol
            Positioned(
              right: 12,
              bottom: -4,
              child: Text(
                symbol,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.15),
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  Text(
                    'Add $label',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
