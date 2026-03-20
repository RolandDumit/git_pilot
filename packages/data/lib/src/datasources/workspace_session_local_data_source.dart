import 'dart:convert';
import 'dart:io';

import 'package:git_pilot_domain/git_pilot_domain.dart';

final class WorkspaceSessionLocalDataSource {
  const WorkspaceSessionLocalDataSource({required this.sessionFilePath});

  final String sessionFilePath;

  Future<WorkspaceSession> readSession() async {
    final File sessionFile = File(sessionFilePath);

    if (!await sessionFile.exists()) {
      return const WorkspaceSession.empty();
    }

    final String rawJson = await sessionFile.readAsString();
    final Object? decoded = jsonDecode(rawJson);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Workspace session file is invalid.');
    }

    final List<SavedRepository> savedRepositories =
        (decoded['savedRepositories'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(_savedRepositoryFromJson)
            .toList(growable: false);

    final List<String> openRepositoryIds =
        (decoded['openRepositoryIds'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<String>()
            .toList(growable: false);

    final String? selectedRepositoryId =
        decoded['selectedRepositoryId'] as String?;

    return WorkspaceSession(
      savedRepositories: savedRepositories,
      openRepositoryIds: openRepositoryIds,
      selectedRepositoryId: selectedRepositoryId,
    ).normalize();
  }

  Future<WorkspaceSession> writeSession(WorkspaceSession session) async {
    final File sessionFile = File(sessionFilePath);
    await sessionFile.parent.create(recursive: true);

    final WorkspaceSession normalizedSession = session.normalize();

    await sessionFile.writeAsString(
      jsonEncode(<String, Object?>{
        'savedRepositories': normalizedSession.savedRepositories
            .map(_savedRepositoryToJson)
            .toList(growable: false),
        'openRepositoryIds': normalizedSession.openRepositoryIds,
        'selectedRepositoryId': normalizedSession.selectedRepositoryId,
      }),
    );

    return normalizedSession;
  }

  SavedRepository _savedRepositoryFromJson(Map<String, dynamic> json) {
    return SavedRepository(
      rootPath: json['rootPath'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
    );
  }

  Map<String, Object?> _savedRepositoryToJson(SavedRepository repository) {
    return <String, Object?>{
      'rootPath': repository.rootPath,
      'displayName': repository.displayName,
    };
  }
}
