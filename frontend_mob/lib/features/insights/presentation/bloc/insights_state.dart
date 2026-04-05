import 'package:equatable/equatable.dart';
import 'package:frontend_mob/features/insights/domain/entities/insights_summary.dart';

abstract class InsightsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InsightsInitial extends InsightsState {}

class InsightsLoading extends InsightsState {}

class InsightsLoaded extends InsightsState {
  final InsightsSummary summary;
  InsightsLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class InsightsError extends InsightsState {
  final String message;
  InsightsError(this.message);
  @override
  List<Object?> get props => [message];
}
