import 'package:flutter/widgets.dart';
import 'package:git_pilot_data/git_pilot_data.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/git_pilot_presentation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final GitRepositoryCatalog repositoryCatalog = LocalGitRepositoryCatalog();
  final LoadRepositories loadRepositories = LoadRepositories(repositoryCatalog);

  runApp(GitPilotApp(loadRepositories: loadRepositories));
}
