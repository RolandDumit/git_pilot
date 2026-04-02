import 'package:git_pilot_core/git_pilot_core.dart';

import '../entities/commit_summary.dart';
import '../entities/current_branch_context.dart';
import '../entities/remote_branch_ref.dart';
import '../entities/repository_workspace_snapshot.dart';
import '../entities/saved_repository.dart';
import '../repositories/git_repository_explorer.dart';

final class LoadRepositoryWorkspace {
  const LoadRepositoryWorkspace(this._gitRepositoryExplorer);

  final GitRepositoryExplorer _gitRepositoryExplorer;

  Future<Result<RepositoryWorkspaceSnapshot>> call(
    SavedRepository repository,
  ) async {
    final Result<List<RemoteBranchRef>> branchesResult =
        await _gitRepositoryExplorer.loadRemoteBranches(repository);

    if (branchesResult is FailureResult<List<RemoteBranchRef>>) {
      return FailureResult<RepositoryWorkspaceSnapshot>(branchesResult.failure);
    }

    final Result<CurrentBranchContext> branchContextResult =
        await _gitRepositoryExplorer.loadCurrentBranchContext(repository);

    if (branchContextResult is FailureResult<CurrentBranchContext>) {
      return FailureResult<RepositoryWorkspaceSnapshot>(
        branchContextResult.failure,
      );
    }

    final Result<List<CommitSummary>> commitsResult =
        await _gitRepositoryExplorer.loadRecentCommits(repository);

    if (commitsResult is FailureResult<List<CommitSummary>>) {
      return FailureResult<RepositoryWorkspaceSnapshot>(commitsResult.failure);
    }

    final List<RemoteBranchRef> remoteBranches =
        (branchesResult as Success<List<RemoteBranchRef>>).data;
    final CurrentBranchContext branchContext =
        (branchContextResult as Success<CurrentBranchContext>).data;

    return Success<RepositoryWorkspaceSnapshot>(
      RepositoryWorkspaceSnapshot(
        repository: repository,
        remoteBranches: remoteBranches,
        currentBranchContext: branchContext,
        selectedRemoteBranchName: _resolveSelectedRemoteBranchName(
          remoteBranches,
          branchContext,
        ),
        recentCommits: (commitsResult as Success<List<CommitSummary>>).data,
      ),
    );
  }

  String? _resolveSelectedRemoteBranchName(
    List<RemoteBranchRef> remoteBranches,
    CurrentBranchContext branchContext,
  ) {
    final String? upstreamBranchName = branchContext.upstreamBranchName;

    if (upstreamBranchName != null &&
        remoteBranches.any(
          (RemoteBranchRef branch) => branch.name == upstreamBranchName,
        )) {
      return upstreamBranchName;
    }

    final String? localBranchName = branchContext.localBranchName;
    if (localBranchName == null || localBranchName.isEmpty) {
      return null;
    }

    final String originBranchName = 'origin/$localBranchName';
    if (remoteBranches.any(
      (RemoteBranchRef branch) => branch.name == originBranchName,
    )) {
      return originBranchName;
    }

    for (final RemoteBranchRef branch in remoteBranches) {
      if (branch.name.endsWith('/$localBranchName')) {
        return branch.name;
      }
    }

    return null;
  }
}
