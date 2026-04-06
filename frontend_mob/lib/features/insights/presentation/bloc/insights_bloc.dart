import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/features/insights/presentation/bloc/insights_event.dart';
import 'package:frontend_mob/features/insights/presentation/bloc/insights_state.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/i_insights_repository.dart';

@injectable
class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final IInsightsRepository _repo;

  InsightsBloc(this._repo) : super(InsightsInitial()) {
    on<LoadInsights>(_onLoad);
  }

  Future<void> _onLoad(LoadInsights event, Emitter<InsightsState> emit) async {
    emit(InsightsLoading());
    final result = await _repo.getInsights();
    result.fold(
      (failure) => emit(InsightsError(failure.message)),
      (summary) => emit(InsightsLoaded(summary)),
    );
  }
}
