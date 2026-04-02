import 'commit_summary.dart';
import 'current_branch_context.dart';
import 'remote_branch_ref.dart';
import 'saved_repository.dart';

final class RepositoryWorkspaceSnapshot {
  const RepositoryWorkspaceSnapshot({
    required this.repository,
    required this.remoteBranches,
    required this.currentBranchContext,
    required this.selectedRemoteBranchName,
    required this.recentCommits,
  });

  final SavedRepository repository;
  final List<RemoteBranchRef> remoteBranches;
  final CurrentBranchContext currentBranchContext;
  final String? selectedRemoteBranchName;
  final List<CommitSummary> recentCommits;
}
