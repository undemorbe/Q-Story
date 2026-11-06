import '../errors/failures.dart';

/// Either-style result type for repository methods. Wraps success [T] or
/// a typed [Failure]. Use `switch` for exhaustive matching:
///
/// ```dart
/// switch (result) {
///   case Ok(value: final v): ...
///   case Err(failure: final f): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  factory Result.ok(T value) = Ok<T>;
  factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// Returns value or `null` on error.
  T? get valueOrNull => switch (this) {
        Ok<T>(value: final v) => v,
        Err<T>() => null,
      };

  /// Returns failure or `null` on success.
  Failure? get failureOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(failure: final f) => f,
      };
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
