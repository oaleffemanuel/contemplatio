import 'package:flutter/widgets.dart';

/// Keeps reading content in a centred column on wide screens (iPad), so lines
/// and cards keep phone-like proportions instead of stretching edge to edge.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.shrinkHeight = false,
  });

  final Widget child;
  final double maxWidth;

  /// For bars (e.g. bottomNavigationBar): take the child's height, not all of it.
  final bool shrinkHeight;

  @override
  Widget build(BuildContext context) => Center(
    heightFactor: shrinkHeight ? 1 : null,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
