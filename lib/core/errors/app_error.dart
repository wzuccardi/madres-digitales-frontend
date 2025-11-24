class AppError implements Exception {
  const AppError(this.message, {this.code});
  final String message;
  final String? code;
  @override
  String toString() => 'AppError: $message${code != null ? ' (code: $code)' : ''}';
}

class NetworkError extends AppError {
  const NetworkError(super.message, {super.code});
}

class ServerError extends AppError {
  const ServerError(super.message, {super.code});
}

class TimeoutError extends AppError {
  const TimeoutError(super.message, {super.code});
}

class SessionExpiredError extends AppError {
  const SessionExpiredError(super.message, {super.code});
}

class InvalidTokenError extends AppError {
  const InvalidTokenError(super.message, {super.code});
}

class AuthenticationError extends AppError {
  const AuthenticationError(super.message, {super.code});
}

class UnknownError extends AppError {
  const UnknownError(super.message, {super.code});
}

class AuthError extends AppError {
  const AuthError(super.message, {super.code});
}

class PermissionError extends AppError {
  const PermissionError(super.message, {super.code});
}

class NotFoundError extends AppError {
  const NotFoundError(super.message, {super.code});
}

class FileSizeExceededError extends AppError {
  const FileSizeExceededError(super.message, {super.code});
}

class FileUploadError extends AppError {
  const FileUploadError(super.message, {super.code});
}

class StorageError extends AppError {
  const StorageError(super.message, {super.code});
}

class ConfigurationError extends AppError {
  const ConfigurationError(super.message, {super.code});
}

class ValidationError extends AppError {
  const ValidationError(super.message, {super.code});
}
