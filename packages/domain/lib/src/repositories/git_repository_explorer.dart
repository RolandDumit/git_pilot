import 'package:git_pilot_core/git_pilot_core.dart';

import '../entities/remote_branch_ref.dart';
import '../entities/repository_tree_node.dart';
import '../entities/saved_repository.dart';

abstract interface class GitRepositoryExplorer {
  Future<Result<SavedRepository>> resolveRepository(String selectedPath);

  Future<Result<List<RemoteBranchRef>>> loadRemoteBranches(
    SavedRepository repository,
  );

  Future<Result<List<RepositoryTreeNode>>> loadTreeNodes(
    SavedRepository repository, {
    String? relativePath,
  });
}
