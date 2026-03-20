import 'package:git_pilot_core/git_pilot_core.dart';

import '../entities/workspace_session.dart';
import '../repositories/workspace_session_repository.dart';

final class LoadWorkspaceSession {
  const LoadWorkspaceSession(this._workspaceSessionRepository);

  final WorkspaceSessionRepository _workspaceSessionRepository;

  Future<Result<WorkspaceSession>> call() {
    return _workspaceSessionRepository.loadSession();
  }
}
