import 'dart:io';

import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:path/path.dart' as p;

final class RepositoryFileTreeDataSource {
  const RepositoryFileTreeDataSource();

  Future<Result<List<RepositoryTreeNode>>> loadTreeNodes(
    SavedRepository repository, {
    String? relativePath,
  }) async {
    final String directoryPath = relativePath == null || relativePath.isEmpty
        ? repository.rootPath
        : p.join(repository.rootPath, relativePath);

    final Directory directory = Directory(directoryPath);

    if (!await directory.exists()) {
      return const FailureResult<List<RepositoryTreeNode>>(
        ValidationFailure('The selected repository folder no longer exists.'),
      );
    }

    final List<FileSystemEntity> entries =
        directory
            .listSync(followLinks: false)
            .where(
              (FileSystemEntity entity) => p.basename(entity.path) != '.git',
            )
            .toList(growable: false)
          ..sort(_compareEntities);

    final List<RepositoryTreeNode> nodes = entries
        .map((FileSystemEntity entity) => _toNode(repository, entity))
        .toList(growable: false);

    return Success<List<RepositoryTreeNode>>(nodes);
  }

  int _compareEntities(FileSystemEntity left, FileSystemEntity right) {
    final bool leftIsDirectory = left is Directory;
    final bool rightIsDirectory = right is Directory;

    if (leftIsDirectory != rightIsDirectory) {
      return leftIsDirectory ? -1 : 1;
    }

    return p
        .basename(left.path)
        .toLowerCase()
        .compareTo(p.basename(right.path).toLowerCase());
  }

  RepositoryTreeNode _toNode(
    SavedRepository repository,
    FileSystemEntity entity,
  ) {
    final bool isDirectory = entity is Directory;
    final String relativePath = p.relative(
      entity.path,
      from: repository.rootPath,
    );

    return RepositoryTreeNode(
      name: p.basename(entity.path),
      relativePath: relativePath,
      isDirectory: isDirectory,
      hasChildren: isDirectory ? _directoryHasVisibleChildren(entity) : false,
    );
  }

  bool _directoryHasVisibleChildren(Directory directory) {
    return directory
        .listSync(followLinks: false)
        .any((FileSystemEntity entity) => p.basename(entity.path) != '.git');
  }
}
