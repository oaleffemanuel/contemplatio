import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/content_repository.dart';
import '../data/models.dart';
import '../widgets/cards.dart';
import '../widgets/sacred_image.dart';
import 'guide_screen.dart';
import 'rosary_screen.dart';

/// Rosário tab: the four sets, each opening the full-screen prayer mode.
class RosarySetsScreen extends StatefulWidget {
  const RosarySetsScreen({
    super.key,
    required this.repository,
    this.scrollController,
  });

  final ContentRepository repository;
  final ScrollController? scrollController;

  @override
  State<RosarySetsScreen> createState() => _RosarySetsScreenState();
}

class _RosarySetsScreenState extends State<RosarySetsScreen> {
  late final Future<List<MysterySet>> _sets = widget.repository.mysterySets();

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.paddingOf(context).bottom + RosaryScreen.tabBarSpace;
    final todayId = mysterySetForWeekday(DateTime.now().weekday);
    return FutureBuilder<List<MysterySet>>(
      future: _sets,
      builder: (context, snapshot) {
        final sets = snapshot.data;
        if (sets == null) return const SizedBox.expand();
        return SafeArea(
          bottom: false,
          child: ListView(
            controller: widget.scrollController,
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottom + 12),
            children: [
              Text('Mistérios', style: LumenType.title(34)),
              const SizedBox(height: 4),
              Text(
                'Contemple a vida de Cristo com os olhos de Maria.',
                style: LumenType.caption.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 18),
              ListCard(
                image: 'luminous_4_transfiguration_1.jpg',
                title: 'Contemplar os mistérios',
                subtitle: 'Guia a partir da Rosarium Virginis Mariae',
                onTap: () => GuideScreen.open(context, widget.repository),
              ),
              for (final set in sets) ...[
                SectionLabel(
                  set.title,
                  trailing: set.id == todayId ? const TagBadge('hoje') : null,
                ),
                _SetBanner(
                  set: set,
                  onTap:
                      () => RosaryScreen.open(
                        context,
                        widget.repository,
                        setId: set.id,
                      ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SetBanner extends StatelessWidget {
  const _SetBanner({required this.set, required this.onTap});

  final MysterySet set;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: LumenColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SizedBox(
              height: 92,
              child: Row(
                children: [
                  for (final m in set.mysteries)
                    Expanded(
                      child: SacredImage(
                        file: m.image,
                        shade: ImageShade.none,
                        thumbnail: true,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          set.mysteries.map((m) => m.name).join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: LumenType.caption.copyWith(
                            color: LumenColors.ivory,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(daysForSet(set.id), style: LumenType.caption),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: LumenColors.faint),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
