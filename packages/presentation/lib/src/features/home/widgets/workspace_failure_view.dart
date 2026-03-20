import 'package:flutter/widgets.dart';
import 'package:git_pilot_presentation/info_banner.dart';

class WorkspaceFailureView extends StatelessWidget {
  const WorkspaceFailureView({super.key, required this.failureMessage});

  final String failureMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: InfoBanner(
            title: 'Unable to load workspace session',
            description: failureMessage,
            variant: InfoBannerVariant.error,
          ),
        ),
      ),
    );
  }
}
