import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../app/theme.dart';
import '../data/content_repository.dart';
import '../data/lumen_settings.dart';
import '../data/models.dart';
import '../widgets/cards.dart';
import '../widgets/lumen_icons.dart';
import '../widgets/lumen_button.dart';
import '../widgets/sacred_image.dart';
import 'rosary_screen.dart';
import 'guide_screen.dart';
import 'saints_screen.dart';
import 'via_sacra_screen.dart';

/// "Início", in Biblia Traditio's layout: greeting, today's mysteries as the
/// hero, quick shortcuts and where to continue.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.onOpenTab,
    this.scrollController,
  });

  final ContentRepository repository;
  final ValueChanged<int> onOpenTab;
  final ScrollController? scrollController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<
    (List<MysterySet>, List<ViaSacraCollection>, List<SaintWork>)
  >
  _data = _load();

  Future<(List<MysterySet>, List<ViaSacraCollection>, List<SaintWork>)>
  _load() async => (
    await widget.repository.mysterySets(),
    await widget.repository.viaSacraCollections(),
    await widget.repository.saintWorks(),
  );

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  static String _date(DateTime d) {
    const weekdays = [
      'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', //
      'Sexta-feira', 'Sábado', 'Domingo',
    ];
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', //
      'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return '${weekdays[d.weekday - 1]}, ${d.day} de ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final settings = LumenScope.of(context);
    final bottom =
        MediaQuery.paddingOf(context).bottom + RosaryScreen.tabBarSpace;
    return FutureBuilder(
      future: _data,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.expand();
        final (sets, collections, saints) = data;
        final now = DateTime.now();
        final today = sets.firstWhere(
          (s) => s.id == mysterySetForWeekday(now.weekday),
        );
        final started =
            collections.where((c) => settings.lastStation(c.id) > 0).toList();

        return SafeArea(
          bottom: false,
          child: ListView(
            controller: widget.scrollController,
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottom + 12),
            children: [
              Text(
                _greeting(),
                style: LumenType.caption.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(_date(now), style: LumenType.title(32)),
              const SizedBox(height: 20),
              _TodayHero(
                set: today,
                onPray:
                    () => RosaryScreen.open(
                      context,
                      widget.repository,
                      setId: today.id,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: QuickCard(
                      icon: RosaryIcon(color: LumenColors.accent, size: 22),
                      label: 'Mistérios',
                      onTap: () => widget.onOpenTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickCard(
                      icon: CrossIcon(color: LumenColors.accent, size: 22),
                      label: 'Via Sacra',
                      onTap: () => widget.onOpenTab(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickCard(
                      icon: Icon(
                        FluentIcons.book_open_24_regular,
                        color: LumenColors.accent,
                        size: 22,
                      ),
                      label: 'Guia',
                      onTap: () => GuideScreen.open(context, widget.repository),
                    ),
                  ),
                ],
              ),
              if (started.isNotEmpty) ...[
                const SectionLabel('Continuar'),
                for (final c in started) ...[
                  ListCard(
                    image: c.stations[settings.lastStation(c.id)].image,
                    title: c.author,
                    subtitle:
                        'Via Sacra · ${romanNumeral(settings.lastStation(c.id) + 1)} estação',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CollectionScreen(collection: c),
                          ),
                        ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
              const SectionLabel('Com os santos'),
              for (final w in saints) ...[
                ListCard(
                  image: 'joyful_1_annunciation_1.jpg',
                  title: '${w.title} · ${w.author}',
                  subtitle: 'Um texto para cada um dos 20 mistérios',
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder:
                              (_) => SaintWorkScreen(
                                repository: widget.repository,
                                work: w,
                              ),
                        ),
                      ),
                ),
                const SizedBox(height: 10),
              ],
              const SectionLabel('Para contemplar'),
              ListCard(
                image: collections.first.stations.first.image,
                title: 'Via Sacra · ${collections.first.author}',
                subtitle: '14 estações para acompanhar Jesus',
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder:
                            (_) =>
                                CollectionScreen(collection: collections.first),
                      ),
                    ),
              ),
              const SizedBox(height: 10),
              for (final s in sets.where((s) => s.id != today.id)) ...[
                ListCard(
                  image: s.mysteries.first.image,
                  title: s.title,
                  subtitle: daysForSet(s.id),
                  onTap:
                      () => RosaryScreen.open(
                        context,
                        widget.repository,
                        setId: s.id,
                      ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Today's mysteries: the painting under a terracotta gradient, as in
/// Biblia Traditio's Gospel hero.
class _TodayHero extends StatelessWidget {
  const _TodayHero({required this.set, required this.onPray});

  final MysterySet set;
  final VoidCallback onPray;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPray,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 340,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SacredImage(
                file: set.mysteries.first.image,
                alignment: const Alignment(0, -0.3),
                shade: ImageShade.none,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.45, 1],
                    colors: [
                      Colors.transparent,
                      LumenColors.heroStart.withValues(alpha: 0.55),
                      LumenColors.heroEnd.withValues(alpha: 0.97),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'MISTÉRIOS DE HOJE',
                      style: LumenType.eyebrow(LumenColors.onHeroMuted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      set.shortTitle,
                      style: LumenType.title(38, color: LumenColors.onImage),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      set.mysteries.map((m) => m.name).take(3).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LumenType.caption.copyWith(
                        color: LumenColors.onHeroMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LumenButton(
                      label: 'Começar',
                      icon: FluentIcons.play_24_filled,
                      onPressed: onPray,
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
