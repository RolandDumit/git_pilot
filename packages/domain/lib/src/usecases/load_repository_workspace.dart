import 'package:git_pilot_core/git_pilot_core.dart';

import '../entities/remote_branch_ref.dart';
import '../entities/repository_tree_node.dart';
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

    final Result<List<RepositoryTreeNode>> treeResult =
        await _gitRepositoryExplorer.loadTreeNodes(repository);

    if (treeResult is FailureResult<List<RepositoryTreeNode>>) {
      return FailureResult<RepositoryWorkspaceSnapshot>(treeResult.failure);
    }

    return Success<RepositoryWorkspaceSnapshot>(
      RepositoryWorkspaceSnapshot(
        repository: repository,
        remoteBranches: (branchesResult as Success<List<RemoteBranchRef>>).data,
        rootNodes: (treeResult as Success<List<RepositoryTreeNode>>).data,
      ),
    );
  }
}
