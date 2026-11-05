import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

final class LiquidTab {
  const LiquidTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final Widget Function(Color color) icon;
  final Widget Function(Color color) selectedIcon;
  final String label;
}

/// Floating "liquid glass" tab bar: a frosted capsule with a glass lens that
/// springs to the selected tab, stretching while it travels, and icons that
/// swap outline → fill with a small bounce (Instagram-style, icons only).
class LiquidTabBar extends StatefulWidget {
  const LiquidTabBar({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
    this.onReselect,
  });

  final List<LiquidTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  /// Tapping the tab that is already open (e.g. scroll it back to the top).
  final ValueChanged<int>? onReselect;

  @override
  State<LiquidTabBar> createState() => _LiquidTabBarState();
}

bool get _light => LumenPalette.current.brightness == Brightness.light;

class _LiquidTabBarState extends State<LiquidTabBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pos = AnimationController.unbounded(
    vsync: this,
    value: widget.index.toDouble(),
  );

  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 420,
    damping: 26,
  );

  @override
  void didUpdateWidget(covariant LiquidTabBar old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _pos.animateWith(
        SpringSimulation(
          _spring,
          _pos.value,
          widget.index.toDouble(),
          _pos.velocity,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.tabs.length;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: SizedBox(
          height: 64,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        _light
                            ? [
                              Colors.white.withValues(alpha: 0.78),
                              const Color(0xFFEDE7DB).withValues(alpha: 0.86),
                            ]
                            : [
                              const Color(0xFF2A2A2D).withValues(alpha: 0.62),
                              const Color(0xFF121214).withValues(alpha: 0.72),
                            ],
                  ),
                  border: Border.all(
                    color:
                        _light
                            ? Colors.black.withValues(alpha: 0.06)
                            : Colors.white.withValues(alpha: 0.10),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 30,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final slot = box.maxWidth / count;
                    return AnimatedBuilder(
                      animation: _pos,
                      builder: (context, _) {
                        // Stretch with speed, like a liquid drop between tabs.
                        final speed = _pos.velocity.abs().clamp(0.0, 12.0);
                        final width = slot - 10 + speed * 5.5;
                        final center = slot * (_pos.value + 0.5);
                        final squash = lerpDouble(1, 0.86, speed / 12)!;
                        return Stack(
                          children: [
                            // Top specular sheen of the glass.
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              height: 26,
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.07),
                                        Colors.white.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: center - width / 2,
                              top: 6 + (1 - squash) * 26,
                              width: width,
                              height: 52 * squash,
                              child: const _Lens(),
                            ),
                            Row(
                              children: [
                                for (var i = 0; i < count; i++)
                                  Expanded(
                                    child: _TabButton(
                                      tab: widget.tabs[i],
                                      selected: i == widget.index,
                                      onTap: () {
                                        if (i == widget.index) {
                                          HapticFeedback.selectionClick();
                                          widget.onReselect?.call(i);
                                          return;
                                        }
                                        HapticFeedback.selectionClick();
                                        widget.onChanged(i);
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Lens extends StatelessWidget {
  const _Lens();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              _light
                  ? [
                    LumenColors.accent.withValues(alpha: 0.16),
                    LumenColors.accent.withValues(alpha: 0.08),
                  ]
                  : [
                    Colors.white.withValues(alpha: 0.20),
                    Colors.white.withValues(alpha: 0.06),
                  ],
        ),
        border: Border.all(
          color:
              _light
                  ? LumenColors.accent.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.22),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: LumenColors.accent.withValues(alpha: 0.18),
            blurRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final LiquidTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82), weight: 25),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.82,
        end: 1.12,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.12,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 40,
    ),
  ]).animate(_bounce);

  @override
  void didUpdateWidget(covariant _TabButton old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) _bounce.forward(from: 0);
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.selected
            ? (_light ? LumenColors.accent : Colors.white)
            : LumenColors.muted;
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.tab.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: KeyedSubtree(
                key: ValueKey(widget.selected),
                child:
                    widget.selected
                        ? widget.tab.selectedIcon(color)
                        : widget.tab.icon(color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
