import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/button.dart';
import 'package:git_pilot_presentation/style.dart';

import '../cubit/workspace_cubit.dart';
import 'remote_branches_panel.dart';
import 'repository_tab_bar.dart';
import 'repository_tree_panel.dart';
import 'workspace_message_banner.dart';
import 'workspace_panel.dart';

class WorkspaceShell extends StatelessWidget {
  const WorkspaceShell({super.key, required this.state});

  final WorkspaceState state;

  @override
  Widget build(BuildContext context) {
    final WorkspaceCubit cubit = context.read<WorkspaceCubit>();
    final SavedRepository? selectedRepository = state.selectedRepository;
    final RepositoryTabState selectedTabState =
        state.selectedTabState ?? const RepositoryTabState();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Git Pilot', style: context.typography.heading),
                    const SizedBox(height: 6),
                    Text(
                      'Persistent local repositories with restored tabs.',
                      style: context.typography.body.muted(context),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 220,
                child: Button.small(
                  onPressed: cubit.openLocalRepository,
                  label: 'Open local repository',
                  loading: state.isPickingRepository,
                ),
              ),
            ],
          ),
          if (state.message != null) ...[
            const SizedBox(height: 20),
            WorkspaceMessageBanner(message: state.message!),
          ],
          const SizedBox(height: 20),
          RepositoryTabBar(state: state),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool stackPanels =
                    constraints.maxWidth < Style.breakpoints.desktop * 2;

                final Widget branchesPanel = WorkspacePanel(
                  title: 'Remote branches',
                  child: RemoteBranchesPanel(tabState: selectedTabState),
                );

                final Widget treePanel = WorkspacePanel(
                  title: selectedRepository == null
                      ? 'Git tree'
                      : 'Git tree (${selectedRepository.displayName})',
                  child: RepositoryTreePanel(
                    tabState: selectedTabState,
                    onToggleDirectory: cubit.toggleDirectory,
                  ),
                );

                if (stackPanels) {
                  return Column(
                    children: [
                      Expanded(child: branchesPanel),
                      const SizedBox(height: 16),
                      Expanded(child: treePanel),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 320, child: branchesPanel),
                    const SizedBox(width: 16),
                    Expanded(child: treePanel),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
