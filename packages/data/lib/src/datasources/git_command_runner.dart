import 'package:process/process.dart';

final class GitCommandRunner {
  GitCommandRunner({ProcessManager? processManager})
    : _processManager = processManager ?? LocalProcessManager();

  final ProcessManager _processManager;

  Future<GitCommandResult> run(
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    final result = await _processManager.run(<String>[
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
