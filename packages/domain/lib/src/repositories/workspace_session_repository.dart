import 'package:git_pilot_core/git_pilot_core.dart';

import '../entities/workspace_session.dart';

abstract interface class WorkspaceSessionRepository {
  Future<Result<WorkspaceSession>> loadSession();

  Future<Result<WorkspaceSession>> saveSession(WorkspaceSession session);
}
