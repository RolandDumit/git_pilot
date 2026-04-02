final class CommitSummary {
  const CommitSummary({
    required this.subject,
    required this.authorName,
    required this.committedAt,
    required this.hash,
  });

  final String subject;
  final String authorName;
  final DateTime committedAt;
  final String hash;

  @override
  bool operator ==(Object other) {
    return other is CommitSummary &&
        other.subject == subject &&
        other.authorName == authorName &&
        other.committedAt == committedAt &&
        other.hash == hash;
  }

  @override
  int get hashCode => Object.hash(subject, authorName, committedAt, hash);
}
