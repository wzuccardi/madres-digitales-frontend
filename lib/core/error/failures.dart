abstract class Failure implements Exception {
  const Failure([this.message]);
  final String? message;
  @override
  String toString() => message ?? runtimeType.toString();
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message]);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message]);
}
