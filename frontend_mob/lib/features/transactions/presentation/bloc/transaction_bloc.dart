import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/i_transaction_repository.dart';

abstract class TransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String? category;
  final TransactionType? type;
  final String? search;
  LoadTransactions({this.category, this.type, this.search});
  @override
  List<Object?> get props => [category, type, search];
}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;
  AddTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;
  UpdateTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;
  DeleteTransactionEvent(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class TransactionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final String? activeCategory;
  final TransactionType? activeType;
  TransactionLoaded(this.transactions, {this.activeCategory, this.activeType});
  @override
  List<Object?> get props => [transactions, activeCategory, activeType];
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}

class TransactionActionSuccess extends TransactionState {
  final String message;
  TransactionActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final ITransactionRepository _repo;

  TransactionBloc(this._repo) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoad);
    on<AddTransactionEvent>(_onAdd);
    on<UpdateTransactionEvent>(_onUpdate);
    on<DeleteTransactionEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    final result = await _repo.getTransactions(
      category: event.category,
      type: event.type,
      search: event.search,
    );
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(
        transactions,
        activeCategory: event.category,
        activeType: event.type,
      )),
    );
  }

  Future<void> _onAdd(AddTransactionEvent event, Emitter<TransactionState> emit) async {
    final result = await _repo.addTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(TransactionActionSuccess('Transaction added'));
        add(LoadTransactions());
      },
    );
  }

  Future<void> _onUpdate(UpdateTransactionEvent event, Emitter<TransactionState> emit) async {
    final result = await _repo.updateTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(TransactionActionSuccess('Transaction updated'));
        add(LoadTransactions());
      },
    );
  }

  Future<void> _onDelete(DeleteTransactionEvent event, Emitter<TransactionState> emit) async {
    final result = await _repo.deleteTransaction(event.id);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(TransactionActionSuccess('Transaction deleted'));
        add(LoadTransactions());
      },
    );
  }
}
