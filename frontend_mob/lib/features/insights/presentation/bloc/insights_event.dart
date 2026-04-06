import 'package:equatable/equatable.dart';

abstract class InsightsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInsights extends InsightsEvent {}
