import '../errors/app_error.dart';

// Base exception class
abstract class AppException extends AppError {
  const AppException(super.message, {super.code});
}

// Network exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code});
}

// Auth exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException(super.message, {super.code});
}

class InvalidTokenException extends AppException {
  const InvalidTokenException(super.message, {super.code});
}

class SessionExpiredException extends AppException {
  const SessionExpiredException(super.message, {super.code});
}

class UserNotFoundException extends AppException {
  const UserNotFoundException(super.message, {super.code});
}

class AccountDisabledException extends AppException {
  const AccountDisabledException(super.message, {super.code});
}

class AccountNotVerifiedException extends AppException {
  const AccountNotVerifiedException(super.message, {super.code});
}

class TooManyAttemptsException extends AppException {
  const TooManyAttemptsException(super.message, {super.code});
}

// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

// Resource exceptions
class ResourceNotFoundException extends AppException {
  const ResourceNotFoundException(super.message, {super.code});
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.code});
}

class RateLimitExceededException extends AppException {
  const RateLimitExceededException(super.message, {super.code});
}