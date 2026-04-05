import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';

abstract class ITransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page,
    String? category,
    TransactionType? type,
    String? search,
  });

  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction);

  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction);

  Future<Either<Failure, Unit>> deleteTransaction(String id);

  Future<Either<Failure, Map<String, double>>> getCategoryTotals(DateTime month);
}
