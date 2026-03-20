import 'package:git_pilot_core/git_pilot_core.dart';

import '../entities/saved_repository.dart';
import '../entities/workspace_session.dart';
import '../repositories/git_repository_explorer.dart';
import '../repositories/workspace_session_repository.dart';

final class AddLocalRepository {
  const AddLocalRepository(
    this._workspaceSessionRepository,
    this._gitRepositoryExplorer,
  );

  final WorkspaceSessionRepository _workspaceSessionRepository;
  final GitRepositoryExplorer _gitRepositoryExplorer;

  Future<Result<WorkspaceSession>> call(String selectedPath) async {
    final Result<SavedRepository> repositoryResult =
        await _gitRepositoryExplorer.resolveRepository(selectedPath);

    if (repositoryResult is FailureResult<SavedRepository>) {
      return FailureResult<WorkspaceSession>(repositoryResult.failure);
    }

    final Result<WorkspaceSession> sessionResult =
        await _workspaceSessionRepository.loadSession();

    if (sessionResult is FailureResult<WorkspaceSession>) {
      return sessionResult;
    }

    final SavedRepository repository =
        (repositoryResult as Success<SavedRepository>).data;
    final WorkspaceSession session =
        (sessionResult as Success<WorkspaceSession>).data;

    return _workspaceSessionRepository.saveSession(
      session.addOrOpenRepository(repository),
    );
  }
}
