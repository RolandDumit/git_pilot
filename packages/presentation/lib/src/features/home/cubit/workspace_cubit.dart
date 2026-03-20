import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';

import '../../../services/local_repository_picker.dart';

part 'workspace_state.dart';

class WorkspaceCubit extends Cubit<WorkspaceState> {
  WorkspaceCubit({
    required LoadWorkspaceSession loadWorkspaceSession,
    required AddLocalRepository addLocalRepository,
    required OpenRepositoryTab openRepositoryTab,
    required CloseRepositoryTab closeRepositoryTab,
    required SelectRepositoryTab selectRepositoryTab,
    required LoadRepositoryWorkspace loadRepositoryWorkspace,
    required LoadRepositoryTreeChildren loadRepositoryTreeChildren,
    required LocalRepositoryPicker localRepositoryPicker,
  }) : _loadWorkspaceSession = loadWorkspaceSession,
       _addLocalRepository = addLocalRepository,
       _openRepositoryTab = openRepositoryTab,
       _closeRepositoryTab = closeRepositoryTab,
       _selectRepositoryTab = selectRepositoryTab,
       _loadRepositoryWorkspace = loadRepositoryWorkspace,
       _loadRepositoryTreeChildren = loadRepositoryTreeChildren,
       _localRepositoryPicker = localRepositoryPicker,
       super(const WorkspaceState());

  final LoadWorkspaceSession _loadWorkspaceSession;
  final AddLocalRepository _addLocalRepository;
  final OpenRepositoryTab _openRepositoryTab;
  final CloseRepositoryTab _closeRepositoryTab;
  final SelectRepositoryTab _selectRepositoryTab;
  final LoadRepositoryWorkspace _loadRepositoryWorkspace;
  final LoadRepositoryTreeChildren _loadRepositoryTreeChildren;
  final LocalRepositoryPicker _localRepositoryPicker;

  Future<void> initialize() async {
    emit(
      state.copyWith(
        mode: WorkspaceViewMode.loading,
        message: null,
        failureMessage: null,
      ),
    );

    final Result<WorkspaceSession> sessionResult =
        await _loadWorkspaceSession();

    if (sessionResult is FailureResult<WorkspaceSession>) {
      emit(
        state.copyWith(
          mode: WorkspaceViewMode.failure,
          failureMessage: sessionResult.failure.message,
        ),
      );
      return;
    }

    final WorkspaceSession session =
        (sessionResult as Success<WorkspaceSession>).data;

    emit(
      state.copyWith(
        mode: _modeForSession(session),
        session: session,
        message: null,
        failureMessage: null,
      ),
    );

    await _loadSelectedWorkspaceIfNeeded();
  }

  Future<void> openLocalRepository() async {
    emit(state.copyWith(isPickingRepository: true));

    final String? selectedPath = await _localRepositoryPicker.pickDirectory();

    emit(state.copyWith(isPickingRepository: false));

    if (selectedPath == null) {
      return;
    }

    final Result<WorkspaceSession> sessionResult = await _addLocalRepository(
      selectedPath,
    );

    await _handleSessionMutationResult(sessionResult);
  }

  Future<void> openSavedRepository(String repositoryId) async {
    final Result<WorkspaceSession> sessionResult = await _openRepositoryTab(
      repositoryId,
    );

    await _handleSessionMutationResult(sessionResult);
  }

  Future<void> selectRepository(String repositoryId) async {
    if (state.session.selectedRepositoryId == repositoryId) {
      return;
    }

    final Result<WorkspaceSession> sessionResult = await _selectRepositoryTab(
      repositoryId,
    );

    await _handleSessionMutationResult(sessionResult);
  }

  Future<void> closeRepository(String repositoryId) async {
    final Result<WorkspaceSession> sessionResult = await _closeRepositoryTab(
      repositoryId,
    );

    await _handleSessionMutationResult(sessionResult);
  }

