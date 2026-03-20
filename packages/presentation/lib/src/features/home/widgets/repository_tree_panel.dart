import 'package:flutter/widgets.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/orient_ui_widgets/info_banner.dart';
import 'package:git_pilot_presentation/orient_ui_widgets/spinner.dart';
import 'package:git_pilot_presentation/style.dart';

import '../cubit/workspace_cubit.dart';

class RepositoryTreePanel extends StatelessWidget {
  const RepositoryTreePanel({
    super.key,
    required this.tabState,
    required this.onToggleDirectory,
  });

  final RepositoryTabState tabState;
  final ValueChanged<RepositoryTreeNode> onToggleDirectory;

  @override
  Widget build(BuildContext context) {
    final Style style = Style.of(context);

    if (tabState.isLoading) {
      return Center(child: Spinner(color: style.colors.foreground));
    }

    if (tabState.hasError) {
      return InfoBanner(
        title: 'Unable to load repository tree',
        description: tabState.errorMessage,
        variant: InfoBannerVariant.error,
      );
    }

    if (tabState.rootNodes.isEmpty) {
      return Center(
        child: Text(
          'Repository tree is empty.',
          style: context.typography.body.muted(context),
        ),
      );
    }

    return ListView(
      children: tabState.rootNodes
          .map(
            (RepositoryTreeNode node) => RepositoryTreeNodeView(
              node: node,
              depth: 0,
              tabState: tabState,
              onToggleDirectory: onToggleDirectory,
            ),
          )
          .toList(growable: false),
    );
  }
}

class RepositoryTreeNodeView extends StatelessWidget {
  const RepositoryTreeNodeView({
    super.key,
    required this.node,
    required this.depth,
    required this.tabState,
    required this.onToggleDirectory,
  });

  final RepositoryTreeNode node;
  final int depth;
  final RepositoryTabState tabState;
  final ValueChanged<RepositoryTreeNode> onToggleDirectory;

  @override
  Widget build(BuildContext context) {
    final Style style = Style.of(context);
    final bool isExpanded = tabState.expandedDirectoryPaths.contains(
      node.relativePath,
    );
    final bool isLoading = tabState.loadingDirectoryPaths.contains(
      node.relativePath,
    );
    final List<RepositoryTreeNode> children =
        tabState.childNodesByParentPath[node.relativePath] ??
        const <RepositoryTreeNode>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: node.isDirectory ? () => onToggleDirectory(node) : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: EdgeInsets.only(
              left: 12 + (depth * 20),
              right: 12,
              top: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              color: style.colors.background,
              borderRadius: BorderRadius.circular(Style.radii.medium),
              border: Border.all(color: style.colors.borderSubtle),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  child: Text(
                    node.isDirectory ? (isExpanded ? 'v' : '>') : '-',
                    style: context.typography.bodySmall.withColor(
                      style.colors.mutedForeground,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(node.name, style: context.typography.body),
                ),
                if (isLoading)
                  Spinner(color: style.colors.mutedForeground)
                else if (node.isDirectory && node.hasChildren)
                  Text(
                    '${children.length}',
                    style: context.typography.caption.muted(context),
                  ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ...children.map(
            (RepositoryTreeNode child) => RepositoryTreeNodeView(
              node: child,
              depth: depth + 1,
              tabState: tabState,
              onToggleDirectory: onToggleDirectory,
            ),
          ),
      ],
    );
  }
}
