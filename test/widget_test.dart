import 'package:flutter_test/flutter_test.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/git_pilot_presentation.dart';

void main() {
  testWidgets('renders the desktop shell from the presentation package', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GitPilotApp(
        loadRepositories: LoadRepositories(_FakeGitRepositoryCatalog()),
      ),
    );
    await tester.pump();

    expect(find.text('Git Pilot'), findsOneWidget);
    expect(find.text('Cross-platform Git desktop client'), findsOneWidget);
    expect(find.text('No repositories connected yet.'), findsOneWidget);
  });
}

class _FakeGitRepositoryCatalog implements GitRepositoryCatalog {
  @override
  Future<Result<List<GitRepositorySummary>>> loadRepositories() async {
    return const Success<List<GitRepositorySummary>>(<GitRepositorySummary>[]);
  }
}
