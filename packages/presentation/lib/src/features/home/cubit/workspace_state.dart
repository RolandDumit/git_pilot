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
    this.currentLocalBranchName,
    this.selectedRemoteBranchName,
    this.recentCommits = const <CommitSummary>[],
    this.errorMessage,
  });

  final RepositoryTabStatus status;
  final List<RemoteBranchRef> remoteBranches;
  final String? currentLocalBranchName;
  final String? selectedRemoteBranchName;
  final List<CommitSummary> recentCommits;
  final String? errorMessage;

  bool get isLoading => status == RepositoryTabStatus.loading;
  bool get hasError => status == RepositoryTabStatus.failure;

  RepositoryTabState copyWith({
    RepositoryTabStatus? status,
    List<RemoteBranchRef>? remoteBranches,
    Object? currentLocalBranchName = _workspaceStateSentinel,
    Object? selectedRemoteBranchName = _workspaceStateSentinel,
    List<CommitSummary>? recentCommits,
    Object? errorMessage = _workspaceStateSentinel,
  }) {
    return RepositoryTabState(
      status: status ?? this.status,
      remoteBranches: remoteBranches ?? this.remoteBranches,
      currentLocalBranchName:
          identical(currentLocalBranchName, _workspaceStateSentinel)
          ? this.currentLocalBranchName
          : currentLocalBranchName as String?,
      selectedRemoteBranchName:
          identical(selectedRemoteBranchName, _workspaceStateSentinel)
          ? this.selectedRemoteBranchName
          : selectedRemoteBranchName as String?,
      recentCommits: recentCommits ?? this.recentCommits,
      errorMessage: identical(errorMessage, _workspaceStateSentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
