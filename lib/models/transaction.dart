import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final double amount;
  final String category;
  final String description;
  final TransactionType type;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String? icon;

  Transaction({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.type,
    required this.paymentMethod,
    required this.date,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'amount': amount,
      'category': category,
      'description': description,
      'type': type.index,
      'paymentMethod': paymentMethod.index,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'icon': icon,
    };
    if (id != 0) map['id'] = id;
    return map;
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      type: TransactionType.values[map['type']],
      paymentMethod: PaymentMethod.values[map['paymentMethod']],
      date: DateFormat('yyyy-MM-dd').parse(map['date']),
      icon: map['icon'],
    );
  }

  Transaction copyWith({
    int? id,
    double? amount,
    String? category,
    String? description,
    TransactionType? type,
    PaymentMethod? paymentMethod,
    DateTime? date,
    String? icon,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      icon: icon ?? this.icon,
    );
  }
} 