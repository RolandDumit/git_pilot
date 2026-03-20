import 'package:git_pilot_core/git_pilot_core.dart';

import '../entities/workspace_session.dart';
import '../repositories/workspace_session_repository.dart';

final class OpenRepositoryTab {
  const OpenRepositoryTab(this._workspaceSessionRepository);

  final WorkspaceSessionRepository _workspaceSessionRepository;

  Future<Result<WorkspaceSession>> call(String repositoryId) async {
    final Result<WorkspaceSession> sessionResult =
        await _workspaceSessionRepository.loadSession();

    if (sessionResult is FailureResult<WorkspaceSession>) {
      return sessionResult;
    }

    final WorkspaceSession session =
        (sessionResult as Success<WorkspaceSession>).data;

    return _workspaceSessionRepository.saveSession(
      session.openRepository(repositoryId),
    );
  }
}
