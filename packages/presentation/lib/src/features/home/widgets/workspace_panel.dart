import 'package:flutter/widgets.dart';
import 'package:git_pilot_presentation/style.dart';

class WorkspacePanel extends StatelessWidget {
  const WorkspacePanel({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Style style = Style.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(Style.radii.large),
        border: Border.all(color: style.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.typography.title),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
