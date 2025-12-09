import 'dart:ui'; // para o ImageFilter do glassmorphism
import 'package:flutter/material.dart';

void main() {
  runApp(const ContemplatioApp());
}

class ContemplatioApp extends StatelessWidget {
  const ContemplatioApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color marianBlue = Color(0xFF0B1A3A);

    return MaterialApp(
      title: 'Contemplatio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: marianBlue,
        fontFamily: 'SF Pro Text', // se não tiver, o Flutter usa a default
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: const ContemplatioHomePage(),
    );
  }
}

class ContemplatioHomePage extends StatefulWidget {
  const ContemplatioHomePage({super.key});

  @override
  State<ContemplatioHomePage> createState() => _ContemplatioHomePageState();
}

/// Conjuntos de mistérios do Rosário
enum RosarySet {
  joyful, // Gozosos
  luminous, // Luminosos
  sorrowful, // Dolorosos
  glorious, // Gloriosos
}

/// Nome bonito pro conjunto (título grande na tela)
String rosarySetTitlePtBr(RosarySet set) {
  switch (set) {
    case RosarySet.joyful:
      return 'Mistérios Gozosos';
    case RosarySet.luminous:
      return 'Mistérios Luminosos';
    case RosarySet.sorrowful:
      return 'Mistérios Dolorosos';
    case RosarySet.glorious:
      return 'Mistérios Gloriosos';
  }
}

class MysterySlide {
  final String title;
  final String subtitle;
  final List<String> imageAsset;
  final List<String> meditations;

  const MysterySlide({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.meditations,
  });
}

class _ContemplatioHomePageState extends State<ContemplatioHomePage> {
  RosarySet _currentSet = RosarySet.joyful; // começa nos Gozosos
  int _currentSlideIndex = 0;
  int _currentImageIndex = 0;
  int _currentBottomIndex = 0;

  /// Todos os conjuntos de mistérios
  final Map<RosarySet, List<MysterySlide>> _slidesBySet = {
    RosarySet.joyful: const [
      MysterySlide(
        title: 'Mistérios Gozosos',
        subtitle: '1º - A Anunciação',
        imageAsset: [
          'assets/images/joyful_annunciation_1.jpg',
          'assets/images/joyful_annunciation_2.jpg',
          'assets/images/joyful_annunciation_3.jpg',
        ],
        meditations: [
          '“O Verbo se fez carne e habitou entre nós.”',
          '“Senhora, ensina-me a dizer Sim como Tu.”',
        ],
      ),
    ],

    RosarySet.luminous: const [
      MysterySlide(
        title: 'Mistérios Luminosos',
        subtitle: '1º - Batismo de Jesus',
        imageAsset: [
          'assets/images/joyful_annunciation_1.jpg',
          'assets/images/joyful_annunciation_2.jpg',
          'assets/images/joyful_annunciation_3.jpg',
        ],
        meditations: [
          '“Este é o Meu Filho muito amado.”',
          '“Senhora, ensina-me a dizer Sim como Tu.”',
        ],
      ),
    ],

    RosarySet.sorrowful: const [
      MysterySlide(
        title: 'Mistérios Dolorosos',
        subtitle: '1º – Agonia no Horto',
        imageAsset: [
          'assets/images/joyful_annunciation_1.jpg',
          'assets/images/joyful_annunciation_2.jpg',
          'assets/images/joyful_annunciation_3.jpg',
        ],
        meditations: ['“Pai, afasta de mim este cálice...”'],
      ),
    ],

    RosarySet.glorious: const [
      MysterySlide(
        title: 'Mistérios Gloriosos',
        subtitle: '1º – A Ressurreição',
        imageAsset: [
          'assets/images/joyful_annunciation_1.jpg',
          'assets/images/joyful_annunciation_2.jpg',
          'assets/images/joyful_annunciation_3.jpg',
        ],
        meditations: ['“Ele não está aqui — ressuscitou!”'],
      ),
    ],
  };

  /// Slide atual
  MysterySlide get _currentSlide =>
      _slidesBySet[_currentSet]![_currentSlideIndex];

  /// Título do conjunto atual (Gozosos, Dolorosos etc)
  String get _currentSetTitle => rosarySetTitlePtBr(_currentSet);

  /// Formata a data em PT-BR: "Sábado, 29 de Novembro"
  String get _formattedDatePtBr {
    final now = DateTime.now();
    const weekdays = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    // no Dart, Monday = 1 ... Sunday = 7
    final weekdayName = weekdays[now.weekday - 1];
    final monthName = months[now.month - 1];

    return '$weekdayName, ${now.day} de $monthName';
  }

  /// Escolhe um ponto de meditação "randômico por dia".
  /// Usa o dia do mês como base, assim cada dia cai em um índice diferente.
  String get _todayMeditation {
    final now = DateTime.now();
    final List<String> list = _currentSlide.meditations;
    final index = now.day % list.length;
    return list[index];
  }

