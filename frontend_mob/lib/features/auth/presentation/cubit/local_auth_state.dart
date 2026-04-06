abstract class LocalAuthState {}

class LocalAuthInitial extends LocalAuthState {}

class LocalAuthLoading extends LocalAuthState {}

class LocalAuthUnlocked extends LocalAuthState {}

class LocalAuthLocked extends LocalAuthState {}

class LocalAuthError extends LocalAuthState {}
