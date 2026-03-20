import 'package:git_pilot_core/git_pilot_core.dart';

import '../entities/repository_tree_node.dart';
import '../entities/saved_repository.dart';
import '../repositories/git_repository_explorer.dart';

final class LoadRepositoryTreeChildren {
  const LoadRepositoryTreeChildren(this._gitRepositoryExplorer);

  final GitRepositoryExplorer _gitRepositoryExplorer;

  Future<Result<List<RepositoryTreeNode>>> call(
    SavedRepository repository, {
    required String relativePath,
  }) {
    return _gitRepositoryExplorer.loadTreeNodes(
      repository,
      relativePath: relativePath,
    );
  }
}
