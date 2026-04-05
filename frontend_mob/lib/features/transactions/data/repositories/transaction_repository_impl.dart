import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

@LazySingleton(as: ITransactionRepository)
class TransactionRepositoryImpl implements ITransactionRepository {
  final ITransactionRemoteDatasource _remote;

  TransactionRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page = 1,
    String? category,
    TransactionType? type,
    String? search,
  }) async {
    try {
      final models = await _remote.getTransactions(
        page: page,
        category: category,
        type: type?.name,
        search: search,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction) async {
    try {
      final model = await _remote.addTransaction(TransactionModel.fromEntity(transaction));
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction) async {
    try {
      final model = await _remote.updateTransaction(TransactionModel.fromEntity(transaction));
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    try {
      await _remote.deleteTransaction(id);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getCategoryTotals(DateTime month) async {
    try {
      final monthStr = DateFormat('yyyy-MM').format(month);
      final result = await _remote.getCategoryTotals(monthStr);
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    }
  }
}
