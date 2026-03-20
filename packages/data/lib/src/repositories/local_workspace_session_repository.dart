import 'package:git_pilot_domain/git_pilot_domain.dart';

import '../datasources/workspace_session_local_data_source.dart';

final class LocalWorkspaceSessionRepository
    implements WorkspaceSessionRepository {
  const LocalWorkspaceSessionRepository({
    required WorkspaceSessionLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final WorkspaceSessionLocalDataSource _localDataSource;

  @override
  Future<Result<WorkspaceSession>> loadSession() async {
    try {
      final WorkspaceSession session = await _localDataSource.readSession();
      return Success<WorkspaceSession>(session);
    } on FormatException catch (error) {
      return FailureResult<WorkspaceSession>(StorageFailure(error.message));
    } on Object catch (error) {
      return FailureResult<WorkspaceSession>(
        StorageFailure('Unable to load the workspace session: $error'),
      );
    }
  }

  @override
  Future<Result<WorkspaceSession>> saveSession(WorkspaceSession session) async {
    try {
      final WorkspaceSession storedSession = await _localDataSource
          .writeSession(session);
      return Success<WorkspaceSession>(storedSession);
    } on Object catch (error) {
      return FailureResult<WorkspaceSession>(
        StorageFailure('Unable to save the workspace session: $error'),
      );
    }
  }
}
