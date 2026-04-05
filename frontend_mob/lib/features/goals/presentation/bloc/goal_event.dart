import 'package:equatable/equatable.dart';
import 'package:frontend_mob/features/goals/domain/entities/goal.dart';

abstract class GoalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalEvent {}

class CreateGoalEvent extends GoalEvent {
  final Goal goal;
  CreateGoalEvent(this.goal);
  @override
  List<Object?> get props => [goal];
}

class UpdateGoalEvent extends GoalEvent {
  final Goal goal;
  UpdateGoalEvent(this.goal);
  @override
  List<Object?> get props => [goal];
}

class DeleteGoalEvent extends GoalEvent {
  final String id;
  DeleteGoalEvent(this.id);
  @override
  List<Object?> get props => [id];
}
