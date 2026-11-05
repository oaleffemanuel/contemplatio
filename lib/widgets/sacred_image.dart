import 'package:flutter/material.dart';

import '../app/theme.dart';

/// A painting shown full-bleed. With [drift] it slowly zooms (Ken Burns) to
/// invite contemplation. A gradient keeps overlaid text legible.
class SacredImage extends StatefulWidget {
  const SacredImage({
    super.key,
    required this.file,
    this.alignment = Alignment.center,
    this.drift = false,
    this.shade = ImageShade.bottom,
    this.thumbnail = false,
  });

  final String file;
  final Alignment alignment;
  final bool drift;
  final ImageShade shade;

  /// Cards and grids decode a small version instead of the full painting.
  final bool thumbnail;

  @override
  State<SacredImage> createState() => _SacredImageState();
}

enum ImageShade { bottom, full, none }

class _SacredImageState extends State<SacredImage>
    with SingleTickerProviderStateMixin {
  AnimationController? _drift;

  @override
  void initState() {
    super.initState();
    if (widget.drift) {
      _drift = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 28),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _drift?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/${widget.file}',
      fit: BoxFit.cover,
      alignment: widget.alignment,
      gaplessPlayback: true,
      cacheWidth:
          widget.thumbnail
              ? (420 * MediaQuery.devicePixelRatioOf(context) / 3).round()
              : null,
      errorBuilder: (_, _, _) => const _Placeholder(),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_drift case final drift?)
          AnimatedBuilder(
            animation: drift,
            builder:
                (_, child) => Transform.scale(
                  scale: 1.04 + 0.06 * Curves.easeInOut.transform(drift.value),
                  alignment: widget.alignment,
                  child: child,
                ),
            child: image,
          )
        else
          image,
        if (widget.shade != ImageShade.none)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops:
                    widget.shade == ImageShade.full
                        ? const [0, 1]
                        : const [0, 0.3, 0.5, 0.78, 1],
                colors:
                    widget.shade == ImageShade.full
                        ? [
                          LumenColors.imageInk.withValues(alpha: 0.35),
                          LumenColors.imageInk.withValues(alpha: 0.85),
                        ]
                        : [
                          LumenColors.imageInk.withValues(alpha: 0.75),
                          Colors.transparent,
                          Colors.transparent,
                          LumenColors.imageInk.withValues(alpha: 0.78),
                          LumenColors.imageInk.withValues(alpha: 0.97),
                        ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.35),
          radius: 1.15,
          colors: [Color(0xFF26304A), LumenColors.imageInk],
        ),
      ),
    );
  }
}
