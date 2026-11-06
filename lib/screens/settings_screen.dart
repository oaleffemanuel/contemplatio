import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../app/theme.dart';
import '../widgets/readable_width.dart';
import '../data/content_repository.dart';
import '../data/models.dart';
import 'guide_screen.dart';
import 'onboarding_screen.dart';
import 'rosary_screen.dart' show RosaryScreen;
import '../data/lumen_settings.dart';
import '../widgets/lumen_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.repository,
    this.scrollController,
  });

  final ContentRepository repository;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final settings = LumenScope.of(context);
    final bottom =
        MediaQuery.paddingOf(context).bottom + RosaryScreen.tabBarSpace;
    return SafeArea(
      bottom: false,
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(20, 18, 20, bottom + 16),
        children: [
          Text('Ajustes', style: LumenType.title(34)),
          const SizedBox(height: 24),
          _Group(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tamanho do texto',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '“Senhor, ensina-nos a rezar.”',
                      style: LumenType.meditation(
                        settings.textScale * 0.85,
                        color: LumenColors.ivory,
                      ),
                    ),
                    Slider(
                      value: settings.textScale,
                      min: 0.85,
                      max: 1.35,
                      divisions: 10,
                      onChanged: (v) => settings.textScale = v,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Group(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tema',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: LumenColors.accent,
                          selectedForegroundColor: Colors.white,
                          foregroundColor: LumenColors.ivory,
                          side: BorderSide(color: LumenColors.line),
                        ),
                        segments: const [
                          ButtonSegment(
                            value: 'dark',
                            label: _SegmentLabel('Escuro'),
                          ),
                          ButtonSegment(
                            value: 'light',
                            label: _SegmentLabel('Claro'),
                          ),
                          ButtonSegment(
                            value: 'system',
                            label: _SegmentLabel('Automático'),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (v) => settings.themeMode = v.first,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Group(
            children: [
              _Row(
                icon: Icons.waving_hand_outlined,
                label: 'Ver a introdução',
                onTap:
                    () => _push(
                      context,
                      OnboardingScreen(
                        onDone: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
              _Row(
                icon: Icons.menu_book_outlined,
                label: 'Contemplar os mistérios',
                onTap: () => GuideScreen.open(context, repository),
              ),
              _Row(
                icon: Icons.favorite_border_rounded,
                label: 'Créditos e obras',
                onTap:
                    () => _push(context, CreditsScreen(repository: repository)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Donations go through Pix on WhatsApp. App Store guideline 3.1.1 only
          // allows tips via in-app purchase, so the appeal is Android-only; iOS
          // keeps the plain contact row.
          if (defaultTargetPlatform == TargetPlatform.android) ...[
            const _SupportCard(),
            const SizedBox(height: 16),
          ],
          _Group(
            children: [
              _Row(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Falar no WhatsApp',
                onTap:
                    () => openWhatsApp(
                      context,
                      'Olá! Escrevo sobre o app Lumen.',
                    ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'Lumen · contemplar os mistérios de Cristo',
              style: LumenType.caption,
            ),
          ),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

/// Developer's WhatsApp (+55 31 97596-5032), shared with Biblia Traditio.
const _whatsAppPhone = '5531975965032';

Future<void> openWhatsApp(BuildContext context, String message) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final uri = Uri.parse(
    'https://wa.me/$_whatsAppPhone?text=${Uri.encodeComponent(message)}',
  );
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LumenColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('APOIE O LUMEN', style: LumenType.section),
            const SizedBox(height: 10),
            Text(
              'O Lumen é gratuito e sem anúncios. Manter o app publicado nas '
              'lojas tem um custo todo ano. Se ele te ajuda a rezar, qualquer '
              'valor ajuda.',
              style: LumenType.body(1.0, color: LumenColors.ivory),
            ),
            const SizedBox(height: 16),
            LumenButton(
              label: 'Doar via Pix',
              icon: Icons.favorite_rounded,
              expand: true,
              onPressed:
                  () => openWhatsApp(
                    context,
                    'Olá! Quero ajudar a manter o Lumen publicado. '
                    'Pode me mandar a chave Pix?',
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LumenColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 56),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Icon(icon, color: LumenColors.accent, size: 22),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right_rounded, color: LumenColors.muted),
      onTap: onTap,
    );
  }
}

/// Texts, anthology, paintings and fonts.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key, required this.repository});

  final ContentRepository repository;

  Future<
    (List<ViaSacraAnthology>, List<ViaSacraCollection>, List<ArtworkCredit>)
  >
  _load() async {
    // One line per distinct work, sorted by artist.
    final seen = <String>{};
    final images =
        (await repository.artworkCredits()).values
            .where((c) => seen.add('${c.artist}|${c.title}'))
            .toList()
          ..sort((a, b) => a.artist.compareTo(b.artist));
    return (
      await repository.anthologies(),
      await repository.viaSacraCollections(),
      images,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créditos')),
      body: ReadableWidth(
        child: FutureBuilder(
          future: _load(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) return const SizedBox.expand();
            final (anthologies, collections, images) = data;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                for (final a in anthologies) ...[
                  Text('COLETÂNEA', style: LumenType.section),
                  const SizedBox(height: 6),
                  Text(a.title, style: LumenType.title(26)),
                  Text(
                    'Organização do ${a.organizer}. As Vias Sacras de Santo '
                    'Afonso, Newman, Madre Teresa, Ernestina de Champourcin e '
                    'Frei Asinello vêm desta coletânea.',
                    style: LumenType.caption.copyWith(fontSize: 13.5),
                  ),
                  if (a.instagram != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: LumenColors.accent,
                        ),
                        onPressed:
                            () => launchUrl(
                              Uri.parse(a.instagram!),
                              mode: LaunchMode.externalApplication,
                            ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const Text('@pe_albertoshintani no Instagram'),
                      ),
                    ),
                  const Divider(height: 32),
                ],
                Text('TEXTOS', style: LumenType.section),
                const SizedBox(height: 8),
                for (final c in collections.where((c) => c.group == null))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${c.title} — ${c.author}'
                      '${c.source != null ? '\n${c.source}' : ''}',
                      style: LumenType.caption.copyWith(fontSize: 13.5),
                    ),
                  ),
                const Divider(height: 32),
                Text('PINTURAS', style: LumenType.section),
                const SizedBox(height: 8),
                if (images.isEmpty)
                  Text('Em breve.', style: LumenType.caption)
                else
                  for (final c in images)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${c.artist} — ${c.title}'
                        '${c.year.isEmpty ? '' : ' (${c.year})'}\n'
                        '${c.location.isEmpty ? '' : '${c.location} · '}${c.license}',
                        style: LumenType.caption.copyWith(fontSize: 13),
                      ),
                    ),
                const Divider(height: 32),
                Text('TIPOGRAFIA', style: LumenType.section),
                const SizedBox(height: 8),
                Text(
                  'EB Garamond e Inter — SIL Open Font License. Ícones: Fluent UI (MIT).',
                  style: LumenType.caption.copyWith(fontSize: 13.5),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Keeps segment labels on one line on small phones ("Automático").
class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, softWrap: false),
  );
}
