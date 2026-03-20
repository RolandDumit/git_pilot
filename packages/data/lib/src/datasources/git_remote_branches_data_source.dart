import 'package:git_pilot_domain/git_pilot_domain.dart';

import 'git_command_runner.dart';

final class GitRemoteBranchesDataSource {
  const GitRemoteBranchesDataSource({required GitCommandRunner commandRunner})
    : _commandRunner = commandRunner;

  final GitCommandRunner _commandRunner;

  Future<Result<List<RemoteBranchRef>>> loadRemoteBranches(
    SavedRepository repository,
  ) async {
    final GitCommandResult result = await _commandRunner.run(const <String>[
      'for-each-ref',
      'refs/remotes',
      '--format=%(refname:short)',
    ], workingDirectory: repository.rootPath);

    if (!result.isSuccess) {
      final String message = result.stderr.isEmpty
          ? 'Unable to load remote branches.'
          : result.stderr;

      return FailureResult<List<RemoteBranchRef>>(GitCommandFailure(message));
    }

    final List<RemoteBranchRef> branches =
        result.stdout
            .split('\n')
            .map((String line) => line.trim())
            .where((String line) => line.isNotEmpty && !line.endsWith('/HEAD'))
            .map((String branchName) => RemoteBranchRef(name: branchName))
            .toList(growable: false)
          ..sort((RemoteBranchRef left, RemoteBranchRef right) {
            return left.name.compareTo(right.name);
          });

    return Success<List<RemoteBranchRef>>(branches);
  }
}
