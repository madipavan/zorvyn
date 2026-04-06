import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/utils/app_constants.dart';
import 'package:frontend_mob/features/transactions/domain/entities/transaction.dart';

class TransactionFormState {
  final TransactionType type;
  final String category;
  final DateTime date;

  const TransactionFormState({
    required this.type,
    required this.category,
    required this.date,
  });

  TransactionFormState copyWith({
    TransactionType? type,
    String? category,
    DateTime? date,
  }) {
    return TransactionFormState(
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }
}

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit()
      : super(TransactionFormState(
          type: TransactionType.expense,
          category: AppConstants.expenseCategories.first,
          date: DateTime.now(),
        ));

  void prefill({
    required TransactionType type,
    required String category,
    required DateTime date,
  }) {
    emit(TransactionFormState(type: type, category: category, date: date));
  }

  void setType(TransactionType type) {
    final category = type == TransactionType.expense
        ? AppConstants.expenseCategories.first
        : AppConstants.incomeCategories.first;
    emit(state.copyWith(type: type, category: category));
  }

  void setCategory(String category) {
    emit(state.copyWith(category: category));
  }

  void setDate(DateTime date) {
    emit(state.copyWith(date: date));
  }
}
