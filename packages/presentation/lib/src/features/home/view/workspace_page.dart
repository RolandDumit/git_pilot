import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_presentation/style.dart';

import '../cubit/workspace_cubit.dart';
import '../widgets/workspace_failure_view.dart';
import '../widgets/workspace_landing.dart';
import '../widgets/workspace_loading_view.dart';
import '../widgets/workspace_shell.dart';

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Style style = Style.of(context);

    return ColoredBox(
      color: style.colors.background,
      child: SafeArea(
        child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
          builder: (BuildContext context, WorkspaceState state) {
            return AnimatedSwitcher(
              duration: Style.durations.normal,
              child: switch (state.mode) {
                WorkspaceViewMode.loading => const WorkspaceLoadingView(),
                WorkspaceViewMode.emptyOnboarding => WorkspaceLanding(
                  key: const ValueKey<String>('empty-onboarding'),
                  state: state,
                ),
                WorkspaceViewMode.selector => WorkspaceLanding(
                  key: const ValueKey<String>('saved-selector'),
                  state: state,
                ),
                WorkspaceViewMode.workspace => WorkspaceShell(
                  key: const ValueKey<String>('workspace-shell'),
                  state: state,
                ),
                WorkspaceViewMode.failure => WorkspaceFailureView(
                  failureMessage:
                      state.failureMessage ?? 'Unable to load the workspace.',
                ),
              },
            );
          },
        ),
      ),
    );
  }
}
