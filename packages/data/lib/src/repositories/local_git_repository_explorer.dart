import 'package:git_pilot_domain/git_pilot_domain.dart';

import '../datasources/git_current_branch_data_source.dart';
import '../datasources/git_remote_branches_data_source.dart';
import '../datasources/git_recent_commits_data_source.dart';
import '../datasources/git_repository_resolver_data_source.dart';
import '../datasources/repository_file_tree_data_source.dart';

final class LocalGitRepositoryExplorer implements GitRepositoryExplorer {
  const LocalGitRepositoryExplorer({
    required GitRepositoryResolverDataSource repositoryResolverDataSource,
    required GitCurrentBranchDataSource currentBranchDataSource,
    required GitRemoteBranchesDataSource remoteBranchesDataSource,
    required GitRecentCommitsDataSource recentCommitsDataSource,
    required RepositoryFileTreeDataSource repositoryFileTreeDataSource,
  }) : _repositoryResolverDataSource = repositoryResolverDataSource,
       _currentBranchDataSource = currentBranchDataSource,
       _remoteBranchesDataSource = remoteBranchesDataSource,
       _recentCommitsDataSource = recentCommitsDataSource,
       _repositoryFileTreeDataSource = repositoryFileTreeDataSource;

  final GitRepositoryResolverDataSource _repositoryResolverDataSource;
  final GitCurrentBranchDataSource _currentBranchDataSource;
  final GitRemoteBranchesDataSource _remoteBranchesDataSource;
  final GitRecentCommitsDataSource _recentCommitsDataSource;
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
  Future<Result<CurrentBranchContext>> loadCurrentBranchContext(
    SavedRepository repository,
  ) {
    return _currentBranchDataSource.loadCurrentBranchContext(repository);
  }

  @override
  Future<Result<List<CommitSummary>>> loadRecentCommits(
    SavedRepository repository, {
    int limit = 50,
  }) {
    return _recentCommitsDataSource.loadRecentCommits(repository, limit: limit);
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
