import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../data/content_repository.dart';
import '../data/lumen_settings.dart';
import '../data/models.dart';
import '../widgets/glass.dart';
import '../widgets/sacred_image.dart';

/// Contemplation mode: the paintings are the prayer. Swipe sideways between
/// the five mysteries; tap the right or left edge for the next or previous
/// work of the same mystery (like stories); tap the middle to hide every
/// word and stay with the image.
class RosaryScreen extends StatefulWidget {
  const RosaryScreen({
    super.key,
    required this.repository,
    this.initialSetId,
    this.now,
  });

  final ContentRepository repository;
  final String? initialSetId;

  /// Injectable clock for tests.
  final DateTime Function()? now;

  /// Space reserved at the bottom of tab screens for the floating tab bar.
  static const tabBarSpace = 88.0;

  static Future<void> open(
    BuildContext context,
    ContentRepository repository, {
    String? setId,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder:
            (_, _, _) =>
                RosaryScreen(repository: repository, initialSetId: setId),
        transitionsBuilder:
            (_, a, _, child) => FadeTransition(
              opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
              child: ScaleTransition(
                scale: Tween(begin: 1.04, end: 1.0).animate(
                  CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            ),
      ),
    );
  }

  @override
  State<RosaryScreen> createState() => _RosaryScreenState();
}

class _RosaryScreenState extends State<RosaryScreen> {
  late final Future<(List<MysterySet>, Map<String, ArtworkCredit>)> _data =
      _load();
  final PageController _pages = PageController();
  String? _setId;
  int _mystery = 0;

  /// Image shown for each mystery, so coming back keeps your place.
  final Map<int, int> _imageByMystery = {};
  bool _immersive = false;

  Future<(List<MysterySet>, Map<String, ArtworkCredit>)> _load() async => (
    await widget.repository.mysterySets(),
    await widget.repository.artworkCredits(),
  );

  DateTime get _today => (widget.now ?? DateTime.now)();
  String get _todaySetId => mysterySetForWeekday(_today.weekday);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _selectSet(String id) {
    if (id == _setId) return;
    LumenScope.of(context).chooseSet(id, _today);
    setState(() {
      _setId = id;
      _mystery = 0;
      _imageByMystery.clear();
    });
    if (_pages.hasClients) _pages.jumpToPage(0);
  }

  void _step(MysterySet set, int delta) {
    final images = set.mysteries[_mystery].images;
    final current = _imageByMystery[_mystery] ?? 0;
    final next = current + delta;
    if (next >= 0 && next < images.length) {
      HapticFeedback.selectionClick();
      setState(() => _imageByMystery[_mystery] = next);
      return;
    }
    // Past the last work, move on to the next mystery (and back).
    final target = _mystery + (delta > 0 ? 1 : -1);
    if (target >= 0 && target < set.mysteries.length) {
      _pages.animateToPage(
        target,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _openSetPicker(List<MysterySet> sets) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) =>
              _SetPicker(sets: sets, selectedId: _setId!, todayId: _todaySetId),
    );
    if (chosen != null) _selectSet(chosen);
  }

  // Over the painting the composition matters more than size.
  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(
    maxScaleFactor: 1.15,
    child: _build(context),
  );

