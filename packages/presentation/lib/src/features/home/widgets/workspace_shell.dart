import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/style.dart';

import '../cubit/workspace_cubit.dart';
import 'remote_branches_panel.dart';
import 'repository_tab_bar.dart';
import 'repository_tree_panel.dart';
import 'workspace_message_banner.dart';
import 'workspace_panel.dart';

class WorkspaceShell extends StatefulWidget {
  const WorkspaceShell({super.key, required this.state});

  final WorkspaceState state;

  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  static const double _defaultBranchesPanelWidth = 320;
  static const double _defaultBranchesPanelHeight = 280;
  static const double _minBranchesPanelWidth = 240;
  static const double _minBranchesPanelHeight = 180;
  static const double _minTreePanelWidth = 320;
  static const double _minTreePanelHeight = 240;
  static const double _separatorWidth = 4;

  double _branchesPanelWidth = _defaultBranchesPanelWidth;
  double _branchesPanelHeight = _defaultBranchesPanelHeight;

  double _clampBranchesPanelWidth(double width, double availableWidth) {
    final double maxWidth = availableWidth - _separatorWidth - _minTreePanelWidth;

    if (maxWidth <= _minBranchesPanelWidth) {
      return availableWidth / 2;
    }

    return width.clamp(_minBranchesPanelWidth, maxWidth).toDouble();
  }

  double _clampBranchesPanelHeight(double height, double availableHeight) {
    final double maxHeight = availableHeight - _separatorWidth - _minTreePanelHeight;

    if (maxHeight <= _minBranchesPanelHeight) {
      return availableHeight / 2;
    }

    return height.clamp(_minBranchesPanelHeight, maxHeight).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final WorkspaceCubit cubit = context.read<WorkspaceCubit>();
    final WorkspaceState state = widget.state;
    final SavedRepository? selectedRepository = state.selectedRepository;
    final RepositoryTabState selectedTabState = state.selectedTabState ?? const RepositoryTabState();

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.message != null) ...[const SizedBox(height: 16), WorkspaceMessageBanner(message: state.message!)],
          const SizedBox(height: 4),
          RepositoryTabBar(state: state),
          const SizedBox(height: 4),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool stackPanels = constraints.maxWidth < Style.breakpoints.desktop * 2;
                final Style style = Style.of(context);

                final Widget branchesPanel = WorkspacePanel(
                  title: 'Remote branches',
                  child: RemoteBranchesPanel(tabState: selectedTabState),
                );

                final Widget treePanel = WorkspacePanel(
                  title: selectedRepository == null ? 'Git tree' : 'Git tree (${selectedRepository.displayName})',
                  child: RepositoryTreePanel(tabState: selectedTabState, onToggleDirectory: cubit.toggleDirectory),
                );

                if (stackPanels) {
                  final double branchesPanelHeight = _clampBranchesPanelHeight(
                    _branchesPanelHeight,
                    constraints.maxHeight,
                  );

                  return Column(
                    children: [
                      SizedBox(height: branchesPanelHeight, child: branchesPanel),
                      MouseRegion(
                        cursor: SystemMouseCursors.resizeRow,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onVerticalDragUpdate: (DragUpdateDetails details) {
                            setState(() {
                              _branchesPanelHeight = _clampBranchesPanelHeight(
                                branchesPanelHeight + details.delta.dy,
                                constraints.maxHeight,
                              );
                            });
                          },
                          child: SizedBox(
                            height: _separatorWidth,
                            child: Center(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: style.colors.border,
                                  borderRadius: BorderRadius.circular(Style.radii.small),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: treePanel),
                    ],
                  );
                }

                final double branchesPanelWidth = _clampBranchesPanelWidth(_branchesPanelWidth, constraints.maxWidth);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: branchesPanelWidth, child: branchesPanel),
                    MouseRegion(
                      cursor: SystemMouseCursors.resizeColumn,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragUpdate: (DragUpdateDetails details) {
                          setState(() {
                            _branchesPanelWidth = _clampBranchesPanelWidth(
                              branchesPanelWidth + details.delta.dx,
                              constraints.maxWidth,
                            );
                          });
                        },
                        child: SizedBox(
                          width: _separatorWidth,
                          child: Center(
                            child: Container(
                              width: 2,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(Style.radii.small),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
