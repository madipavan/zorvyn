import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend_mob/features/auth/presentation/bloc/auth_state.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/auth_event_bus.dart' as bus;
import '../../domain/repositories/i_auth_repository.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _repo.login(event.email, event.password);
    result.fold(
      (failure) => emit(AuthFailedState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _repo.register(
      event.name,
      event.email,
      event.password,
    );
    result.fold(
      (failure) => emit(AuthFailedState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _repo.logout();
    bus.AuthEventBus.instance.add(bus.AuthEvent.loggedOut);
    emit(AuthUnauthenticated());
  }
}
