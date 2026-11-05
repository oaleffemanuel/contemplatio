import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

enum LumenButtonStyle { primary, secondary, glass }

/// Buttons in Biblia Traditio's language: solid terracotta for the main
/// action, graphite for secondary ones; a soft press-in on touch.
class LumenButton extends StatefulWidget {
  const LumenButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = LumenButtonStyle.primary,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LumenButtonStyle style;
  final bool expand;

  @override
  State<LumenButton> createState() => _LumenButtonState();
}

class _LumenButtonState extends State<LumenButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (widget.style) {
      LumenButtonStyle.primary => (LumenColors.accent, Colors.white),
      LumenButtonStyle.secondary => (
        LumenColors.surfaceHigh,
        LumenColors.ivory,
      ),
      LumenButtonStyle.glass => (
        Colors.white.withValues(alpha: 0.14),
        Colors.white,
      ),
    };
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap:
          widget.onPressed == null
              ? null
              : () {
                HapticFeedback.lightImpact();
                widget.onPressed!();
              },
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 50,
          width: widget.expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border:
                widget.style == LumenButtonStyle.glass
                    ? Border.all(color: Colors.white.withValues(alpha: 0.22))
                    : null,
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: fg, size: 19),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: LumenType.ui,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
