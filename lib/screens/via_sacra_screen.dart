import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/theme.dart';
import '../widgets/readable_width.dart';
import '../data/content_repository.dart';
import '../data/lumen_settings.dart';
import '../data/models.dart';
import '../widgets/cards.dart';
import '../widgets/glass.dart';
import '../widgets/lumen_button.dart';
import '../widgets/prayer_text.dart';
import '../widgets/sacred_image.dart';
import 'rosary_screen.dart' show RosaryScreen;

/// Via Sacra hub: St Josemaría first, then Pope Francis (2025), the
/// "A melodia do Calvário" anthology and the short Via Sacra.
class ViaSacraScreen extends StatefulWidget {
  const ViaSacraScreen({
    super.key,
    required this.repository,
    this.scrollController,
  });

  final ContentRepository repository;
  final ScrollController? scrollController;

  @override
  State<ViaSacraScreen> createState() => _ViaSacraScreenState();
}

class _ViaSacraScreenState extends State<ViaSacraScreen> {
  late final Future<(List<ViaSacraCollection>, List<ViaSacraAnthology>)> _data =
      () async {
        return (
          await widget.repository.viaSacraCollections(),
          await widget.repository.anthologies(),
        );
      }();

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.paddingOf(context).bottom + RosaryScreen.tabBarSpace;
    return FutureBuilder(
      future: _data,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.expand();
        final (collections, anthologies) = data;
        final standalone = collections.where((c) => c.group == null).toList();
        final featured = standalone.where((c) => c.kind != 'jaculatorias');
        final short = standalone.where((c) => c.kind == 'jaculatorias');

        return CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Via Sacra', style: LumenType.title(34)),
                      const SizedBox(height: 4),
                      Text(
                        'Acompanhar Jesus até o Calvário, estação por estação.',
                        style: LumenType.caption.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList.list(
                children: [
                  for (final (i, c) in featured.indexed) ...[
                    _FeatureCard(
                      collection: c,
                      image: i == 0 ? 'viacrucis_02.jpg' : 'viacrucis_11.jpg',
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
            for (final anthology in anthologies)
              SliverToBoxAdapter(
                child: _AnthologySection(
                  anthology: anthology,
                  collections:
                      collections
                          .where((c) => c.group == anthology.id)
                          .toList(),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 16),
              sliver: SliverList.list(
                children: [for (final c in short) _CompactCard(collection: c)],
              ),
            ),
          ],
        );
      },
    );
  }
}

void _openCollection(BuildContext context, ViaSacraCollection c) {
  HapticFeedback.selectionClick();
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => CollectionScreen(collection: c)),
  );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.collection, required this.image});

  final ViaSacraCollection collection;
  final String image;

  @override
  Widget build(BuildContext context) {
    final last = LumenScope.of(context).lastStation(collection.id);
    return GestureDetector(
      onTap: () => _openCollection(context, collection),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 230,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SacredImage(
                file: image,
                alignment: const Alignment(0, -0.2),
                shade: ImageShade.none,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.2, 1],
                    colors: [
                      Colors.transparent,
                      LumenColors.heroEnd.withValues(alpha: 0.96),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      collection.title.toUpperCase(),
                      style: LumenType.eyebrow(LumenColors.onHeroMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      collection.author,
                      style: LumenType.title(30, color: LumenColors.onImage),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      last > 0
                          ? 'Continuar na ${romanNumeral(last + 1)} estação'
                          : '14 estações',
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
    );
  }
}

class _AnthologySection extends StatelessWidget {
  const _AnthologySection({required this.anthology, required this.collections});

  final ViaSacraAnthology anthology;
  final List<ViaSacraCollection> collections;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COLETÂNEA', style: LumenType.section),
                const SizedBox(height: 8),
                Text(anthology.title, style: LumenType.title(28)),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    Text(
                      'org. ${anthology.organizer}',
                      style: LumenType.caption,
                    ),
                    if (anthology.instagram != null) ...[
                      GestureDetector(
                        onTap:
                            () => launchUrl(
                              Uri.parse(anthology.instagram!),
                              mode: LaunchMode.externalApplication,
                            ),
                        child: Text(
                          '@pe_albertoshintani',
                          style: LumenType.caption.copyWith(
                            color: LumenColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: collections.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                if (i == collections.length) {
                  return _ReadingsCard(anthology: anthology);
                }
                final c = collections[i];
                return _PortraitCard(
                  title: c.author,
                  subtitle: 'Via Sacra',
                  image:
                      'viacrucis_${((i * 3) % 14 + 1).toString().padLeft(2, '0')}.jpg',
                  onTap: () => _openCollection(context, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitCard extends StatelessWidget {
  const _PortraitCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 168,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SacredImage(file: image, thumbnail: true, shade: ImageShade.full),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      subtitle.toUpperCase(),
                      style: LumenType.eyebrow(
                        LumenColors.onHeroMuted,
                      ).copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: LumenType.title(22, color: LumenColors.onImage),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingsCard extends StatelessWidget {
  const _ReadingsCard({required this.anthology});

  final ViaSacraAnthology anthology;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AnthologyReadingsScreen(anthology: anthology),
            ),
          ),
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LumenColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: LumenColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(FluentIcons.book_open_24_regular, color: LumenColors.accent),
            const Spacer(),
            Text('Prefácio e leituras', style: LumenType.title(22)),
            const SizedBox(height: 6),
            Text(
              '${anthology.readings.length + 1} textos para preparar a alma',
              style: LumenType.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard({required this.collection});

  final ViaSacraCollection collection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListCard(
        image: 'viacrucis_12.jpg',
        title: 'Via Sacra breve',
        subtitle: collection.author,
        onTap: () => _openCollection(context, collection),
      ),
    );
  }
}

/// A collection: cover, opening prayer and the grid of 14 stations.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.collection});

  final ViaSacraCollection collection;

  void _open(BuildContext context, int page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => StationReader(collection: collection, initialPage: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = LumenScope.of(context);
    final last = settings.lastStation(collection.id);
    final hasIntro = collection.intro.isNotEmpty;
    final offset = hasIntro ? 1 : 0;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: ReadableWidth(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: height * 0.5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SacredImage(
                      file: collection.stations.first.image,
                      drift: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collection.title.toUpperCase(),
                            style: LumenType.eyebrow(LumenColors.onHeroMuted),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            collection.author,
                            style: LumenType.title(
                              40,
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: LumenButton(
                        expand: true,
                        icon: FluentIcons.play_24_filled,
                        onPressed:
                            () => _open(context, last > 0 ? last + offset : 0),
                        label:
                            last > 0
                                ? 'Continuar · ${romanNumeral(last + 1)} estação'
                                : (hasIntro
                                    ? 'Começar pela oração inicial'
                                    : 'Começar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (collection.source != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 4),
                  child: Text(collection.source!, style: LumenType.caption),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
                children: [
                  for (final (i, s) in collection.stations.indexed)
                    GestureDetector(
                      onTap: () => _open(context, i + offset),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            SacredImage(file: s.image, thumbnail: true),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    romanNumeral(s.number),
                                    style: LumenType.title(
                                      26,
                                      color: LumenColors.gold,
                                    ),
                                  ),
                                  Text(
                                    s.title,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: LumenType.ui,
                                      fontSize: 12.5,
                                      height: 1.3,
                                      fontWeight: FontWeight.w500,
                                      color: LumenColors.onImage,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i == last && last > 0)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: LumenColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Station by station: the painting fills the screen to be contemplated;
/// the text lives in a sheet that can be lowered (only the image) or raised.
class StationReader extends StatefulWidget {
  const StationReader({
    super.key,
    required this.collection,
    required this.initialPage,
  });

  final ViaSacraCollection collection;
  final int initialPage;

  @override
  State<StationReader> createState() => _StationReaderState();
}

class _StationReaderState extends State<StationReader> {
  late final PageController _pages = PageController(
    initialPage: widget.initialPage,
  );
  late int _page = widget.initialPage;

  List<_ReaderPage> get _all {
    final c = widget.collection;
    return [
      if (c.intro.isNotEmpty)
        _ReaderPage(
          eyebrow: 'ORAÇÃO INICIAL',
          title: c.author,
          image: c.stations.first.image,
          paragraphs: c.intro,
        ),
      for (final s in c.stations)
        _ReaderPage(
          eyebrow: '${romanNumeral(s.number)} ESTAÇÃO',
          title: s.title,
          image: s.image,
          paragraphs: s.paragraphs,
          stationIndex: s.number - 1,
        ),
      if (c.closing.isNotEmpty)
        _ReaderPage(
          eyebrow: 'ORAÇÃO FINAL',
          title: c.author,
          image: c.stations.last.image,
          paragraphs: c.closing,
        ),
    ];
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _all;
    final settings = LumenScope.of(context);
    return Scaffold(
      backgroundColor: LumenColors.ink,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: pages.length,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              final station = pages[i].stationIndex;
              if (station != null) {
                settings.setLastStation(widget.collection.id, station);
              }
              setState(() => _page = i);
            },
            itemBuilder:
                (context, i) => _ReaderPageView(
                  page: pages[i],
                  scale: settings.textScale,
                  jaculatorias: widget.collection.kind == 'jaculatorias',
                  addVersicle:
                      !pages[i].paragraphs.first.startsWith('℣') &&
                      pages[i].stationIndex != null &&
                      widget.collection.kind != 'jaculatorias',
                ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                children: [
                  Glass(
                    radius: 20,
                    tint: 0.4,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: LumenColors.onImage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        for (var i = 0; i < pages.length; i++)
                          Expanded(
                            child: Container(
                              height: 2.5,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    i <= _page
                                        ? LumenColors.gold
                                        : LumenColors.onImage.withValues(
                                          alpha: 0.22,
                                        ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ReaderPage {
  const _ReaderPage({
    required this.eyebrow,
    required this.title,
    required this.image,
    required this.paragraphs,
    this.stationIndex,
  });

  final String eyebrow;
  final String title;
  final String image;
  final List<String> paragraphs;
  final int? stationIndex;
}

class _ReaderPageView extends StatefulWidget {
  const _ReaderPageView({
    required this.page,
    required this.scale,
    required this.jaculatorias,
    required this.addVersicle,
  });

  final _ReaderPage page;
  final double scale;
  final bool jaculatorias;
  final bool addVersicle;

  @override
  State<_ReaderPageView> createState() => _ReaderPageViewState();
}

class _ReaderPageViewState extends State<_ReaderPageView> {
  final DraggableScrollableController _sheet = DraggableScrollableController();
  static const _min = 0.16, _initial = 0.42, _max = 0.94;

  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  /// Tapping the painting lowers the sheet to contemplate, or raises it back.
  void _toggle() {
    if (!_sheet.isAttached) return;
    final target = _sheet.size > _min + 0.05 ? _min : _initial;
    _sheet.animateTo(
      target,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final paragraphs = [
      if (widget.addVersicle)
        '℣ Nós vos adoramos, ó Cristo, e vos bendizemos.\n'
            '℟ Porque pela vossa santa Cruz remistes o mundo.',
      ...widget.page.paragraphs,
    ];
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: SacredImage(
            file: widget.page.image,
            drift: true,
            shade: ImageShade.none,
          ),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  LumenColors.imageInk.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: const [0, 0.18, 1],
              ),
            ),
          ),
        ),
        DraggableScrollableSheet(
          controller: _sheet,
          minChildSize: _min,
          initialChildSize: _initial,
          maxChildSize: _max,
          snap: true,
          snapSizes: const [_initial],
          builder:
              (context, scroll) => Container(
                decoration: BoxDecoration(
                  color: LumenColors.ink.withValues(alpha: 0.94),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border(top: BorderSide(color: LumenColors.line)),
                ),
                child: ListView(
                  controller: scroll,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    MediaQuery.paddingOf(context).bottom + 32,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: LumenColors.ivory.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.page.eyebrow,
                      style: LumenType.eyebrow(
                        LumenColors.accentFor('passion'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.page.title,
                      style: LumenType.title(30 * widget.scale),
                    ),
                    const SizedBox(height: 20),
                    PrayerText(
                      paragraphs: paragraphs,
                      scale: widget.scale,
                      jaculatorias: widget.jaculatorias,
                    ),
                  ],
                ),
              ),
        ),
      ],
    );
  }
}

/// Preface and introductory readings of an anthology.
class AnthologyReadingsScreen extends StatelessWidget {
  const AnthologyReadingsScreen({super.key, required this.anthology});

  final ViaSacraAnthology anthology;

  @override
  Widget build(BuildContext context) {
    final articles = [anthology.preface, ...anthology.readings];
    return Scaffold(
      appBar: AppBar(title: Text(anthology.title)),
      body: ReadableWidth(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          itemCount: articles.length,
          separatorBuilder: (_, _) => const Divider(height: 28),
          itemBuilder: (context, i) {
            final a = articles[i];
            return InkWell(
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ArticleScreen(article: a),
                    ),
                  ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i == 0 ? 'PREFÁCIO' : 'LEITURA $i',
                      style: LumenType.eyebrow(LumenColors.gold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.title.replaceFirst('Prefácio: ', ''),
                      style: LumenType.title(24),
                    ),
                    if (a.author.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(a.author, style: LumenType.caption),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final scale = LumenScope.of(context).textScale;
    return Scaffold(
      appBar: AppBar(),
      body: ReadableWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 48),
          children: [
            Text(
              article.title.replaceFirst('Prefácio: ', ''),
              style: LumenType.title(32),
            ),
            if (article.author.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(article.author, style: LumenType.caption),
            ],
            const SizedBox(height: 24),
            PrayerText(paragraphs: article.paragraphs, scale: scale),
          ],
        ),
      ),
    );
  }
}
