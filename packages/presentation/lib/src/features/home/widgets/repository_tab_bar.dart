import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/style.dart';

import '../cubit/workspace_cubit.dart';

class RepositoryTabBar extends StatelessWidget {
  const RepositoryTabBar({super.key, required this.state});

  final WorkspaceState state;

  @override
  Widget build(BuildContext context) {
    final Style style = Style.of(context);
    final WorkspaceCubit cubit = context.read<WorkspaceCubit>();
    final List<SavedRepository> openRepositories =
        state.session.openRepositories;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(Style.radii.large),
        border: Border.all(color: style.colors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: openRepositories
              .map((SavedRepository repository) {
                final bool isSelected =
                    repository.id == state.session.selectedRepositoryId;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: RepositoryTab(
                    repository: repository,
                    isSelected: isSelected,
                    onTap: () => cubit.selectRepository(repository.id),
                    onClose: () => cubit.closeRepository(repository.id),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}

class RepositoryTab extends StatelessWidget {
  const RepositoryTab({
    super.key,
    required this.repository,
    required this.isSelected,
    required this.onTap,
    required this.onClose,
  });

  final SavedRepository repository;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final Style style = Style.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected
            ? style.colors.background
            : style.colors.navigation.railBackground,
        borderRadius: BorderRadius.circular(Style.radii.medium),
        border: Border.all(
          color: isSelected ? style.colors.border : style.colors.borderSubtle,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    repository.displayName,
                    style: context.typography.body.w600,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 180,
                    child: Text(
                      repository.rootPath,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.caption.muted(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                'x',
                style: context.typography.body.withColor(
                  style.colors.mutedForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
