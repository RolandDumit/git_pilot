import 'saved_repository.dart';

final class WorkspaceSession {
  const WorkspaceSession({
    this.savedRepositories = const <SavedRepository>[],
    this.openRepositoryIds = const <String>[],
    this.selectedRepositoryId,
  });

  const WorkspaceSession.empty()
    : savedRepositories = const <SavedRepository>[],
      openRepositoryIds = const <String>[],
      selectedRepositoryId = null;

  final List<SavedRepository> savedRepositories;
  final List<String> openRepositoryIds;
  final String? selectedRepositoryId;

  bool get hasSavedRepositories => savedRepositories.isNotEmpty;
  bool get hasOpenRepositories => openRepositoryIds.isNotEmpty;

  SavedRepository? repositoryById(String repositoryId) {
    for (final SavedRepository repository in savedRepositories) {
      if (repository.id == repositoryId) {
        return repository;
      }
    }

    return null;
  }

  List<SavedRepository> get openRepositories {
    return openRepositoryIds
        .map(repositoryById)
        .whereType<SavedRepository>()
        .toList(growable: false);
  }

  WorkspaceSession normalize() {
    final Set<String> validIds = savedRepositories
        .map((SavedRepository repository) => repository.id)
        .toSet();

    final List<String> normalizedOpenIds = openRepositoryIds
        .where(validIds.contains)
        .toList(growable: false);

    final String? normalizedSelectedId =
        selectedRepositoryId != null &&
            normalizedOpenIds.contains(selectedRepositoryId)
        ? selectedRepositoryId
        : normalizedOpenIds.isEmpty
        ? null
        : normalizedOpenIds.first;

    return WorkspaceSession(
      savedRepositories: savedRepositories,
      openRepositoryIds: normalizedOpenIds,
      selectedRepositoryId: normalizedSelectedId,
    );
  }

  WorkspaceSession addOrOpenRepository(SavedRepository repository) {
    final List<SavedRepository> nextSavedRepositories =
        savedRepositories
            .where((SavedRepository candidate) => candidate.id != repository.id)
            .toList(growable: true)
          ..add(repository);

    final List<String> nextOpenIds = openRepositoryIds.contains(repository.id)
        ? openRepositoryIds
        : <String>[...openRepositoryIds, repository.id];

    return WorkspaceSession(
      savedRepositories: nextSavedRepositories,
      openRepositoryIds: nextOpenIds,
      selectedRepositoryId: repository.id,
    ).normalize();
  }

  WorkspaceSession openRepository(String repositoryId) {
    if (repositoryById(repositoryId) == null) {
      return normalize();
    }

    final List<String> nextOpenIds = openRepositoryIds.contains(repositoryId)
        ? openRepositoryIds
        : <String>[...openRepositoryIds, repositoryId];

    return copyWith(
      openRepositoryIds: nextOpenIds,
      selectedRepositoryId: repositoryId,
    ).normalize();
  }

  WorkspaceSession closeRepository(String repositoryId) {
    final List<String> nextOpenIds = openRepositoryIds
        .where((String id) => id != repositoryId)
        .toList(growable: false);

    final String? nextSelectedId;
    if (selectedRepositoryId == repositoryId) {
      nextSelectedId = nextOpenIds.isEmpty ? null : nextOpenIds.last;
    } else {
      nextSelectedId = selectedRepositoryId;
    }

    return copyWith(
      openRepositoryIds: nextOpenIds,
      selectedRepositoryId: nextSelectedId,
    ).normalize();
  }

  WorkspaceSession selectRepository(String repositoryId) {
    if (!openRepositoryIds.contains(repositoryId)) {
      return normalize();
    }

    return copyWith(selectedRepositoryId: repositoryId).normalize();
  }

  WorkspaceSession copyWith({
    List<SavedRepository>? savedRepositories,
    List<String>? openRepositoryIds,
    String? selectedRepositoryId,
  }) {
    return WorkspaceSession(
      savedRepositories: savedRepositories ?? this.savedRepositories,
      openRepositoryIds: openRepositoryIds ?? this.openRepositoryIds,
      selectedRepositoryId: selectedRepositoryId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WorkspaceSession &&
        _listEquals(other.savedRepositories, savedRepositories) &&
        _listEquals(other.openRepositoryIds, openRepositoryIds) &&
        other.selectedRepositoryId == selectedRepositoryId;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(savedRepositories),
    Object.hashAll(openRepositoryIds),
    selectedRepositoryId,
  );
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (identical(left, right)) {
    return true;
  }

  if (left.length != right.length) {
    return false;
  }

  for (int index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}
