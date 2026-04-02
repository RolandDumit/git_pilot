import 'package:flutter_test/flutter_test.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/git_pilot_presentation.dart';

void main() {
  group('WorkspaceCubit', () {
    test(
      'opening an already saved repository focuses the existing tab instead of duplicating it',
      () async {
        const SavedRepository repository = SavedRepository(
          rootPath: '/repos/git_pilot',
          displayName: 'git_pilot',
        );
        final _InMemoryWorkspaceSessionRepository sessionRepository =
            _InMemoryWorkspaceSessionRepository(
              session: WorkspaceSession(
                savedRepositories: <SavedRepository>[repository],
                openRepositoryIds: <String>[repository.id],
                selectedRepositoryId: repository.id,
              ),
            );
        final _FakeGitRepositoryExplorer explorer = _FakeGitRepositoryExplorer(
          resolvedRepository: repository,
        );
        final WorkspaceCubit cubit = WorkspaceCubit(
          loadWorkspaceSession: LoadWorkspaceSession(sessionRepository),
          addLocalRepository: AddLocalRepository(sessionRepository, explorer),
          openRepositoryTab: OpenRepositoryTab(sessionRepository),
          closeRepositoryTab: CloseRepositoryTab(sessionRepository),
          selectRepositoryTab: SelectRepositoryTab(sessionRepository),
          loadRepositoryWorkspace: LoadRepositoryWorkspace(explorer),
          localRepositoryPicker: _FakeLocalRepositoryPicker(
            selectedPaths: <String>[repository.id],
          ),
        );

        await cubit.initialize();
        await cubit.openLocalRepository();

        expect(cubit.state.session.savedRepositories.length, 1);
        expect(cubit.state.session.openRepositoryIds, <String>[repository.id]);
        expect(cubit.state.session.selectedRepositoryId, repository.id);
      },
    );

    test(
      'invalid repository selection shows an error without mutating the saved session',
      () async {
        final _InMemoryWorkspaceSessionRepository sessionRepository =
            _InMemoryWorkspaceSessionRepository();
        final _FakeGitRepositoryExplorer explorer = _FakeGitRepositoryExplorer(
          resolutionFailure: const ValidationFailure(
            'The selected folder is not a Git repository.',
          ),
        );
        final WorkspaceCubit cubit = WorkspaceCubit(
          loadWorkspaceSession: LoadWorkspaceSession(sessionRepository),
          addLocalRepository: AddLocalRepository(sessionRepository, explorer),
          openRepositoryTab: OpenRepositoryTab(sessionRepository),
          closeRepositoryTab: CloseRepositoryTab(sessionRepository),
          selectRepositoryTab: SelectRepositoryTab(sessionRepository),
          loadRepositoryWorkspace: LoadRepositoryWorkspace(explorer),
          localRepositoryPicker: _FakeLocalRepositoryPicker(
            selectedPaths: <String>['/invalid/repo'],
          ),
        );

        await cubit.initialize();
        await cubit.openLocalRepository();

        expect(cubit.state.session, const WorkspaceSession.empty());
        expect(
          cubit.state.message?.text,
          'The selected folder is not a Git repository.',
        );
        expect(cubit.state.mode, WorkspaceViewMode.emptyOnboarding);
      },
    );

    test(
      'initialization seeds the selected remote branch and allows manual selection',
      () async {
        const SavedRepository repository = SavedRepository(
          rootPath: '/repos/git_pilot',
          displayName: 'git_pilot',
        );
        final _InMemoryWorkspaceSessionRepository sessionRepository =
            _InMemoryWorkspaceSessionRepository(
              session: WorkspaceSession(
                savedRepositories: <SavedRepository>[repository],
                openRepositoryIds: <String>[repository.id],
                selectedRepositoryId: repository.id,
              ),
            );
        final _FakeGitRepositoryExplorer explorer = _FakeGitRepositoryExplorer(
          resolvedRepository: repository,
          currentBranchContext: const CurrentBranchContext(
            localBranchName: 'main',
            upstreamBranchName: 'origin/main',
          ),
          remoteBranches: const <RemoteBranchRef>[
            RemoteBranchRef(name: 'origin/main'),
            RemoteBranchRef(name: 'origin/release'),
          ],
        );
        final WorkspaceCubit cubit = WorkspaceCubit(
          loadWorkspaceSession: LoadWorkspaceSession(sessionRepository),
          addLocalRepository: AddLocalRepository(sessionRepository, explorer),
          openRepositoryTab: OpenRepositoryTab(sessionRepository),
          closeRepositoryTab: CloseRepositoryTab(sessionRepository),
          selectRepositoryTab: SelectRepositoryTab(sessionRepository),
          loadRepositoryWorkspace: LoadRepositoryWorkspace(explorer),
          localRepositoryPicker: _FakeLocalRepositoryPicker(
            selectedPaths: const <String>[],
          ),
        );

        await cubit.initialize();

        expect(
          cubit.state.selectedTabState?.selectedRemoteBranchName,
          'origin/main',
        );

        cubit.selectRemoteBranch('origin/release');

        expect(
          cubit.state.selectedTabState?.selectedRemoteBranchName,
          'origin/release',
        );
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
    this.resolvedRepository,
    this.resolutionFailure,
    this.currentBranchContext = const CurrentBranchContext(
      localBranchName: 'main',
      upstreamBranchName: 'origin/main',
    ),
    this.remoteBranches = const <RemoteBranchRef>[
      RemoteBranchRef(name: 'origin/main'),
    ],
    List<CommitSummary>? recentCommits,
  }) : recentCommits =
           recentCommits ??
           <CommitSummary>[
             CommitSummary(
               hash: 'abcdef1234567890',
               authorName: 'Ada Lovelace',
               committedAt: DateTime.utc(2026, 4, 1, 10, 30),
               subject: 'Initial commit',
             ),
           ];

  final SavedRepository? resolvedRepository;
  final Failure? resolutionFailure;
  final CurrentBranchContext currentBranchContext;
  final List<RemoteBranchRef> remoteBranches;
  final List<CommitSummary> recentCommits;

  @override
  Future<Result<List<RemoteBranchRef>>> loadRemoteBranches(
    SavedRepository repository,
  ) async {
    return Success<List<RemoteBranchRef>>(remoteBranches);
  }

  @override
  Future<Result<CurrentBranchContext>> loadCurrentBranchContext(
    SavedRepository repository,
  ) async {
    return Success<CurrentBranchContext>(currentBranchContext);
  }

  @override
  Future<Result<List<CommitSummary>>> loadRecentCommits(
    SavedRepository repository, {
    int limit = 50,
  }) async {
    return Success<List<CommitSummary>>(recentCommits);
  }

  @override
  Future<Result<SavedRepository>> resolveRepository(String selectedPath) async {
    if (resolutionFailure != null) {
      return FailureResult<SavedRepository>(resolutionFailure!);
    }

    return Success<SavedRepository>(resolvedRepository!);
  }

  @override
  Future<Result<List<RepositoryTreeNode>>> loadTreeNodes(
    SavedRepository repository, {
    String? relativePath,
  }) async {
    return const Success<List<RepositoryTreeNode>>(<RepositoryTreeNode>[]);
  }
}

final class _FakeLocalRepositoryPicker implements LocalRepositoryPicker {
  _FakeLocalRepositoryPicker({required List<String> selectedPaths})
    : _selectedPaths = selectedPaths;

  final List<String> _selectedPaths;

  @override
  Future<String?> pickDirectory() async {
    if (_selectedPaths.isEmpty) {
      return null;
    }

    return _selectedPaths.removeAt(0);
  }
}
