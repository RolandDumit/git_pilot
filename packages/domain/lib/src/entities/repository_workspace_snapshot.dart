import 'remote_branch_ref.dart';
import 'repository_tree_node.dart';
import 'saved_repository.dart';

final class RepositoryWorkspaceSnapshot {
  const RepositoryWorkspaceSnapshot({
    required this.repository,
    required this.remoteBranches,
    required this.rootNodes,
  });

  final SavedRepository repository;
  final List<RemoteBranchRef> remoteBranches;
  final List<RepositoryTreeNode> rootNodes;
}
