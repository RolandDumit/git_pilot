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
