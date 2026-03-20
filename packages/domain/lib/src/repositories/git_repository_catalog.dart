import 'package:git_pilot_core/git_pilot_core.dart';

import '../entities/git_repository_summary.dart';

abstract interface class GitRepositoryCatalog {
  Future<Result<List<GitRepositorySummary>>> loadRepositories();
}
