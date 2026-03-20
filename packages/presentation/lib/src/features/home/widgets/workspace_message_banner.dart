import 'package:flutter/widgets.dart';
import 'package:git_pilot_presentation/info_banner.dart';

import '../cubit/workspace_cubit.dart';

class WorkspaceMessageBanner extends StatelessWidget {
  const WorkspaceMessageBanner({super.key, required this.message});

  final WorkspaceMessage message;

  @override
  Widget build(BuildContext context) {
    return InfoBanner(
      title: message.kind == WorkspaceMessageKind.error
          ? 'Something went wrong'
          : 'Notice',
      description: message.text,
      variant: message.kind == WorkspaceMessageKind.error
          ? InfoBannerVariant.error
          : InfoBannerVariant.info,
    );
  }
}
