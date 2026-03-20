import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';

part 'repository_overview_state.dart';

class RepositoryOverviewCubit extends Cubit<RepositoryOverviewState> {
  RepositoryOverviewCubit(this._loadRepositories)
    : super(const RepositoryOverviewState());

  final LoadRepositories _loadRepositories;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: RepositoryOverviewStatus.loading,
        errorMessage: null,
      ),
    );

    final Result<List<GitRepositorySummary>> result = await _loadRepositories();

    emit(
      result.map(
        success: (List<GitRepositorySummary> repositories) {
          return state.copyWith(
            status: RepositoryOverviewStatus.success,
            repositories: repositories,
            errorMessage: null,
          );
        },
        failure: (Failure failure) {
          return state.copyWith(
            status: RepositoryOverviewStatus.failure,
            errorMessage: failure.message,
          );
        },
      ),
    );
  }
}