  Widget _build(BuildContext context) {
    final settings = LumenScope.of(context);
    return Scaffold(
      backgroundColor: LumenColors.imageInk,
      body: FutureBuilder(
        future: _data,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) return const SizedBox.expand();
          final (sets, credits) = data;
          _setId ??=
              widget.initialSetId ??
              settings.chosenSetFor(_today) ??
              _todaySetId;
          final set = sets.firstWhere(
            (s) => s.id == _setId,
            orElse: () => sets.first,
          );
          final accent = LumenColors.accentFor(set.id);
          final mystery = set.mysteries[_mystery];
          final imageIndex = _imageByMystery[_mystery] ?? 0;

          return Stack(
            children: [
              PageView.builder(
                controller: _pages,
                itemCount: set.mysteries.length,
                onPageChanged: (i) => setState(() => _mystery = i),
                itemBuilder:
                    (context, i) => _MysteryPage(
                      key: ValueKey('${set.id}-$i'),
                      setId: set.id,
                      onSelectImage: (img) {
                        HapticFeedback.selectionClick();
                        setState(() => _imageByMystery[i] = img);
                      },
                      mystery: set.mysteries[i],
                      imageIndex: _imageByMystery[i] ?? 0,
                      credits: credits,
                      accent: accent,
                      immersive: _immersive,
                    ),
              ),
              // Tap zones: left/right edges step through the works, the
              // middle hides or shows the words. Horizontal drags still
              // reach the PageView underneath.
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: MediaQuery.sizeOf(context).height * 0.42,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _step(set, -1),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => setState(() => _immersive = !_immersive),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _step(set, 1),
                      ),
                    ),
                  ],
                ),
              ),
              if (!_immersive && mystery.images.length > 1)
                for (final left in [true, false])
                  Positioned(
                    left: left ? 4 : null,
                    right: left ? null : 4,
                    top: MediaQuery.sizeOf(context).height * 0.3,
                    child: IgnorePointer(
                      child: Icon(
                        left
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        size: 34,
                        color: LumenColors.onImage.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Glass(
                            radius: 20,
                            tint: 0.35,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: LumenColors.onImage,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _StoryProgress(
                              count: mystery.images.length,
                              index: imageIndex,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 260),
                        opacity: _immersive ? 0 : 1,
                        child: IgnorePointer(
                          ignoring: _immersive,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(6, 18, 6, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_mystery + 1} DE ${set.mysteries.length}'
                                  ' · ${set.title.toUpperCase()}',
                                  style: LumenType.eyebrow(
                                    LumenColors.onImage.withValues(alpha: 0.75),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _openSetPicker(sets),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Trocar mistérios',
                                        style: LumenType.imageCaption.copyWith(
                                          color: accent,
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: accent,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MysteryPage extends StatefulWidget {
  const _MysteryPage({
    super.key,
    required this.setId,
    required this.mystery,
    required this.imageIndex,
    required this.onSelectImage,
    required this.credits,
    required this.accent,
    required this.immersive,
  });

  final String setId;
  final Mystery mystery;
  final int imageIndex;
  final ValueChanged<int> onSelectImage;
  final Map<String, ArtworkCredit> credits;
  final Color accent;
  final bool immersive;

  @override
  State<_MysteryPage> createState() => _MysteryPageState();
}

class _MysteryPageState extends State<_MysteryPage> {
  int? _jaculatoria;

  void _nextJaculatoria() {
    final list = widget.mystery.meditations;
    if (list.length < 2) return;
    HapticFeedback.selectionClick();
    final next = ((_jaculatoria ?? 0) + 1) % list.length;
    LumenScope.of(
      context,
    ).setMeditationIndex(widget.setId, widget.mystery.number, next);
    setState(() => _jaculatoria = next);
  }

  @override
  Widget build(BuildContext context) {
    final settings = LumenScope.of(context);
    final scale = settings.textScale;
    final mystery = widget.mystery;
    final images = mystery.images;
    final current = widget.imageIndex.clamp(0, images.length - 1);
    final file = images[current];
    final jaculatorias = mystery.meditations;
    _jaculatoria ??= settings
        .meditationIndex(widget.setId, mystery.number)
        .clamp(0, jaculatorias.isEmpty ? 0 : jaculatorias.length - 1);
    final credit = widget.credits[file];
    final accent = widget.accent;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          switchInCurve: Curves.easeOut,
          child: SacredImage(
            key: ValueKey('$file-${widget.immersive}'),
            file: file,
            drift: true,
            shade: widget.immersive ? ImageShade.none : ImageShade.bottom,
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          opacity: widget.immersive ? 0 : 1,
          child: IgnorePointer(
            ignoring: widget.immersive,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                MediaQuery.paddingOf(context).bottom + 22,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${mystery.number}º MISTÉRIO',
                    style: LumenType.eyebrow(accent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mystery.name,
                    style: LumenType.title(
                      36 * scale,
                      color: LumenColors.onImage,
                    ),
                  ),
                  if (jaculatorias.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _nextJaculatoria,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            child: Text(
                              '“${jaculatorias[_jaculatoria!]}”',
                              key: ValueKey(_jaculatoria),
                              style: LumenType.meditation(scale),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (var i = 0; i < jaculatorias.length; i++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 5),
                                  width: i == _jaculatoria ? 14 : 5,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color:
                                        i == _jaculatoria
                                            ? accent
                                            : LumenColors.onImage.withValues(
                                              alpha: 0.3,
                                            ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              Text(
                                'toque para outra jaculatória',
                                style: LumenType.imageCaption.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (images.length > 1) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder:
                            (context, i) => GestureDetector(
                              onTap: () => widget.onSelectImage(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color:
                                        i == current
                                            ? accent
                                            : Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                    width: i == current ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Opacity(
                                    opacity: i == current ? 1 : 0.6,
                                    child: SacredImage(
                                      file: images[i],
                                      shade: ImageShade.none,
                                      thumbnail: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ],
                  if (credit != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      credit.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LumenType.imageCaption.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryProgress extends StatelessWidget {
  const _StoryProgress({
    required this.count,
    required this.index,
    required this.color,
  });

  final int count;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2.5,
              margin: EdgeInsets.only(right: i == count - 1 ? 0 : 5),
              decoration: BoxDecoration(
                color:
                    i <= index
                        ? color
                        : LumenColors.onImage.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}

class _SetPicker extends StatelessWidget {
  const _SetPicker({
    required this.sets,
    required this.selectedId,
    required this.todayId,
  });

  final List<MysterySet> sets;
  final String selectedId;
  final String todayId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161617),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.paddingOf(context).bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF26262A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'Mistérios',
              style: LumenType.title(28, color: LumenColors.onImage),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
            children: [
              for (final set in sets)
                _SetCard(
                  set: set,
                  selected: set.id == selectedId,
                  isToday: set.id == todayId,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetCard extends StatelessWidget {
  const _SetCard({
    required this.set,
    required this.selected,
    required this.isToday,
  });

  final MysterySet set;
  final bool selected;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(set.id),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SacredImage(file: set.mysteries.first.image, thumbnail: true),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? LumenColors.accent : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: LumenColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'HOJE',
                        style: LumenType.eyebrow(
                          Colors.white,
                        ).copyWith(fontSize: 9.5, letterSpacing: 1),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    set.shortTitle,
                    style: LumenType.title(26, color: LumenColors.onImage),
                  ),
                  const SizedBox(height: 2),
                  Text(daysForSet(set.id), style: LumenType.imageCaption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
