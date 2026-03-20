sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

final class GitCommandFailure extends Failure {
  const GitCommandFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
