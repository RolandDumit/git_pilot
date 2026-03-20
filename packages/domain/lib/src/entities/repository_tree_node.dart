final class RepositoryTreeNode {
  const RepositoryTreeNode({
    required this.name,
    required this.relativePath,
    required this.isDirectory,
    required this.hasChildren,
  });

  final String name;
  final String relativePath;
  final bool isDirectory;
  final bool hasChildren;

  String get id => relativePath;

  @override
  bool operator ==(Object other) {
    return other is RepositoryTreeNode &&
        other.name == name &&
        other.relativePath == relativePath &&
        other.isDirectory == isDirectory &&
        other.hasChildren == hasChildren;
  }

  @override
  int get hashCode => Object.hash(name, relativePath, isDirectory, hasChildren);
}
