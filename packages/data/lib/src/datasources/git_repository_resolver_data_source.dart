import 'dart:io';

import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:path/path.dart' as p;

import 'git_command_runner.dart';

final class GitRepositoryResolverDataSource {
  const GitRepositoryResolverDataSource({
    required GitCommandRunner commandRunner,
  }) : _commandRunner = commandRunner;

  final GitCommandRunner _commandRunner;

  Future<Result<SavedRepository>> resolveRepository(String selectedPath) async {
    final Directory directory = Directory(selectedPath);

    if (!await directory.exists()) {
      return const FailureResult<SavedRepository>(
        ValidationFailure('The selected folder does not exist.'),
      );
    }

    final GitCommandResult result = await _commandRunner.run(const <String>[
      'rev-parse',
      '--show-toplevel',
    ], workingDirectory: selectedPath);

    if (!result.isSuccess || result.stdout.isEmpty) {
      final String message = result.stderr.isEmpty
          ? 'The selected folder is not a Git repository.'
          : result.stderr;

      return FailureResult<SavedRepository>(ValidationFailure(message));
    }

    final String normalizedPath = p.normalize(result.stdout);

    return Success<SavedRepository>(
      SavedRepository(
        rootPath: normalizedPath,
        displayName: p.basename(normalizedPath),
      ),
    );
  }
}
