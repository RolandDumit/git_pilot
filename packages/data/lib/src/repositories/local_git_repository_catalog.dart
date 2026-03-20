import 'package:git_pilot_domain/git_pilot_domain.dart';

import '../datasources/git_command_runner.dart';

final class LocalGitRepositoryCatalog implements GitRepositoryCatalog {
  LocalGitRepositoryCatalog({GitCommandRunner? commandRunner})
    : _commandRunner = commandRunner ?? GitCommandRunner();

  final GitCommandRunner _commandRunner;

  @override
  Future<Result<List<GitRepositorySummary>>> loadRepositories() async {
    final GitCommandResult result = await _commandRunner.run(const <String>[
      '--version',
    ]);

    if (!result.isSuccess) {
      final String message = result.stderr.isEmpty
          ? 'Git is not available on this machine.'
          : result.stderr;

      return FailureResult<List<GitRepositorySummary>>(
        GitCommandFailure(message),
      );
    }

    return const Success<List<GitRepositorySummary>>(<GitRepositorySummary>[]);
  }
}
