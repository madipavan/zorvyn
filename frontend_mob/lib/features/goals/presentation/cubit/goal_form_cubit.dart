import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/features/goals/domain/entities/goal.dart';

class GoalFormState {
  final GoalType type;
  final DateTime endDate;

  const GoalFormState({required this.type, required this.endDate});

  GoalFormState copyWith({GoalType? type, DateTime? endDate}) {
    return GoalFormState(
      type: type ?? this.type,
      endDate: endDate ?? this.endDate,
    );
  }
}

class GoalFormCubit extends Cubit<GoalFormState> {
  GoalFormCubit()
      : super(GoalFormState(
          type: GoalType.savings,
          endDate: DateTime.now().add(const Duration(days: 30)),
        ));

  void setType(GoalType type) => emit(state.copyWith(type: type));

  void setEndDate(DateTime date) => emit(state.copyWith(endDate: date));
}
