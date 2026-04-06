import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionFilterCubit extends Cubit<String> {
  TransactionFilterCubit() : super('All');

  void setFilter(String filter) => emit(filter);
}
