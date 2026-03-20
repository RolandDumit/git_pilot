import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/orient_ui_widgets/tappable_icon.dart';
import 'package:git_pilot_presentation/style.dart';

import '../cubit/workspace_cubit.dart';

class RepositoryTabBar extends StatelessWidget {
  const RepositoryTabBar({super.key, required this.state});

  final WorkspaceState state;

  @override
  Widget build(BuildContext context) {
    final Style style = Style.of(context);
    final WorkspaceCubit cubit = context.read<WorkspaceCubit>();
    final List<SavedRepository> openRepositories = state.session.openRepositories;

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
          children: List<Widget>.generate(openRepositories.length, (int index) {
            final SavedRepository repository = openRepositories[index];
            final bool isSelected = repository.id == state.session.selectedRepositoryId;

            return Padding(
              padding: EdgeInsets.only(right: index == openRepositories.length - 1 ? 0 : 8),
              child: RepositoryTab(
                repository: repository,
                isSelected: isSelected,
                onTap: () => cubit.selectRepository(repository.id),
                onClose: () => cubit.closeRepository(repository.id),
              ),
            );
          }),
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
        color: isSelected ? style.colors.background : style.colors.navigation.railBackground,
        borderRadius: BorderRadius.circular(Style.radii.medium),
        border: Border.all(color: isSelected ? style.colors.border : style.colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                repository.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.body.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TappableIcon(
              onPressed: onClose,
              size: 32,
              tooltip: 'Close ${repository.displayName}',
              icon: const Icon(Icons.close_rounded, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
