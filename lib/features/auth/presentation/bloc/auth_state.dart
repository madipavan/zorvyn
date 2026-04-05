import 'package:equatable/equatable.dart';
import 'package:frontend_mob/features/auth/domain/entities/auth_user.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailedState extends AuthState {
  final String message;
  AuthFailedState(this.message);
  @override
  List<Object?> get props => [message];
}
