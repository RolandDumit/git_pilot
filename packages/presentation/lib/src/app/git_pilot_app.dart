import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_pilot_domain/git_pilot_domain.dart';

import '../features/home/cubit/repository_overview_cubit.dart';
import '../features/home/view/repository_overview_page.dart';

class GitPilotApp extends StatelessWidget {
  const GitPilotApp({super.key, required this.loadRepositories});

  final LoadRepositories loadRepositories;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RepositoryOverviewCubit>(
      create: (_) => RepositoryOverviewCubit(loadRepositories)..load(),
      child: MaterialApp(
        title: 'Git Pilot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1F2937),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          useMaterial3: true,
        ),
        home: const RepositoryOverviewPage(),
      ),
    );
  }
}
