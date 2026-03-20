import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';
import 'package:git_pilot_presentation/style.dart';

import '../features/home/cubit/workspace_cubit.dart';
import '../features/home/view/workspace_page.dart';
import '../services/local_repository_picker.dart';

class GitPilotApp extends StatefulWidget {
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
  State<GitPilotApp> createState() => _GitPilotAppState();
}

class _GitPilotAppState extends State<GitPilotApp> with WidgetsBindingObserver {
  late Brightness _platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final Brightness nextBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    if (nextBrightness == _platformBrightness) {
      return;
    }

    setState(() {
      _platformBrightness = nextBrightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = _platformBrightness == Brightness.dark;

    return Style(
      brightness: _platformBrightness,
      child: BlocProvider<WorkspaceCubit>(
        create: (_) => WorkspaceCubit(
          loadWorkspaceSession: widget.loadWorkspaceSession,
          addLocalRepository: widget.addLocalRepository,
          openRepositoryTab: widget.openRepositoryTab,
          closeRepositoryTab: widget.closeRepositoryTab,
          selectRepositoryTab: widget.selectRepositoryTab,
          loadRepositoryWorkspace: widget.loadRepositoryWorkspace,
          loadRepositoryTreeChildren: widget.loadRepositoryTreeChildren,
          localRepositoryPicker: widget.localRepositoryPicker,
        )..initialize(),
        child: MaterialApp(
          title: 'Git Pilot',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF09090B),
          ),
          builder: (BuildContext context, Widget? child) {
            final Style style = Style.of(context);

            return DefaultTextStyle(
              style: style.typography.body,
              child: IconTheme(
                data: IconThemeData(color: style.colors.foreground),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: const WorkspacePage(),
        ),
      ),
    );
  }
}
