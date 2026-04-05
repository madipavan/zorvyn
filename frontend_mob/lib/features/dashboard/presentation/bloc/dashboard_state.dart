import 'package:equatable/equatable.dart';
import 'package:frontend_mob/features/dashboard/domain/entities/dashboard_summary.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  DashboardLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
