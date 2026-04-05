import 'package:equatable/equatable.dart';

enum GoalType { savings, noSpend, budgetLimit, streak }

class Goal extends Equatable {
  final String id;
  final String title;
  final GoalType type;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int streakDays;

  const Goal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.streakDays = 0,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;
  bool get isCompleted => currentAmount >= targetAmount;
  int get daysLeft => endDate.difference(DateTime.now()).inDays.clamp(0, 9999);

  Goal copyWith({
    String? id,
    String? title,
    GoalType? type,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? streakDays,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  @override
  List<Object?> get props => [id, title, type, targetAmount, currentAmount, startDate, endDate, isActive, streakDays];
}
