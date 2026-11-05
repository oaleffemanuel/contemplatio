import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../widgets/lumen_button.dart';
import '../widgets/sacred_image.dart';

/// First-launch introduction: what Lumen is and how to use it.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages = PageController();
  int _page = 0;

  static const _steps = [
    (
      image: 'joyful_1_annunciation_1.jpg',
      eyebrow: 'BEM-VINDO AO LUMEN',
      title: 'Contemplar a vida de Cristo',
      text:
          'Com os olhos de Maria, diante das grandes obras da arte sacra. '
          'Cada dia, os mistérios do dia.',
    ),
    (
      image: 'luminous_4_transfiguration_1.jpg',
      eyebrow: 'AS OBRAS',
      title: 'Várias pinturas para cada mistério',
      text:
          'Deslize para o lado para mudar de mistério. Toque nas bordas da '
          'tela ou nas miniaturas para ver outras obras. Toque no meio para '
          'ficar só com a imagem.',
    ),
    (
      image: 'glorious_1_resurrection_1.jpg',
      eyebrow: 'JACULATÓRIAS',
      title: 'Uma frase para levar consigo',
      text:
          'Toque na jaculatória para ver outra. Guarde uma no coração e '
          'repita-a ao longo do dia.',
    ),
    (
      image: 'sorrowful_4_cross_1.jpg',
      eyebrow: 'VIA SACRA E OS SANTOS',
      title: 'Acompanhar Jesus até o Calvário',
      text:
          'Faça a Via Sacra com São Josemaria, o Papa Francisco e outros '
          'santos, e leia o que eles escreveram sobre cada mistério.',
    ),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _steps.length - 1) {
      widget.onDone();
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(
    maxScaleFactor: 1.15,
    child: _build(context),
  );

  Widget _build(BuildContext context) {
    final last = _page == _steps.length - 1;
    return Scaffold(
      backgroundColor: LumenColors.imageInk,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: _steps.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final step = _steps[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  SacredImage(file: step.image, drift: true),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      26,
                      0,
                      26,
                      MediaQuery.paddingOf(context).bottom + 120,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.eyebrow,
                          style: LumenType.eyebrow(LumenColors.onHeroMuted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.title,
                          style: LumenType.title(
                            36,
                            color: LumenColors.onImage,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          step.text,
                          style: LumenType.body(
                            color: LumenColors.onImage,
                            1,
                          ).copyWith(fontSize: 18, color: LumenColors.onImage),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            left: 26,
            right: 26,
            bottom: MediaQuery.paddingOf(context).bottom + 28,
            child: Row(
              children: [
                for (var i = 0; i < _steps.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 6),
                    width: i == _page ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color:
                          i == _page
                              ? LumenColors.accent
                              : LumenColors.onImage.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                const Spacer(),
                if (!last)
                  TextButton(
                    onPressed: widget.onDone,
                    child: Text(
                      'Pular',
                      style: TextStyle(color: LumenColors.muted),
                    ),
                  ),
                LumenButton(
                  label: last ? 'Começar' : 'Próximo',
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
