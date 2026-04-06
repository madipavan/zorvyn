import '../../domain/entities/transaction.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String type;
  final String category;
  final String date;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      category: json['category'] as String,
      date: json['date'] as String,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date,
        if (note != null) 'note': note,
      };

  Transaction toEntity() => Transaction(
        id: id,
        amount: amount,
        type: type == 'income' ? TransactionType.income : TransactionType.expense,
        category: category,
        date: DateTime.parse(date),
        note: note,
      );

  static TransactionModel fromEntity(Transaction t) => TransactionModel(
        id: t.id,
        amount: t.amount,
        type: t.type.name,
        category: t.category,
        date: t.date.toIso8601String(),
        note: t.note,
      );
}
