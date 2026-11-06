/// Typed error hierarchy for repository/use-case layer.
///
/// Use `sealed` matching at the UI layer:
/// ```dart
/// switch (failure) {
///   case NetworkFailure():    showOfflineBanner();
///   case NotFoundFailure():   showEmpty();
///   case ValidationFailure(:final message): showSnack(message);
///   case ServerFailure():     showRetry();
///   case CacheFailure():      showRetry();
///   case UnknownFailure():    showRetry();
/// }
/// ```
sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет соединения']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Не найдено']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Ошибка локального хранилища']);
}

class UnknownFailure extends Failure {
  final Object? cause;
  const UnknownFailure([super.message = 'Неизвестная ошибка', this.cause]);
}
