import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import 'sacred_image.dart';

/// Section label in Biblia Traditio's style ("VIA SACRA").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: LumenType.section)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Graphite card with a press-in animation.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

/// Row card: a painting (or icon) tile, title, subtitle and chevron — the
/// secondary card of Biblia Traditio's home.
class ListCard extends StatelessWidget {
  const ListCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.image,
    this.icon,
    this.badge,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? image;
  final Widget? icon;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LumenColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 56,
                child:
                    image != null
                        ? SacredImage(
                          file: image!,
                          shade: ImageShade.none,
                          thumbnail: true,
                        )
                        : ColoredBox(
                          color: LumenColors.accentSoft,
                          child: Center(child: icon),
                        ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(title, style: LumenType.cardTitle)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        TagBadge(badge!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: LumenType.caption),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: LumenColors.faint),
          ],
        ),
      ),
    );
  }
}

class TagBadge extends StatelessWidget {
  const TagBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: LumenColors.accentSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: LumenType.ui,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: LumenColors.accent,
        ),
      ),
    );
  }
}

/// Small square shortcut (Biblia Traditio's quick card).
class QuickCard extends StatelessWidget {
  const QuickCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LumenColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            icon,
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: LumenType.ui,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: LumenColors.ivory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
