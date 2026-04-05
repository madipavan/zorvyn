abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Unauthorized']);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class ValidationFailure extends Failure {
  final List<String> errors;
  const ValidationFailure(super.message, this.errors);
}