  @override
  Widget build(BuildContext context) {
    const Color marianBlue = Color(0xFF0B1A3A);

    /// const Color gold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: marianBlue,
      extendBody: true, // para o glass navbar passar por cima do body
      body: Stack(
        children: [
          SafeArea(
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: PageController(initialPage: _currentSlideIndex),
              itemCount: _slidesBySet[_currentSet]!.length,
              onPageChanged: (newIndex) {
                setState(() {
                  _currentSlideIndex = newIndex;
                  // sempre voltar para a primeira imagem do mistério
                  _currentImageIndex = 0;
                });
              },
              itemBuilder: (context, index) {
                final mystery = _slidesBySet[_currentSet]![index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildMysteryPage(mystery),
                );
              },
            ),
          ),

          // 👉 NAVBAR DE VIDRO
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: _buildGlassBottomNavBar(),
          ),
        ],
      ),
    );
  }

  /// Card com a imagem do mistério (por enquanto placeholder).
  Widget _buildMysteryImageCard() {
    const Color gold = Color(0xFFD4AF37);

    final images = _currentSlide.imageAsset; // lista de imagens do mistério
    final bool hasImages = images.isNotEmpty;
    final bool canGoPrevImage = hasImages && _currentImageIndex > 0;
    final bool canGoNextImage =
        hasImages && _currentImageIndex < images.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double cardWidth = maxWidth;
        final double cardHeight = maxWidth * 4 / 3; // proporção 3:4

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 👉 Moldura com sombra "galeria de arte"
              Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: gold, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: hasImages
                      ? Image.asset(
                          images[_currentImageIndex],
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF50535C), Color(0xFF1F2230)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_rounded,
                              size: 72,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                ),
              ),

              // 👉 Botão: imagem anterior (dentro do mesmo mistério)
              Positioned(
                left: 12,
                child: Opacity(
                  opacity: canGoPrevImage ? 1 : 0.25,
                  child: InkWell(
                    onTap: canGoPrevImage ? _previousImage : null,
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // 👉 Botão: próxima imagem (dentro do mesmo mistério)
              Positioned(
                right: 12,
                child: Opacity(
                  opacity: canGoNextImage ? 1 : 0.25,
                  child: InkWell(
                    onTap: canGoNextImage ? _nextImage : null,
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMysteryPage(MysterySlide mystery) {
    const Color gold = Color(0xFFD4AF37);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),

        // Data
        Text(
          _formattedDatePtBr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // TÍTULO DO CONJUNTO ATUAL (ex: Mistérios Gozosos)
        Text(
          _currentSetTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),

        // IMAGEM (camada 1)
        _buildMysteryImageCard(),

        const SizedBox(height: 24),

        // Título (mistério)
        Text(
          mystery.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 4),

        // Subtítulo
        Text(
          mystery.subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: gold,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 16),

        // Meditação
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _todayMeditation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.normal,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 120),
      ],
    );
  }

  void _nextImage() {
    final images = _currentSlide.imageAsset;
    if (images.isEmpty) return;

    setState(() {
      if (_currentImageIndex < images.length - 1) {
        _currentImageIndex++;
      }
    });
  }

  void _previousImage() {
    final images = _currentSlide.imageAsset;
    if (images.isEmpty) return;

    setState(() {
      if (_currentImageIndex > 0) {
        _currentImageIndex--;
      }
    });
  }

  void _openMysterySetSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return _buildMysterySetSheet();
      },
    );
  }

  Widget _buildMysterySetSheet() {
    const Color gold = Color(0xFFD4AF37);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Text(
            'Escolha o conjunto de mistérios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),

          _buildSetOption(RosarySet.joyful, "Mistérios Gozosos", gold),
          _buildSetOption(RosarySet.luminous, "Mistérios Luminosos", gold),
          _buildSetOption(RosarySet.sorrowful, "Mistérios Dolorosos", gold),
          _buildSetOption(RosarySet.glorious, "Mistérios Gloriosos", gold),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSetOption(RosarySet set, String title, Color gold) {
    final bool isActive = _currentSet == set;

    return InkWell(
      onTap: () {
        Navigator.pop(context); // fecha o bottom sheet
        setState(() {
          _currentSet = set;
          _currentSlideIndex = 0;
          _currentImageIndex = 0;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? gold : Colors.white.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.layers_rounded,
              size: 20,
              color: isActive ? gold : Colors.white70,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isActive ? gold : Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom navigation bar com efeito de vidro (glassmorphism).
  Widget _buildGlassBottomNavBar() {
    const Color gold = Color(0xFFD4AF37);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  activeColor: gold,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.menu_book_rounded,
                  label: 'Guia',
                  activeColor: gold,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.layers_rounded,
                  label: 'Mistérios',
                  activeColor: gold,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.language_rounded,
                  label: 'Idioma',
                  activeColor: gold,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  activeColor: gold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Item individual da navbar (ícone + texto).
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
  }) {
    final bool isActive = _currentBottomIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentBottomIndex = index;
          });
          if (index == 2) {
            _openMysterySetSelector();
          }
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isActive ? 1.0 : 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? activeColor : Colors.white.withOpacity(0.85),
              ),

              /* const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? activeColor
                      : Colors.white.withOpacity(0.85),
                ),
              ), // text of navibar*/
            ],
          ),
        ),
      ),
    );
  }
}
