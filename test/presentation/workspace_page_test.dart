import 'package:flutter/widgets.dart';
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

    testWidgets('restored open tabs show branches and recent commits', (
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
      expect(find.text('origin/main'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Recent commits'), findsOneWidget);
      expect(find.text('Initial commit'), findsOneWidget);
      expect(find.text('Checked out locally: main'), findsOneWidget);
    });

    testWidgets('tapping a branch updates the highlighted selection', (
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

      expect(_selectedTileTitles(tester), <String>['origin/main']);

      await tester.tap(find.text('origin/release'));
      await tester.pumpAndSettle();

      expect(_selectedTileTitles(tester), <String>['origin/release']);
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
  _FakeGitRepositoryExplorer({
    this.resolvedRepository,
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
  final List<CommitSummary> recentCommits;

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
  Future<Result<CurrentBranchContext>> loadCurrentBranchContext(
    SavedRepository repository,
  ) async {
    return const Success<CurrentBranchContext>(
      CurrentBranchContext(
        localBranchName: 'main',
        upstreamBranchName: 'origin/main',
      ),
    );
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
    return const Success<List<RepositoryTreeNode>>(<RepositoryTreeNode>[]);
  }
}

final class _FakeLocalRepositoryPicker implements LocalRepositoryPicker {
  @override
  Future<String?> pickDirectory() async {
    return null;
  }
}

List<String> _selectedTileTitles(WidgetTester tester) {
  return find
      .byWidgetPredicate((Widget widget) {
        if (widget.runtimeType.toString() != 'Tile') {
          return false;
        }

        final dynamic tile = widget;
        return tile.isSelected == true;
      })
      .evaluate()
      .map<String>((Element element) {
        final dynamic tile = element.widget;
        return tile.title as String;
      })
      .toList(growable: false);
}
