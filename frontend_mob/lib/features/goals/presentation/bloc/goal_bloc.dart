import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/features/goals/presentation/bloc/goal_event.dart';
import 'package:frontend_mob/features/goals/presentation/bloc/goal_state.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/i_goal_repository.dart';

@injectable
class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final IGoalRepository _repo;

  GoalBloc(this._repo) : super(GoalInitial()) {
    on<LoadGoals>(_onLoad);
    on<CreateGoalEvent>(_onCreate);
    on<UpdateGoalEvent>(_onUpdate);
    on<DeleteGoalEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadGoals event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    final result = await _repo.getGoals();
    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (goals) => emit(GoalLoaded(goals)),
    );
  }

  Future<void> _onCreate(CreateGoalEvent event, Emitter<GoalState> emit) async {
    final result = await _repo.createGoal(event.goal);
    result.fold((failure) => emit(GoalError(failure.message)), (_) {
      emit(GoalActionSuccess('Goal created'));
      add(LoadGoals());
    });
  }

  Future<void> _onUpdate(UpdateGoalEvent event, Emitter<GoalState> emit) async {
    final result = await _repo.updateGoal(event.goal);
    result.fold((failure) => emit(GoalError(failure.message)), (_) {
      emit(GoalActionSuccess('Goal updated'));
      add(LoadGoals());
    });
  }

  Future<void> _onDelete(DeleteGoalEvent event, Emitter<GoalState> emit) async {
    final result = await _repo.deleteGoal(event.id);
    result.fold((failure) => emit(GoalError(failure.message)), (_) {
      emit(GoalActionSuccess('Goal deleted'));
      add(LoadGoals());
    });
  }
}
