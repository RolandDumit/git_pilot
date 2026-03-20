import 'package:flutter/widgets.dart';
import 'package:git_pilot_presentation/orient_ui_widgets/spinner.dart';
import 'package:git_pilot_presentation/style.dart';

class WorkspaceLoadingView extends StatelessWidget {
  const WorkspaceLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final Style style = Style.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spinner(color: style.colors.foreground),
          const SizedBox(height: 16),
          Text('Loading workspace...', style: context.typography.body),
        ],
      ),
    );
  }
}
