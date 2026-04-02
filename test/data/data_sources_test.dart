import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_pilot_data/git_pilot_data.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:path/path.dart' as p;

void main() {
  group('data sources', () {
    test(
      'workspace session local data source round-trips saved repositories and tabs',
      () async {
        final Directory tempDirectory = await Directory.systemTemp.createTemp(
          'git_pilot_session_test',
        );
        addTearDown(() async {
          await tempDirectory.delete(recursive: true);
        });

        final WorkspaceSessionLocalDataSource dataSource =
            WorkspaceSessionLocalDataSource(
              sessionFilePath: p.join(tempDirectory.path, 'workspace.json'),
            );
        const WorkspaceSession session = WorkspaceSession(
          savedRepositories: <SavedRepository>[
            SavedRepository(rootPath: '/repos/alpha', displayName: 'alpha'),
          ],
          openRepositoryIds: <String>['/repos/alpha'],
          selectedRepositoryId: '/repos/alpha',
        );

        await dataSource.writeSession(session);
        final WorkspaceSession restoredSession = await dataSource.readSession();

        expect(restoredSession, session);
      },
    );

    test(
      'git repository resolver data source returns normalized repository root',
      () async {
        final GitRepositoryResolverDataSource dataSource =
            GitRepositoryResolverDataSource(
              commandRunner: const _FakeGitCommandRunner(
                result: GitCommandResult(
                  exitCode: 0,
                  stdout: '/repos/git_pilot',
                  stderr: '',
                ),
              ),
            );
        final Directory tempDirectory = await Directory.systemTemp.createTemp(
          'git_pilot_repo_resolver',
        );
        addTearDown(() async {
          await tempDirectory.delete(recursive: true);
        });

        final Result<SavedRepository> result = await dataSource
            .resolveRepository(tempDirectory.path);

        expect(result, isA<Success<SavedRepository>>());
        expect(
          (result as Success<SavedRepository>).data,
          const SavedRepository(
            rootPath: '/repos/git_pilot',
            displayName: 'git_pilot',
          ),
        );
      },
    );

    test(
      'git remote branches data source filters symbolic HEAD refs',
      () async {
        final GitRemoteBranchesDataSource dataSource =
            GitRemoteBranchesDataSource(
              commandRunner: const _FakeGitCommandRunner(
                result: GitCommandResult(
                  exitCode: 0,
                  stdout: 'origin/HEAD\norigin/main\norigin/release',
                  stderr: '',
                ),
              ),
            );

        final Result<List<RemoteBranchRef>> result = await dataSource
            .loadRemoteBranches(
              const SavedRepository(
                rootPath: '/repos/git_pilot',
                displayName: 'git_pilot',
              ),
            );

        expect(result, isA<Success<List<RemoteBranchRef>>>());
        expect(
          (result as Success<List<RemoteBranchRef>>).data,
          const <RemoteBranchRef>[
            RemoteBranchRef(name: 'origin/main'),
            RemoteBranchRef(name: 'origin/release'),
          ],
        );
      },
    );

    test(
      'git current branch data source returns local and upstream branches',
      () async {
        final GitCurrentBranchDataSource dataSource =
            GitCurrentBranchDataSource(
              commandRunner: _SequenceGitCommandRunner(
                results: const <GitCommandResult>[
                  GitCommandResult(exitCode: 0, stdout: 'main', stderr: ''),
                  GitCommandResult(
                    exitCode: 0,
                    stdout: 'origin/main',
                    stderr: '',
                  ),
                ],
              ),
            );

        final Result<CurrentBranchContext> result = await dataSource
            .loadCurrentBranchContext(
              const SavedRepository(
                rootPath: '/repos/git_pilot',
                displayName: 'git_pilot',
              ),
            );

        expect(result, isA<Success<CurrentBranchContext>>());
        expect(
          (result as Success<CurrentBranchContext>).data,
          const CurrentBranchContext(
            localBranchName: 'main',
            upstreamBranchName: 'origin/main',
          ),
        );
      },
    );

    test(
      'git current branch data source falls back when upstream is missing',
      () async {
        final GitCurrentBranchDataSource dataSource =
            GitCurrentBranchDataSource(
              commandRunner: _SequenceGitCommandRunner(
                results: const <GitCommandResult>[
                  GitCommandResult(exitCode: 0, stdout: 'release', stderr: ''),
                  GitCommandResult(
                    exitCode: 128,
                    stdout: '',
                    stderr: 'no upstream configured',
                  ),
                ],
              ),
            );

        final Result<CurrentBranchContext> result = await dataSource
            .loadCurrentBranchContext(
              const SavedRepository(
                rootPath: '/repos/git_pilot',
                displayName: 'git_pilot',
              ),
            );

        expect(result, isA<Success<CurrentBranchContext>>());
        expect(
          (result as Success<CurrentBranchContext>).data,
          const CurrentBranchContext(
            localBranchName: 'release',
            upstreamBranchName: null,
          ),
        );
      },
    );

    test('git recent commits data source parses commit summaries', () async {
      final GitRecentCommitsDataSource dataSource = GitRecentCommitsDataSource(
        commandRunner: const _FakeGitCommandRunner(
          result: GitCommandResult(
            exitCode: 0,
            stdout:
                'abcdef1234567890\u001fAda Lovelace\u001f2026-04-01T10:30:00Z\u001fInitial commit\n'
                '1234567890abcdef\u001fGrace Hopper\u001f2026-04-02T08:00:00Z\u001fAdd history panel',
            stderr: '',
          ),
        ),
      );

      final Result<List<CommitSummary>> result = await dataSource
          .loadRecentCommits(
            const SavedRepository(
              rootPath: '/repos/git_pilot',
              displayName: 'git_pilot',
            ),
          );

      expect(result, isA<Success<List<CommitSummary>>>());
      expect((result as Success<List<CommitSummary>>).data, <CommitSummary>[
        CommitSummary(
          hash: 'abcdef1234567890',
          authorName: 'Ada Lovelace',
          committedAt: DateTime.parse('2026-04-01T10:30:00Z'),
          subject: 'Initial commit',
        ),
        CommitSummary(
          hash: '1234567890abcdef',
          authorName: 'Grace Hopper',
          committedAt: DateTime.parse('2026-04-02T08:00:00Z'),
          subject: 'Add history panel',
        ),
      ]);
    });

    test('git recent commits data source returns git failures', () async {
      final GitRecentCommitsDataSource dataSource = GitRecentCommitsDataSource(
        commandRunner: const _FakeGitCommandRunner(
          result: GitCommandResult(
            exitCode: 128,
            stdout: '',
            stderr: 'fatal: not a git repository',
          ),
        ),
      );

      final Result<List<CommitSummary>> result = await dataSource
          .loadRecentCommits(
            const SavedRepository(
              rootPath: '/repos/git_pilot',
              displayName: 'git_pilot',
            ),
          );

      expect(result, isA<FailureResult<List<CommitSummary>>>());
      expect(
        (result as FailureResult<List<CommitSummary>>).failure.message,
        'fatal: not a git repository',
      );
    });

    test(
      'repository file tree data source excludes .git and sorts directories before files',
      () async {
        final Directory repoDirectory = await Directory.systemTemp.createTemp(
          'git_pilot_file_tree',
        );
        addTearDown(() async {
          await repoDirectory.delete(recursive: true);
        });

        await Directory(p.join(repoDirectory.path, '.git')).create();
        await Directory(p.join(repoDirectory.path, 'lib')).create();
        await File(
          p.join(repoDirectory.path, 'README.md'),
        ).writeAsString('readme');
        await File(
          p.join(repoDirectory.path, 'analysis_options.yaml'),
        ).writeAsString('lints');

        const RepositoryFileTreeDataSource dataSource =
            RepositoryFileTreeDataSource();

        final Result<List<RepositoryTreeNode>> result = await dataSource
            .loadTreeNodes(
              SavedRepository(
                rootPath: repoDirectory.path,
                displayName: 'file_tree',
              ),
            );

        expect(result, isA<Success<List<RepositoryTreeNode>>>());
        expect(
          (result as Success<List<RepositoryTreeNode>>).data
              .map((RepositoryTreeNode node) => node.name)
              .toList(growable: false),
          <String>['lib', 'analysis_options.yaml', 'README.md'],
        );
      },
    );
  });
}

final class _FakeGitCommandRunner implements GitCommandRunner {
  const _FakeGitCommandRunner({required this.result});

  final GitCommandResult result;

  @override
  Future<GitCommandResult> run(
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    return result;
  }
}

final class _SequenceGitCommandRunner implements GitCommandRunner {
  _SequenceGitCommandRunner({required List<GitCommandResult> results})
    : _results = results;

  final List<GitCommandResult> _results;
  int _index = 0;

  @override
  Future<GitCommandResult> run(
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    final GitCommandResult result = _results[_index];
    _index += 1;
    return result;
  }
}
