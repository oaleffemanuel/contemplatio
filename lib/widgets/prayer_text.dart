import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Renders Via Sacra paragraphs with a small devotional markup:
///   `℣ …` / `℟ …`   versicle / response (also several lines in one block)
///   `# …`           scripture reference ("Do Evangelho segundo São Lucas…")
///   `> …`           scripture passage (italic)
///   `*…*`           rubric
///   `… ℟ …`         litany line: invocation, then the people's response
///   multi-line      verse stanza (kept as written)
class PrayerText extends StatelessWidget {
  const PrayerText({
    super.key,
    required this.paragraphs,
    required this.scale,
    this.jaculatorias = false,
  });

  final List<String> paragraphs;
  final double scale;
  final bool jaculatorias;

  static const _symbolFallback = ['Apple Symbols', 'Noto Sans Symbols'];

  @override
  Widget build(BuildContext context) {
    final body = LumenType.body(scale);
    final red = LumenColors.accentFor('sorrowful');
    final children = <Widget>[];
    for (final raw in paragraphs) {
      final p = raw.trim();
      if (p.isEmpty) continue;
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _block(p, body, red),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _block(String p, TextStyle body, Color red) {
    if (jaculatorias) {
      return Text(
        p,
        style: body.copyWith(
          fontFamily: LumenType.serif,
          fontStyle: FontStyle.italic,
          fontSize: 22 * scale,
          height: 1.35,
        ),
      );
    }
    if (p.startsWith('# ')) {
      return Text(
        p.substring(2).toUpperCase(),
        style: LumenType.eyebrow(LumenColors.gold).copyWith(fontSize: 10.5),
      );
    }
    if (p.startsWith('> ')) {
      return Container(
        padding: const EdgeInsets.only(left: 14),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: LumenColors.gold, width: 1.2)),
        ),
        child: Text(
          p.substring(2),
          style: body.copyWith(fontStyle: FontStyle.italic),
        ),
      );
    }
    if (p.startsWith('*') && p.endsWith('*') && p.length > 2) {
      return Text(
        p.substring(1, p.length - 1),
        style: body.copyWith(
          fontStyle: FontStyle.italic,
          color: red,
          fontSize: body.fontSize! * 0.9,
        ),
      );
    }
    final lines = p.split('\n');
    final isRoles = lines.every((l) => l.startsWith('℣') || l.startsWith('℟'));
    if (isRoles) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24 * scale,
                    child: Text(
                      l.substring(0, 1),
                      style: body.copyWith(
                        color: red,
                        fontWeight: FontWeight.w500,
                        fontFamilyFallback: _symbolFallback,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l.substring(1).trim(),
                      style:
                          l.startsWith('℟')
                              ? body.copyWith(fontWeight: FontWeight.w500)
                              : body,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    final litany = p.indexOf(' ℟ ');
    if (litany > 0) {
      return Text.rich(
        TextSpan(
          style: body,
          children: [
            TextSpan(text: p.substring(0, litany + 1)),
            TextSpan(
              text: '℟ ',
              style: TextStyle(color: red, fontFamilyFallback: _symbolFallback),
            ),
            TextSpan(
              text: p.substring(litany + 3),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    return Text(p, style: body);
  }
}
