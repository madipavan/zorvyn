import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:frontend_mob/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/i_dashboard_repository.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final IDashboardRepository _repo;

  DashboardBloc(this._repo) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final result = await _repo.getDashboardSummary();
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (summary) => emit(DashboardLoaded(summary)),
    );
  }
}
