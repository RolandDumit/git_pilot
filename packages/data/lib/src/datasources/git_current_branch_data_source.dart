import 'package:git_pilot_domain/git_pilot_domain.dart';

import 'git_command_runner.dart';

final class GitCurrentBranchDataSource {
  const GitCurrentBranchDataSource({required GitCommandRunner commandRunner})
    : _commandRunner = commandRunner;

  final GitCommandRunner _commandRunner;

  Future<Result<CurrentBranchContext>> loadCurrentBranchContext(
    SavedRepository repository,
  ) async {
    final GitCommandResult localBranchResult = await _commandRunner.run(
      const <String>['branch', '--show-current'],
      workingDirectory: repository.rootPath,
    );

    if (!localBranchResult.isSuccess) {
      final String message = localBranchResult.stderr.isEmpty
          ? 'Unable to load the current branch.'
          : localBranchResult.stderr;

      return FailureResult<CurrentBranchContext>(GitCommandFailure(message));
    }

    final GitCommandResult upstreamResult = await _commandRunner.run(
      const <String>[
        'rev-parse',
        '--abbrev-ref',
        '--symbolic-full-name',
        '@{u}',
      ],
      workingDirectory: repository.rootPath,
    );

    final String? localBranchName = _normalizeValue(localBranchResult.stdout);
    final String? upstreamBranchName = upstreamResult.isSuccess
        ? _normalizeValue(upstreamResult.stdout)
        : null;

    return Success<CurrentBranchContext>(
      CurrentBranchContext(
        localBranchName: localBranchName,
        upstreamBranchName: upstreamBranchName,
      ),
    );
  }

  String? _normalizeValue(String value) {
    final String normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
