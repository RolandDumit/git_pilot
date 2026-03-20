import 'package:flutter_test/flutter_test.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';

void main() {
  group('workspace use cases', () {
    test(
      'adding a repository saves, opens, and selects the normalized repo',
      () async {
        final _InMemoryWorkspaceSessionRepository sessionRepository =
            _InMemoryWorkspaceSessionRepository();
        const SavedRepository repository = SavedRepository(
          rootPath: '/projects/git_pilot',
          displayName: 'git_pilot',
        );
        final _FakeGitRepositoryExplorer explorer = _FakeGitRepositoryExplorer(
          resolvedRepositoriesByInputPath: const <String, SavedRepository>{
            '/projects/git_pilot/packages/presentation': repository,
          },
        );

        final AddLocalRepository addLocalRepository = AddLocalRepository(
          sessionRepository,
          explorer,
        );

        final Result<WorkspaceSession> result = await addLocalRepository(
          '/projects/git_pilot/packages/presentation',
        );

        expect(result, isA<Success<WorkspaceSession>>());

        final WorkspaceSession session =
            (result as Success<WorkspaceSession>).data;

        expect(session.savedRepositories, const <SavedRepository>[repository]);
        expect(session.openRepositoryIds, <String>[repository.id]);
        expect(session.selectedRepositoryId, repository.id);
      },
    );

    test(
      'closing the selected tab falls back to the remaining open tab',
      () async {
        const SavedRepository firstRepository = SavedRepository(
          rootPath: '/repos/alpha',
          displayName: 'alpha',
        );
        const SavedRepository secondRepository = SavedRepository(
          rootPath: '/repos/beta',
          displayName: 'beta',
        );
        final _InMemoryWorkspaceSessionRepository sessionRepository =
            _InMemoryWorkspaceSessionRepository(
              session: WorkspaceSession(
                savedRepositories: <SavedRepository>[
                  firstRepository,
                  secondRepository,
                ],
                openRepositoryIds: <String>[
                  firstRepository.id,
                  secondRepository.id,
                ],
                selectedRepositoryId: secondRepository.id,
              ),
            );

        final CloseRepositoryTab closeRepositoryTab = CloseRepositoryTab(
          sessionRepository,
        );

        final Result<WorkspaceSession> result = await closeRepositoryTab(
          secondRepository.id,
        );

        expect(result, isA<Success<WorkspaceSession>>());

        final WorkspaceSession session =
            (result as Success<WorkspaceSession>).data;

        expect(session.openRepositoryIds, <String>[firstRepository.id]);
        expect(session.selectedRepositoryId, firstRepository.id);
      },
    );
  });
}

final class _InMemoryWorkspaceSessionRepository
    implements WorkspaceSessionRepository {
  _InMemoryWorkspaceSessionRepository({WorkspaceSession? session})
    : _session = session ?? const WorkspaceSession.empty();

  WorkspaceSession _session;

  @override
  Future<Result<WorkspaceSession>> loadSession() async {
    return Success<WorkspaceSession>(_session);
  }

  @override
  Future<Result<WorkspaceSession>> saveSession(WorkspaceSession session) async {
    _session = session;
    return Success<WorkspaceSession>(_session);
  }
}

final class _FakeGitRepositoryExplorer implements GitRepositoryExplorer {
  _FakeGitRepositoryExplorer({
    this.resolvedRepositoriesByInputPath = const <String, SavedRepository>{},
  });

  final Map<String, SavedRepository> resolvedRepositoriesByInputPath;

  @override
  Future<Result<List<RemoteBranchRef>>> loadRemoteBranches(
    SavedRepository repository,
  ) async {
    return const Success<List<RemoteBranchRef>>(<RemoteBranchRef>[]);
  }

  @override
  Future<Result<SavedRepository>> resolveRepository(String selectedPath) async {
    final SavedRepository? repository =
        resolvedRepositoriesByInputPath[selectedPath];

    if (repository == null) {
      return const FailureResult<SavedRepository>(
        ValidationFailure('Repository not found.'),
      );
    }

    return Success<SavedRepository>(repository);
  }

  @override
  Future<Result<List<RepositoryTreeNode>>> loadTreeNodes(
    SavedRepository repository, {
    String? relativePath,
  }) async {
    return const Success<List<RepositoryTreeNode>>(<RepositoryTreeNode>[]);
  }
}
