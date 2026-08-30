import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(String message, {this.statusCode}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'Network connection unavailable.'}) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}
