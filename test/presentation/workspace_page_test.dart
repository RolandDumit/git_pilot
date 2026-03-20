import 'package:flutter_test/flutter_test.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/git_pilot_presentation.dart';

void main() {
  group('GitPilotApp workspace modes', () {
    testWidgets('fresh launch shows the onboarding empty state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          sessionRepository: _InMemoryWorkspaceSessionRepository(),
          explorer: _FakeGitRepositoryExplorer(),
          picker: _FakeLocalRepositoryPicker(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Open your first local repository'), findsOneWidget);
      expect(find.text('Open local repository'), findsOneWidget);
    });

    testWidgets(
      'saved repos with no open tabs shows the selector above the open button',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildApp(
            sessionRepository: _InMemoryWorkspaceSessionRepository(
              session: const WorkspaceSession(
                savedRepositories: <SavedRepository>[
                  SavedRepository(
                    rootPath: '/repos/git_pilot',
                    displayName: 'git_pilot',
                  ),
                ],
              ),
            ),
            explorer: _FakeGitRepositoryExplorer(),
            picker: _FakeLocalRepositoryPicker(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Saved repositories'), findsOneWidget);
        expect(
          find.text('Choose a saved repository or open a new one'),
          findsOneWidget,
        );
      },
    );

    testWidgets('restored open tabs show the tabbed workspace and split view', (
      WidgetTester tester,
    ) async {
      const SavedRepository repository = SavedRepository(
        rootPath: '/repos/git_pilot',
        displayName: 'git_pilot',
      );

      await tester.pumpWidget(
        _buildApp(
          sessionRepository: _InMemoryWorkspaceSessionRepository(
            session: WorkspaceSession(
              savedRepositories: <SavedRepository>[repository],
              openRepositoryIds: <String>[repository.id],
              selectedRepositoryId: repository.id,
            ),
          ),
          explorer: _FakeGitRepositoryExplorer(resolvedRepository: repository),
          picker: _FakeLocalRepositoryPicker(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Remote branches'), findsOneWidget);
      expect(find.text('origin/main'), findsOneWidget);
      expect(find.textContaining('Git tree'), findsOneWidget);
      expect(find.text('lib'), findsOneWidget);
    });
  });
}

GitPilotApp _buildApp({
  required _InMemoryWorkspaceSessionRepository sessionRepository,
  required _FakeGitRepositoryExplorer explorer,
  required _FakeLocalRepositoryPicker picker,
}) {
  return GitPilotApp(
    loadWorkspaceSession: LoadWorkspaceSession(sessionRepository),
    addLocalRepository: AddLocalRepository(sessionRepository, explorer),
    openRepositoryTab: OpenRepositoryTab(sessionRepository),
    closeRepositoryTab: CloseRepositoryTab(sessionRepository),
    selectRepositoryTab: SelectRepositoryTab(sessionRepository),
    loadRepositoryWorkspace: LoadRepositoryWorkspace(explorer),
    loadRepositoryTreeChildren: LoadRepositoryTreeChildren(explorer),
    localRepositoryPicker: picker,
  );
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
  _FakeGitRepositoryExplorer({this.resolvedRepository});

  final SavedRepository? resolvedRepository;

  @override
  Future<Result<List<RemoteBranchRef>>> loadRemoteBranches(
    SavedRepository repository,
  ) async {
    return const Success<List<RemoteBranchRef>>(<RemoteBranchRef>[
      RemoteBranchRef(name: 'origin/main'),
      RemoteBranchRef(name: 'origin/release'),
    ]);
  }

  @override
  Future<Result<SavedRepository>> resolveRepository(String selectedPath) async {
    return Success<SavedRepository>(
      resolvedRepository ??
          const SavedRepository(
            rootPath: '/repos/git_pilot',
            displayName: 'git_pilot',
          ),
    );
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
  @override
  Future<String?> pickDirectory() async {
    return null;
  }
}
