part of 'workspace_cubit.dart';

enum WorkspaceViewMode {
  loading,
  emptyOnboarding,
  selector,
  workspace,
  failure,
}

enum WorkspaceMessageKind { info, error }

enum RepositoryTabStatus { initial, loading, success, failure }

const Object _workspaceStateSentinel = Object();

class WorkspaceState {
  const WorkspaceState({
    this.mode = WorkspaceViewMode.loading,
    this.session = const WorkspaceSession.empty(),
    this.tabsByRepositoryId = const <String, RepositoryTabState>{},
    this.isPickingRepository = false,
    this.message,
    this.failureMessage,
  });

  final WorkspaceViewMode mode;
  final WorkspaceSession session;
  final Map<String, RepositoryTabState> tabsByRepositoryId;
  final bool isPickingRepository;
  final WorkspaceMessage? message;
  final String? failureMessage;

  SavedRepository? get selectedRepository {
    final String? repositoryId = session.selectedRepositoryId;

    if (repositoryId == null) {
      return null;
    }

    return session.repositoryById(repositoryId);
  }

  RepositoryTabState? get selectedTabState {
    final SavedRepository? repository = selectedRepository;

    if (repository == null) {
      return null;
    }

    return tabsByRepositoryId[repository.id];
  }

  WorkspaceState copyWith({
    WorkspaceViewMode? mode,
    WorkspaceSession? session,
    Map<String, RepositoryTabState>? tabsByRepositoryId,
    bool? isPickingRepository,
    Object? message = _workspaceStateSentinel,
    Object? failureMessage = _workspaceStateSentinel,
  }) {
    return WorkspaceState(
      mode: mode ?? this.mode,
      session: session ?? this.session,
      tabsByRepositoryId: tabsByRepositoryId ?? this.tabsByRepositoryId,
      isPickingRepository: isPickingRepository ?? this.isPickingRepository,
      message: identical(message, _workspaceStateSentinel)
          ? this.message
          : message as WorkspaceMessage?,
      failureMessage: identical(failureMessage, _workspaceStateSentinel)
          ? this.failureMessage
          : failureMessage as String?,
    );
  }
}

class WorkspaceMessage {
  const WorkspaceMessage({required this.text, required this.kind});

  final String text;
  final WorkspaceMessageKind kind;
}

class RepositoryTabState {
  const RepositoryTabState({
    this.status = RepositoryTabStatus.initial,
    this.remoteBranches = const <RemoteBranchRef>[],
    this.rootNodes = const <RepositoryTreeNode>[],
    this.childNodesByParentPath = const <String, List<RepositoryTreeNode>>{},
    this.expandedDirectoryPaths = const <String>[],
    this.loadingDirectoryPaths = const <String>[],
    this.errorMessage,
  });

  final RepositoryTabStatus status;
  final List<RemoteBranchRef> remoteBranches;
  final List<RepositoryTreeNode> rootNodes;
  final Map<String, List<RepositoryTreeNode>> childNodesByParentPath;
  final List<String> expandedDirectoryPaths;
  final List<String> loadingDirectoryPaths;
  final String? errorMessage;

  bool get isLoading => status == RepositoryTabStatus.loading;
  bool get hasError => status == RepositoryTabStatus.failure;

  RepositoryTabState copyWith({
    RepositoryTabStatus? status,
    List<RemoteBranchRef>? remoteBranches,
    List<RepositoryTreeNode>? rootNodes,
    Map<String, List<RepositoryTreeNode>>? childNodesByParentPath,
    List<String>? expandedDirectoryPaths,
    List<String>? loadingDirectoryPaths,
    Object? errorMessage = _workspaceStateSentinel,
  }) {
    return RepositoryTabState(
      status: status ?? this.status,
      remoteBranches: remoteBranches ?? this.remoteBranches,
      rootNodes: rootNodes ?? this.rootNodes,
      childNodesByParentPath:
          childNodesByParentPath ?? this.childNodesByParentPath,
      expandedDirectoryPaths:
          expandedDirectoryPaths ?? this.expandedDirectoryPaths,
      loadingDirectoryPaths:
          loadingDirectoryPaths ?? this.loadingDirectoryPaths,
      errorMessage: identical(errorMessage, _workspaceStateSentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
