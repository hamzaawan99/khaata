import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../constants/app_constants.dart';

class CsvService {
  static final CsvService _instance = CsvService._internal();
  factory CsvService() => _instance;
  CsvService._internal();

  Future<String> exportTransactionsToCsv(List<Transaction> transactions, int year, int month) async {
    // Create CSV data
    List<List<dynamic>> csvData = [];
    
    // Add header (Monefy format)
    csvData.add([
      'date',
      'account',
      'category',
      'amount',
      'currency',
      'converted amount',
      'currency',
      'description',
    ]);

    // Add transaction data
    for (var transaction in transactions) {
      // Determine amount sign based on transaction type
      double signedAmount = transaction.type == TransactionType.expense 
          ? -transaction.amount 
          : transaction.amount;
      
      // Get account name from payment method
      String account = AppConstants.paymentMethodLabels[transaction.paymentMethod] ?? 'Cash';
      
      csvData.add([
        DateFormat('dd/MM/yyyy').format(transaction.date),
        account,
        transaction.category,
        signedAmount.toStringAsFixed(2),
        'PKR',
        signedAmount.toStringAsFixed(2),
        'PKR',
        transaction.description,
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(csvData);

    // Get downloads directory for easier access
    Directory? directory;
    if (Platform.isAndroid) {
      // Try to get Downloads directory first
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        // Fallback to external storage
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    // Create filename with timestamp to avoid conflicts
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String fileName = 'khaata_${year}_${month.toString().padLeft(2, '0')}_$timestamp.csv';
    String filePath = '${directory.path}/$fileName';

    // Write file
    File file = File(filePath);
    await file.writeAsString(csv);

    return filePath;
  }

  Future<String> exportAllTransactionsToCsv(List<Transaction> transactions) async {
    // Create CSV data
    List<List<dynamic>> csvData = [];
    
    // Add header (Monefy format)
    csvData.add([
      'date',
      'account',
      'category',
      'amount',
      'currency',
      'converted amount',
      'currency',
      'description',
    ]);

    // Sort transactions by date
    transactions.sort((a, b) => b.date.compareTo(a.date));

    // Add transaction data
    for (var transaction in transactions) {
      // Determine amount sign based on transaction type
      double signedAmount = transaction.type == TransactionType.expense 
          ? -transaction.amount 
          : transaction.amount;
      
      // Get account name from payment method
      String account = AppConstants.paymentMethodLabels[transaction.paymentMethod] ?? 'Cash';
      
      csvData.add([
        DateFormat('dd/MM/yyyy').format(transaction.date),
        account,
        transaction.category,
        signedAmount.toStringAsFixed(2),
        'PKR',
        signedAmount.toStringAsFixed(2),
        'PKR',
        transaction.description,
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(csvData);

    // Get downloads directory for easier access
    Directory? directory;
    if (Platform.isAndroid) {
      // Try to get Downloads directory first
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        // Fallback to external storage
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    // Create filename with timestamp to avoid conflicts
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String fileName = 'khaata_all_transactions_$timestamp.csv';
    String filePath = '${directory.path}/$fileName';

    // Write file
    File file = File(filePath);
    await file.writeAsString(csv);

    return filePath;
  }

  Future<List<Transaction>> importTransactionsFromCsv(String filePath) async {
    try {
      // Read the CSV file
      File file = File(filePath);
      String csvString = await file.readAsString();
      
      print('CSV content length: ${csvString.length}');
      
      // Parse CSV data
      List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
      
      print('CSV rows: ${csvData.length}');
      if (csvData.isNotEmpty) {
        print('Header row: ${csvData[0]}');
      }

      // ── Detect date format from all rows ────────────────────────────────
      // App export uses dd/MM/yyyy (zero-padded, day first)
      // Monefy uses M/d/yyyy (no padding, month first)
      // Scan: if any row's second component > 12 it must be a day → M/d/yyyy
      //       if any row's first component > 12 it must be a day → dd/MM/yyyy
      String dateFormat = 'M/d/yyyy'; // default (Monefy)
      outer:
      for (int i = 1; i < csvData.length; i++) {
        if (csvData[i].isEmpty) continue;
        final parts = csvData[i][0].toString().trim().split('/');
        if (parts.length == 3) {
          final a = int.tryParse(parts[0]) ?? 0;
          final b = int.tryParse(parts[1]) ?? 0;
          if (b > 12) { dateFormat = 'M/d/yyyy'; break outer; }  // day is second → Monefy
          if (a > 12) { dateFormat = 'dd/MM/yyyy'; break outer; } // day is first → app
        }
      }
      print('Detected date format: $dateFormat');
      
      List<Transaction> transactions = [];
      
      // Skip header row and process data rows
      for (int i = 1; i < csvData.length; i++) {
        List<dynamic> row = csvData[i];
        
        if (row.length >= 8) {
          try {
            // Parse date using detected format
            String dateStr = row[0].toString().trim();
            DateTime date = DateFormat(dateFormat).parse(dateStr);
            
            // Parse account (payment method)
            String account = row[1].toString().trim();
            PaymentMethod paymentMethod = PaymentMethod.cash; // Default
            if (account.toLowerCase().contains('debit')) {
              paymentMethod = PaymentMethod.debitCard;
            } else if (account.toLowerCase().contains('credit')) {
              paymentMethod = PaymentMethod.creditCard;
            }
            
            // Parse category
            String category = row[2].toString().trim();
            
            // Parse amount and determine type
            String amountStr = row[3].toString().replaceAll(',', '').trim();
            double amount = double.parse(amountStr);
            
            // Determine transaction type based on amount sign
            TransactionType type = amount >= 0 ? TransactionType.income : TransactionType.expense;
            
            // Make amount positive for storage
            amount = amount.abs();
            
            // Parse description
            String description = row[7].toString().trim();
            
            // Create transaction
            Transaction transaction = Transaction(
              id: 0, // Will be set by database
              amount: amount,
              category: category,
              description: description,
              type: type,
              paymentMethod: paymentMethod,
              date: date,
              icon: category, // Use category name as icon identifier
            );
            
            transactions.add(transaction);
            print('Successfully created transaction: ${transaction.category} - ${transaction.amount}');
          } catch (e) {
            // Skip invalid rows
            print('Skipping invalid row $i: $e');
          }
        } else {
          print('Row $i has insufficient columns: ${row.length} (need at least 8)');
        }
      }
      
      print('Total transactions created: ${transactions.length}');
      return transactions;
    } catch (e) {
      print('CSV import error: $e');
      throw Exception('Failed to parse CSV file: $e');
    }
  }
} 