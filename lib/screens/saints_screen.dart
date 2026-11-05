import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/content_repository.dart';
import '../data/lumen_settings.dart';
import '../data/models.dart';
import '../widgets/cards.dart';
import '../widgets/sacred_image.dart';

/// "Com os santos": what the saints wrote on each mystery, to read apart
/// from the contemplation screen. Each text is illustrated by the main
/// painting of its mystery.
class SaintWorkScreen extends StatefulWidget {
  const SaintWorkScreen({
    super.key,
    required this.repository,
    required this.work,
  });

  final ContentRepository repository;
  final SaintWork work;

  @override
  State<SaintWorkScreen> createState() => _SaintWorkScreenState();
}

class _SaintWorkScreenState extends State<SaintWorkScreen> {
  late final Future<List<MysterySet>> _sets = widget.repository.mysterySets();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<MysterySet>>(
        future: _sets,
        builder: (context, snapshot) {
          final sets = snapshot.data;
          if (sets == null) return const SizedBox.expand();
          return ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.paddingOf(context).bottom + 24,
            ),
            children: [
              Text(widget.work.author.toUpperCase(), style: LumenType.section),
              const SizedBox(height: 6),
              Text(widget.work.title, style: LumenType.title(34)),
              const SizedBox(height: 6),
              Text(
                widget.work.description,
                style: LumenType.caption.copyWith(fontSize: 14),
              ),
              for (final set in sets) ...[
                SectionLabel(set.title),
                for (final e in widget.work.entries.where(
                  (e) => e.setId == set.id,
                )) ...[
                  ListCard(
                    image: set.mysteries[e.mystery - 1].image,
                    title: e.title,
                    subtitle: '${e.mystery}º mistério',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder:
                                (_) => SaintReadingScreen(
                                  work: widget.work,
                                  entry: e,
                                  image: set.mysteries[e.mystery - 1].image,
                                  setTitle: set.title,
                                ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class SaintReadingScreen extends StatelessWidget {
  const SaintReadingScreen({
    super.key,
    required this.work,
    required this.entry,
    required this.image,
    required this.setTitle,
  });

  final SaintWork work;
  final SaintEntry entry;
  final String image;
  final String setTitle;

  @override
  Widget build(BuildContext context) {
    final scale = LumenScope.of(context).textScale;
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: height * 0.42,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SacredImage(file: image, drift: true),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${setTitle.toUpperCase()} · ${entry.mystery}º',
                          style: LumenType.eyebrow(LumenColors.onHeroMuted),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.title,
                          style: LumenType.title(
                            34,
                            color: LumenColors.onImage,
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
                for (final p in entry.paragraphs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(p, style: LumenType.body(scale)),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${work.author} · ${work.title}',
                  style: LumenType.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
