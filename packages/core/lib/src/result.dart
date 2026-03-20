import 'failures/failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  R map<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final Result<T> result = this;

    if (result is Success<T>) {
      return success(result.data);
    }

    if (result is FailureResult<T>) {
      return failure(result.failure);
    }

    throw StateError('Unhandled Result type: $runtimeType');
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;
}
