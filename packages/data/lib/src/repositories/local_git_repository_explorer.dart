import 'package:git_pilot_domain/git_pilot_domain.dart';

import '../datasources/git_remote_branches_data_source.dart';
import '../datasources/git_repository_resolver_data_source.dart';
import '../datasources/repository_file_tree_data_source.dart';

final class LocalGitRepositoryExplorer implements GitRepositoryExplorer {
  const LocalGitRepositoryExplorer({
    required GitRepositoryResolverDataSource repositoryResolverDataSource,
    required GitRemoteBranchesDataSource remoteBranchesDataSource,
    required RepositoryFileTreeDataSource repositoryFileTreeDataSource,
  }) : _repositoryResolverDataSource = repositoryResolverDataSource,
       _remoteBranchesDataSource = remoteBranchesDataSource,
       _repositoryFileTreeDataSource = repositoryFileTreeDataSource;

  final GitRepositoryResolverDataSource _repositoryResolverDataSource;
  final GitRemoteBranchesDataSource _remoteBranchesDataSource;
  final RepositoryFileTreeDataSource _repositoryFileTreeDataSource;

  @override
  Future<Result<SavedRepository>> resolveRepository(String selectedPath) {
    return _repositoryResolverDataSource.resolveRepository(selectedPath);
  }

  @override
  Future<Result<List<RemoteBranchRef>>> loadRemoteBranches(
    SavedRepository repository,
  ) {
    return _remoteBranchesDataSource.loadRemoteBranches(repository);
  }

  @override
  Future<Result<List<RepositoryTreeNode>>> loadTreeNodes(
    SavedRepository repository, {
    String? relativePath,
  }) {
    return _repositoryFileTreeDataSource.loadTreeNodes(
      repository,
      relativePath: relativePath,
    );
  }
}
