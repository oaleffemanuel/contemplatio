import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/theme.dart';
import '../data/content_repository.dart';
import '../data/lumen_settings.dart';
import '../data/models.dart';
import '../widgets/lumen_button.dart';
import '../widgets/sacred_image.dart';

/// "Contemplar os mistérios": a short guide built on Rosarium Virginis
/// Mariae, opened by the Transfiguration — the scene the letter proposes as
/// the icon of Christian contemplation (RVM 9).
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key, required this.repository});

  final ContentRepository repository;

  static void open(BuildContext context, ContentRepository repository) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GuideScreen(repository: repository),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final scale = LumenScope.of(context).textScale;
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: FutureBuilder<Article>(
        future: repository.contemplationGuide(),
        builder: (context, snapshot) {
          final guide = snapshot.data;
          if (guide == null) return const SizedBox.expand();
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: height * 0.52,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const SacredImage(
                        file: 'luminous_4_transfiguration_1.jpg',
                        alignment: Alignment(0, -0.6),
                        drift: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GUIA',
                              style: LumenType.eyebrow(LumenColors.onHeroMuted),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              guide.title,
                              style: LumenType.title(
                                38,
                                color: LumenColors.onImage,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              guide.author,
                              style: LumenType.caption.copyWith(
                                color: LumenColors.onHeroMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  22,
                  8,
                  22,
                  MediaQuery.paddingOf(context).bottom + 32,
                ),
                sliver: SliverList.list(
                  children: [
                    for (final p in guide.paragraphs) _Paragraph(p, scale),
                    if (guide.sourceUrl != null) ...[
                      const SizedBox(height: 12),
                      LumenButton(
                        label: 'Ler a carta completa',
                        icon: FluentIcons.open_24_regular,
                        style: LumenButtonStyle.secondary,
                        expand: true,
                        onPressed:
                            () => launchUrl(
                              Uri.parse(guide.sourceUrl!),
                              mode: LaunchMode.externalApplication,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text, this.scale);

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (text.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(text.substring(2), style: LumenType.title(26 * scale)),
      );
    }
    if (text.startsWith('> ')) {
      final match = RegExp(
        r'^(.*) \((RVM \d+)\)$',
      ).firstMatch(text.substring(2));
      final quote = match?.group(1) ?? text.substring(2);
      final ref = match?.group(2);
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: LumenColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: LumenColors.accent, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '“$quote”',
              style: LumenType.body(
                scale,
              ).copyWith(fontStyle: FontStyle.italic, fontSize: 18 * scale),
            ),
            if (ref != null) ...[
              const SizedBox(height: 8),
              Text(
                ref.replaceFirst('RVM', 'Rosarium Virginis Mariae,'),
                style: LumenType.caption.copyWith(fontSize: 12),
              ),
            ],
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(text, style: LumenType.body(scale)),
    );
  }
}
