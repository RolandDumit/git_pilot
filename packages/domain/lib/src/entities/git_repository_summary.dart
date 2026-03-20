final class GitRepositorySummary {
  const GitRepositorySummary({
    required this.name,
    required this.path,
    this.branch,
  });

  final String name;
  final String path;
  final String? branch;
}
