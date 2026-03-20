import 'package:git_pilot_core/git_pilot_core.dart';

import '../entities/git_repository_summary.dart';
import '../repositories/git_repository_catalog.dart';

final class LoadRepositories {
  const LoadRepositories(this._repositoryCatalog);

  final GitRepositoryCatalog _repositoryCatalog;

  Future<Result<List<GitRepositorySummary>>> call() {
    return _repositoryCatalog.loadRepositories();
  }
}
