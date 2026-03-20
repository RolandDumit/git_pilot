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
