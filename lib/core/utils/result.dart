import '../errors/app_error.dart';

/// Repository return type.
///
/// Repositories return `Result` instead of throwing so controllers cannot
/// forget an error path: the switch is exhaustive at compile time.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  AppError? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final error) => error,
      };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Failure<T>(:final error) => onFailure(error),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(:final value) => Success<R>(transform(value)),
      Failure<T>(:final error) => Failure<R>(error),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppError error;
}

/// Runs [action], converting any [AppError] thrown by the API layer into a
/// [Failure]. Anything else is wrapped as [UnknownError] rather than escaping
/// into the widget tree.
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Success<T>(await action());
  } on AppError catch (error) {
    return Failure<T>(error);
  } catch (error, stackTrace) {
    return Failure<T>(
      UnknownError(
        debugMessage: error.toString(),
        cause: error,
        stackTrace: stackTrace,
      ),
    );
  }
}
