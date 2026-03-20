final class SavedRepository {
  const SavedRepository({required this.rootPath, required this.displayName});

  final String rootPath;
  final String displayName;

  String get id => rootPath;

  @override
  bool operator ==(Object other) {
    return other is SavedRepository &&
        other.rootPath == rootPath &&
        other.displayName == displayName;
  }

  @override
  int get hashCode => Object.hash(rootPath, displayName);
}
