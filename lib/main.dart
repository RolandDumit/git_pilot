import 'package:file_selector/file_selector.dart';
import 'package:flutter/widgets.dart';
import 'package:git_pilot_data/git_pilot_data.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/git_pilot_presentation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String sessionFilePath = await _resolveSessionFilePath();
  final ProcessGitCommandRunner commandRunner = ProcessGitCommandRunner();
  final WorkspaceSessionRepository workspaceSessionRepository =
      LocalWorkspaceSessionRepository(
        localDataSource: WorkspaceSessionLocalDataSource(
          sessionFilePath: sessionFilePath,
        ),
      );
  final GitRepositoryExplorer gitRepositoryExplorer =
      LocalGitRepositoryExplorer(
        repositoryResolverDataSource: GitRepositoryResolverDataSource(
          commandRunner: commandRunner,
        ),
        currentBranchDataSource: GitCurrentBranchDataSource(
          commandRunner: commandRunner,
        ),
        remoteBranchesDataSource: GitRemoteBranchesDataSource(
          commandRunner: commandRunner,
        ),
        recentCommitsDataSource: GitRecentCommitsDataSource(
          commandRunner: commandRunner,
        ),
        repositoryFileTreeDataSource: const RepositoryFileTreeDataSource(),
      );

  runApp(
    GitPilotApp(
      loadWorkspaceSession: LoadWorkspaceSession(workspaceSessionRepository),
      addLocalRepository: AddLocalRepository(
        workspaceSessionRepository,
        gitRepositoryExplorer,
      ),
      openRepositoryTab: OpenRepositoryTab(workspaceSessionRepository),
      closeRepositoryTab: CloseRepositoryTab(workspaceSessionRepository),
      selectRepositoryTab: SelectRepositoryTab(workspaceSessionRepository),
      loadRepositoryWorkspace: LoadRepositoryWorkspace(gitRepositoryExplorer),
      localRepositoryPicker: const _FileSelectorLocalRepositoryPicker(),
    ),
  );
}

Future<String> _resolveSessionFilePath() async {
  final directory = await getApplicationSupportDirectory();
  return p.join(directory.path, 'workspace_session.json');
}

final class _FileSelectorLocalRepositoryPicker
    implements LocalRepositoryPicker {
  const _FileSelectorLocalRepositoryPicker();

  @override
  Future<String?> pickDirectory() {
    return getDirectoryPath(confirmButtonText: 'Open repository');
  }
}
