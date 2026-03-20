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
          loadRepositoryTreeChildren: LoadRepositoryTreeChildren(explorer),
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
          loadRepositoryTreeChildren: LoadRepositoryTreeChildren(explorer),
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
  _FakeGitRepositoryExplorer({this.resolvedRepository, this.resolutionFailure});

  final SavedRepository? resolvedRepository;
  final Failure? resolutionFailure;

  @override
  Future<Result<List<RemoteBranchRef>>> loadRemoteBranches(
    SavedRepository repository,
  ) async {
    return const Success<List<RemoteBranchRef>>(<RemoteBranchRef>[
      RemoteBranchRef(name: 'origin/main'),
    ]);
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
    if (relativePath == null) {
      return const Success<List<RepositoryTreeNode>>(<RepositoryTreeNode>[
        RepositoryTreeNode(
          name: 'lib',
          relativePath: 'lib',
          isDirectory: true,
          hasChildren: true,
        ),
      ]);
    }

    return const Success<List<RepositoryTreeNode>>(<RepositoryTreeNode>[
      RepositoryTreeNode(
        name: 'main.dart',
        relativePath: 'lib/main.dart',
        isDirectory: false,
        hasChildren: false,
      ),
    ]);
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
