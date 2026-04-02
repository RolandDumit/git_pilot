import 'package:flutter/material.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/orient_ui_widgets/info_banner.dart';
import 'package:git_pilot_presentation/orient_ui_widgets/spinner.dart';
import 'package:git_pilot_presentation/orient_ui_widgets/tile.dart';
import 'package:git_pilot_presentation/style.dart';

import '../cubit/workspace_cubit.dart';

class RepositoryTreePanel extends StatelessWidget {
  const RepositoryTreePanel({super.key, required this.tabState});

  final RepositoryTabState tabState;

  @override
  Widget build(BuildContext context) {
    final Style style = Style.of(context);

    if (tabState.isLoading) {
      return Center(child: Spinner(color: style.colors.foreground));
    }

    if (tabState.hasError) {
      return InfoBanner(
        title: 'Unable to load recent commits',
        description: tabState.errorMessage,
        variant: InfoBannerVariant.error,
      );
    }

    if (tabState.recentCommits.isEmpty) {
      return Center(
        child: Text(
          'No commits found.',
          style: context.typography.body.muted(context),
        ),
      );
    }

    return ListView.separated(
      itemCount: tabState.recentCommits.length,
      separatorBuilder: (_, _) => const SizedBox(height: 0),
      itemBuilder: (BuildContext context, int index) {
        final CommitSummary commit = tabState.recentCommits[index];

        return Tile(
          title: commit.subject,
          subtitle:
              '${commit.authorName} • ${_formatCommitDate(commit.committedAt)} • ${commit.hash.substring(0, 7)}',
          leading: Icon(
            Icons.history,
            color: style.colors.mutedForeground,
            size: 16,
          ),
          variant: TileVariant.simple,
        );
      },
    );
  }
}

String _formatCommitDate(DateTime date) {
  final DateTime localDate = date.toLocal();
  final String month = localDate.month.toString().padLeft(2, '0');
  final String day = localDate.day.toString().padLeft(2, '0');
  final String hour = localDate.hour.toString().padLeft(2, '0');
  final String minute = localDate.minute.toString().padLeft(2, '0');
  return '${localDate.year}-$month-$day $hour:$minute';
}
