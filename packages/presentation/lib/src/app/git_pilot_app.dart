import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/style.dart';

import '../features/home/cubit/workspace_cubit.dart';
import '../features/home/view/workspace_page.dart';
import '../services/local_repository_picker.dart';

class GitPilotApp extends StatelessWidget {
  const GitPilotApp({
    super.key,
    required this.loadWorkspaceSession,
    required this.addLocalRepository,
    required this.openRepositoryTab,
    required this.closeRepositoryTab,
    required this.selectRepositoryTab,
    required this.loadRepositoryWorkspace,
    required this.loadRepositoryTreeChildren,
    required this.localRepositoryPicker,
  });

  final LoadWorkspaceSession loadWorkspaceSession;
  final AddLocalRepository addLocalRepository;
  final OpenRepositoryTab openRepositoryTab;
  final CloseRepositoryTab closeRepositoryTab;
  final SelectRepositoryTab selectRepositoryTab;
  final LoadRepositoryWorkspace loadRepositoryWorkspace;
  final LoadRepositoryTreeChildren loadRepositoryTreeChildren;
  final LocalRepositoryPicker localRepositoryPicker;

  @override
  Widget build(BuildContext context) {
    final Brightness platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    return Style(
      brightness: platformBrightness,
      child: BlocProvider<WorkspaceCubit>(
        create: (_) => WorkspaceCubit(
          loadWorkspaceSession: loadWorkspaceSession,
          addLocalRepository: addLocalRepository,
          openRepositoryTab: openRepositoryTab,
          closeRepositoryTab: closeRepositoryTab,
          selectRepositoryTab: selectRepositoryTab,
          loadRepositoryWorkspace: loadRepositoryWorkspace,
          loadRepositoryTreeChildren: loadRepositoryTreeChildren,
          localRepositoryPicker: localRepositoryPicker,
        )..initialize(),
        child: MaterialApp(
          title: 'Git Pilot',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF09090B),
          ),
          home: const WorkspacePage(),
        ),
      ),
    );
  }
}
