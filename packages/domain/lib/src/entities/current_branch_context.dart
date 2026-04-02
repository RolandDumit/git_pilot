final class CurrentBranchContext {
  const CurrentBranchContext({
    required this.localBranchName,
    this.upstreamBranchName,
  });

  final String? localBranchName;
  final String? upstreamBranchName;

  @override
  bool operator ==(Object other) {
    return other is CurrentBranchContext &&
        other.localBranchName == localBranchName &&
        other.upstreamBranchName == upstreamBranchName;
  }

  @override
  int get hashCode => Object.hash(localBranchName, upstreamBranchName);
}
