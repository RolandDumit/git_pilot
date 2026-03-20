import 'dart:io';

import 'package:process/process.dart';

abstract interface class GitCommandRunner {
  Future<GitCommandResult> run(
    List<String> arguments, {
    String? workingDirectory,
  });
}

final class ProcessGitCommandRunner implements GitCommandRunner {
  ProcessGitCommandRunner({ProcessManager? processManager})
    : _processManager = processManager ?? LocalProcessManager();

  final ProcessManager _processManager;

  @override
  Future<GitCommandResult> run(
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    final ProcessResult result = await _processManager.run(<String>[
      'git',
      ...arguments,
    ], workingDirectory: workingDirectory);

    return GitCommandResult(
      exitCode: result.exitCode,
      stdout: '${result.stdout}'.trim(),
      stderr: '${result.stderr}'.trim(),
    );
  }
}

final class GitCommandResult {
  const GitCommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;

  bool get isSuccess => exitCode == 0;
}
