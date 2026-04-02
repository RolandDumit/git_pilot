import 'package:git_pilot_domain/git_pilot_domain.dart';

import 'git_command_runner.dart';

final class GitRecentCommitsDataSource {
  const GitRecentCommitsDataSource({required GitCommandRunner commandRunner})
    : _commandRunner = commandRunner;

  static const String _fieldSeparator = '\u001f';
  final GitCommandRunner _commandRunner;

  Future<Result<List<CommitSummary>>> loadRecentCommits(
    SavedRepository repository, {
    int limit = 50,
  }) async {
    final GitCommandResult result = await _commandRunner.run(<String>[
      'log',
      '-n',
      '$limit',
      '--date=iso-strict',
      '--pretty=format:%H%x1f%an%x1f%ad%x1f%s',
    ], workingDirectory: repository.rootPath);

    if (!result.isSuccess) {
      final String message = result.stderr.isEmpty
          ? 'Unable to load recent commits.'
          : result.stderr;

      return FailureResult<List<CommitSummary>>(GitCommandFailure(message));
    }

    final List<CommitSummary> commits = <CommitSummary>[];

    for (final String rawLine in result.stdout.split('\n')) {
      final String line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }

      final List<String> parts = line.split(_fieldSeparator);
      if (parts.length != 4) {
        return const FailureResult<List<CommitSummary>>(
          ValidationFailure('Unable to parse recent commit history.'),
        );
      }

      final DateTime? committedAt = DateTime.tryParse(parts[2]);
      if (committedAt == null) {
        return const FailureResult<List<CommitSummary>>(
          ValidationFailure('Unable to parse recent commit history.'),
        );
      }

      commits.add(
        CommitSummary(
          hash: parts[0],
          authorName: parts[1],
          committedAt: committedAt,
          subject: parts[3],
        ),
      );
    }

    return Success<List<CommitSummary>>(commits);
  }
}
