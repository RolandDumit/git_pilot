import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/button.dart';
import 'package:git_pilot_presentation/empty_state.dart';
import 'package:git_pilot_presentation/picker.dart';
import 'package:git_pilot_presentation/style.dart';

import '../cubit/workspace_cubit.dart';
import 'workspace_message_banner.dart';

class WorkspaceLanding extends StatelessWidget {
  const WorkspaceLanding({super.key, required this.state});

  final WorkspaceState state;

  @override
  Widget build(BuildContext context) {
    final WorkspaceCubit cubit = context.read<WorkspaceCubit>();
    final Style style = Style.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: style.colors.surfaceContainer,
              borderRadius: BorderRadius.circular(Style.radii.large),
              border: Border.all(color: style.colors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Git Pilot', style: context.typography.display),
                  const SizedBox(height: 12),
                  Text(
                    'Cross-platform Git desktop client',
                    style: context.typography.subtitle,
                  ),
                  const SizedBox(height: 24),
                  if (state.message != null) ...[
                    WorkspaceMessageBanner(message: state.message!),
                    const SizedBox(height: 24),
                  ],
                  if (state.mode == WorkspaceViewMode.selector) ...[
                    SizedBox(
                      width: 360,
                      child: Picker<SavedRepository>(
                        label: 'Saved repositories',
                        items: state.session.savedRepositories,
                        itemLabel: (SavedRepository repository) {
                          return repository.displayName;
                        },
                        onChanged: (SavedRepository repository) {
                          cubit.openSavedRepository(repository.id);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: EmptyState(
                      title: state.mode == WorkspaceViewMode.selector
                          ? 'Choose a saved repository or open a new one'
                          : 'Open your first local repository',
                      description: state.mode == WorkspaceViewMode.selector
                          ? 'Git Pilot remembers saved repositories and can reopen them as tabs whenever you need them.'
                          : 'Select a local Git repository to start building a persistent desktop workspace with restored tabs.',
                      icon: Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: style.colors.accent,
                          borderRadius: BorderRadius.circular(
                            Style.radii.medium,
                          ),
                        ),
                        child: Text(
                          'GP',
                          style: context.typography.title.withColor(
                            style.colors.accentForeground,
                          ),
                        ),
                      ),
                      action: Button(
                        onPressed: cubit.openLocalRepository,
                        label: 'Open local repository',
                        loading: state.isPickingRepository,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
