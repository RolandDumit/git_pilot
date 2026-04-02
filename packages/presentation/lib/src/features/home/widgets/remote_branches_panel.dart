import 'package:flutter/material.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/orient_ui_widgets/info_banner.dart';
import 'package:git_pilot_presentation/orient_ui_widgets/spinner.dart';
import 'package:git_pilot_presentation/orient_ui_widgets/tile.dart';
import 'package:git_pilot_presentation/style.dart';

import '../cubit/workspace_cubit.dart';

class RemoteBranchesPanel extends StatelessWidget {
  const RemoteBranchesPanel({
    super.key,
    required this.tabState,
    required this.onSelectBranch,
  });

  final RepositoryTabState tabState;
  final ValueChanged<String> onSelectBranch;

  @override
  Widget build(BuildContext context) {
    final Style style = Style.of(context);

    if (tabState.isLoading) {
      return Center(child: Spinner(color: style.colors.foreground));
    }

    if (tabState.hasError) {
      return InfoBanner(
        title: 'Unable to load remote branches',
        description: tabState.errorMessage,
        variant: InfoBannerVariant.error,
      );
    }

    if (tabState.remoteBranches.isEmpty) {
      return Center(
        child: Text(
          'No remote branches found.',
          style: context.typography.body.muted(context),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (tabState.currentLocalBranchName != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Checked out locally: ${tabState.currentLocalBranchName}',
              style: context.typography.bodySmall.muted(context),
            ),
          ),
        if (tabState.currentLocalBranchName != null) const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: tabState.remoteBranches.length,
            separatorBuilder: (_, _) => const SizedBox(height: 0),
            itemBuilder: (BuildContext context, int index) {
              final RemoteBranchRef branch = tabState.remoteBranches[index];

              return Tile(
                title: branch.name,
                leading: Icon(Icons.abc, color: style.colors.mutedForeground),
                variant: TileVariant.simple,
                isSelected: branch.name == tabState.selectedRemoteBranchName,
                onTap: () => onSelectBranch(branch.name),
              );
            },
          ),
        ),
      ],
    );
  }
}
