import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/repository_overview_cubit.dart';

class RepositoryOverviewPage extends StatelessWidget {
  const RepositoryOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: BlocBuilder<RepositoryOverviewCubit, RepositoryOverviewState>(
              builder: (BuildContext context, RepositoryOverviewState state) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x120F172A),
                        blurRadius: 32,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Git Pilot',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Cross-platform Git desktop client',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'The root Flutter app now acts as the composition '
                          'layer, while presentation, domain, data, and core '
                          'live in separate packages.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        if (state.isLoading) const LinearProgressIndicator(),
                        if (!state.isLoading) ...<Widget>[
                          if (state.hasError)
                            _StatusBanner(
                              message: state.errorMessage ?? 'Unknown error',
                              color: const Color(0xFFFEE2E2),
                              foreground: const Color(0xFF991B1B),
                            )
                          else if (state.isEmpty)
                            const _StatusBanner(
                              message: 'No repositories connected yet.',
                              color: Color(0xFFE0F2FE),
                              foreground: Color(0xFF0F4C81),
                            )
                          else
                            ...state.repositories.map(
                              (repository) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(repository.name),
                                subtitle: Text(repository.path),
                                trailing: repository.branch == null
                                    ? null
                                    : Text(repository.branch!),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.color,
    required this.foreground,
  });

  final String message;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
