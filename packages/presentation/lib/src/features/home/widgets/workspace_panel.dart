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
        borderRadius: BorderRadius.circular(Style.radii.small),
        border: Border.all(color: style.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const .only(left: 4, top: 4),
            child: Text(title, style: context.typography.subtitle),
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
