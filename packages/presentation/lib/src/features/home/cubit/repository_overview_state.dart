part of 'repository_overview_cubit.dart';

enum RepositoryOverviewStatus { initial, loading, success, failure }

class RepositoryOverviewState {
  const RepositoryOverviewState({
    this.status = RepositoryOverviewStatus.initial,
    this.repositories = const <GitRepositorySummary>[],
    this.errorMessage,
  });

  final RepositoryOverviewStatus status;
  final List<GitRepositorySummary> repositories;
  final String? errorMessage;

  bool get isLoading => status == RepositoryOverviewStatus.loading;
  bool get hasError => status == RepositoryOverviewStatus.failure;
  bool get isEmpty => repositories.isEmpty;

  RepositoryOverviewState copyWith({
    RepositoryOverviewStatus? status,
    List<GitRepositorySummary>? repositories,
    String? errorMessage,
  }) {
    return RepositoryOverviewState(
      status: status ?? this.status,
      repositories: repositories ?? this.repositories,
      errorMessage: errorMessage,
    );
  }
}