  Future<void> toggleDirectory(RepositoryTreeNode node) async {
    final SavedRepository? selectedRepository = state.selectedRepository;

    if (selectedRepository == null || !node.isDirectory || !node.hasChildren) {
      return;
    }

    final RepositoryTabState tabState =
        state.selectedTabState ??
        const RepositoryTabState(status: RepositoryTabStatus.initial);

    if (tabState.expandedDirectoryPaths.contains(node.relativePath)) {
      emit(
        state.copyWith(
          tabsByRepositoryId: _updatedTabState(
            selectedRepository.id,
            tabState.copyWith(
              expandedDirectoryPaths: tabState.expandedDirectoryPaths
                  .where((String path) => path != node.relativePath)
                  .toList(growable: false),
            ),
          ),
        ),
      );
      return;
    }

    if (tabState.childNodesByParentPath.containsKey(node.relativePath)) {
      emit(
        state.copyWith(
          tabsByRepositoryId: _updatedTabState(
            selectedRepository.id,
            tabState.copyWith(
              expandedDirectoryPaths: <String>[
                ...tabState.expandedDirectoryPaths,
                node.relativePath,
              ],
            ),
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        tabsByRepositoryId: _updatedTabState(
          selectedRepository.id,
          tabState.copyWith(
            loadingDirectoryPaths: <String>[
              ...tabState.loadingDirectoryPaths,
              node.relativePath,
            ],
          ),
        ),
      ),
    );

    final Result<List<RepositoryTreeNode>> treeChildrenResult =
        await _loadRepositoryTreeChildren(
          selectedRepository,
          relativePath: node.relativePath,
        );

    final RepositoryTabState latestTabState =
        state.tabsByRepositoryId[selectedRepository.id] ?? tabState;

    if (treeChildrenResult is FailureResult<List<RepositoryTreeNode>>) {
      emit(
        state.copyWith(
          message: WorkspaceMessage(
            text: treeChildrenResult.failure.message,
            kind: WorkspaceMessageKind.error,
          ),
          tabsByRepositoryId: _updatedTabState(
            selectedRepository.id,
            latestTabState.copyWith(
              loadingDirectoryPaths: latestTabState.loadingDirectoryPaths
                  .where((String path) => path != node.relativePath)
                  .toList(growable: false),
              errorMessage: treeChildrenResult.failure.message,
            ),
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        tabsByRepositoryId: _updatedTabState(
          selectedRepository.id,
          latestTabState.copyWith(
            loadingDirectoryPaths: latestTabState.loadingDirectoryPaths
                .where((String path) => path != node.relativePath)
                .toList(growable: false),
            expandedDirectoryPaths: <String>[
              ...latestTabState.expandedDirectoryPaths,
              node.relativePath,
            ],
            childNodesByParentPath: <String, List<RepositoryTreeNode>>{
              ...latestTabState.childNodesByParentPath,
              node.relativePath:
                  (treeChildrenResult as Success<List<RepositoryTreeNode>>)
                      .data,
            },
            errorMessage: null,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSessionMutationResult(
    Result<WorkspaceSession> sessionResult,
  ) async {
    if (sessionResult is FailureResult<WorkspaceSession>) {
      emit(
        state.copyWith(
          message: WorkspaceMessage(
            text: sessionResult.failure.message,
            kind: WorkspaceMessageKind.error,
          ),
        ),
      );
      return;
    }

    final WorkspaceSession session =
        (sessionResult as Success<WorkspaceSession>).data;

    emit(
      state.copyWith(
        mode: _modeForSession(session),
        session: session,
        message: null,
        failureMessage: null,
      ),
    );

    await _loadSelectedWorkspaceIfNeeded();
  }

  Future<void> _loadSelectedWorkspaceIfNeeded() async {
    final SavedRepository? repository = state.selectedRepository;

    if (repository == null) {
      return;
    }

    final RepositoryTabState currentTabState =
        state.tabsByRepositoryId[repository.id] ?? const RepositoryTabState();

    if (currentTabState.status == RepositoryTabStatus.success) {
      return;
    }

    emit(
      state.copyWith(
        tabsByRepositoryId: _updatedTabState(
          repository.id,
          currentTabState.copyWith(
            status: RepositoryTabStatus.loading,
            errorMessage: null,
          ),
        ),
      ),
    );

    final Result<RepositoryWorkspaceSnapshot> workspaceResult =
        await _loadRepositoryWorkspace(repository);

    if (workspaceResult is FailureResult<RepositoryWorkspaceSnapshot>) {
      emit(
        state.copyWith(
          message: WorkspaceMessage(
            text: workspaceResult.failure.message,
            kind: WorkspaceMessageKind.error,
          ),
          tabsByRepositoryId: _updatedTabState(
            repository.id,
            currentTabState.copyWith(
              status: RepositoryTabStatus.failure,
              errorMessage: workspaceResult.failure.message,
            ),
          ),
        ),
      );
      return;
    }

    final RepositoryWorkspaceSnapshot snapshot =
        (workspaceResult as Success<RepositoryWorkspaceSnapshot>).data;

    emit(
      state.copyWith(
        tabsByRepositoryId: _updatedTabState(
          repository.id,
          RepositoryTabState(
            status: RepositoryTabStatus.success,
            remoteBranches: snapshot.remoteBranches,
            rootNodes: snapshot.rootNodes,
          ),
        ),
      ),
    );
  }

  WorkspaceViewMode _modeForSession(WorkspaceSession session) {
    if (!session.hasSavedRepositories) {
      return WorkspaceViewMode.emptyOnboarding;
    }

    if (!session.hasOpenRepositories) {
      return WorkspaceViewMode.selector;
    }

    return WorkspaceViewMode.workspace;
  }

  Map<String, RepositoryTabState> _updatedTabState(
    String repositoryId,
    RepositoryTabState nextTabState,
  ) {
    return <String, RepositoryTabState>{
      ...state.tabsByRepositoryId,
      repositoryId: nextTabState,
    };
  }
}
