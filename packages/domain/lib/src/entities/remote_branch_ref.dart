final class RemoteBranchRef {
  const RemoteBranchRef({required this.name});

  final String name;

  @override
  bool operator ==(Object other) {
    return other is RemoteBranchRef && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
