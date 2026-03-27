import 'dart:ui'; // ImageFilter (glassmorphism)
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // HapticFeedback (opcional para o futuro)
import 'package:shared_preferences/shared_preferences.dart';

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
        fontFamily: 'SF Pro Text',
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

/// Conjuntos de mistérios do Rosário e Via Sacra
enum RosarySet {
  joyful,
  luminous,
  sorrowful,
  glorious,
  // stations, // ✅ VIA SACRA: Adicionar para habilitar
}

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
    // case RosarySet.stations: // ✅ VIA SACRA: Adicionar para habilitar
    //   return 'Via Sacra (Via Crucis)';
  }
}

class MysterySlide {
  final String title;
  final String subtitle;
  final String imageAsset; // ✅ Simplificado: uma imagem por mistério
  final List<String> meditations;

  const MysterySlide({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.meditations,
  });
}

class _ContemplatioHomePageState extends State<ContemplatioHomePage> {
  // Estado
  RosarySet _currentSet = RosarySet.joyful;
  int _currentSlideIndex = 0;
  int _currentBottomIndex = 0; // navbar
  late PageController _pageController;

  // Jaculatória selecionada
  int _currentMeditationIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentSlideIndex);
    _loadLastState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // -----------------------------------------
  // PERSISTÊNCIA
  // -----------------------------------------
  String _mysteryKey(RosarySet set, int slideIndex) =>
      '${set.index}-$slideIndex';

  Future<void> _loadLastState() async {
    final prefs = await SharedPreferences.getInstance();
    final setIndex = prefs.getInt('currentSet') ?? 0;
    final slideIndex = prefs.getInt('currentSlide') ?? 0;

    final safeSet =
        RosarySet.values[setIndex.clamp(0, RosarySet.values.length - 1)];
    final slides = _slidesBySet[safeSet] ?? const <MysterySlide>[];
    final safeSlide =
        slideIndex.clamp(0, (slides.isEmpty ? 0 : slides.length - 1));

    final medKey = 'med_${_mysteryKey(safeSet, safeSlide)}';
    final storedMedIndex = prefs.getInt(medKey) ?? 0;

    setState(() {
      _currentSet = safeSet;
      _currentSlideIndex = safeSlide;
      _currentMeditationIndex = storedMedIndex;

      _pageController = PageController(initialPage: _currentSlideIndex);
    });
  }

  Future<void> _saveLastState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentSet', _currentSet.index);
    await prefs.setInt('currentSlide', _currentSlideIndex);

    final medKey = 'med_${_mysteryKey(_currentSet, _currentSlideIndex)}';
    await prefs.setInt(medKey, _currentMeditationIndex);
  }

  // -----------------------------------------
  // LÓGICA DE CORES E GRADIENTES
  // -----------------------------------------
  Color get _currentSetColor {
    const Color marianBlue = Color(0xFF0B1A3A);
    const Color gold = Color(0xFFD4AF37);
    const Color deepRed = Color(0xFF7B1113); // Para Dolorosos e Via Sacra

    switch (_currentSet) {
      case RosarySet.joyful:
        return marianBlue;
      case RosarySet.luminous:
        return gold;
      case RosarySet.sorrowful:
        return deepRed;
      case RosarySet.glorious:
        return Colors.white; // Mais brilhante
      // case RosarySet.stations: // ✅ VIA SACRA: Adicionar para habilitar
      //   return deepRed;
    }
  }

  LinearGradient get _currentBackgroundGradient {
    const Color marianBlue = Color(0xFF0B1A3A);
    final Color accent = _currentSetColor.withOpacity(0.08);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        marianBlue,
        marianBlue.withOpacity(0.95),
        accent,
        marianBlue,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );
  }

  // -----------------------------------------
  // DADOS (4 conjuntos + Estrutura Via Sacra Comentada)
  // -----------------------------------------
  final Map<RosarySet, List<MysterySlide>> _slidesBySet = {
    // ------------------- GOZOSOS -------------------
    RosarySet.joyful: const [
      MysterySlide(
        title: 'Mistérios Gozosos',
        subtitle: '1º - A Anunciação',
        imageAsset: 'assets/images/joyful_1_annunciation_1.jpg',
        meditations: [
          'Jesus, que eu te diga “sim” nas coisas pequenas, com alegria.',
          'Maria, faze meu coração disponível à vontade de Deus, sem condições.',
          'Senhor, que eu trabalhe bem e em paz, porque contigo tudo tem sentido.',
          'Nossa Mãe, ensina-me a começar e recomeçar: hoje, agora.',
          'Jesus, cresce em mim: menos eu, mais Tu.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Gozosos',
        subtitle: '2º - A Visitação',
        imageAsset: 'assets/images/joyful_2_visitation_1.jpg',
        meditations: [
          'Maria, dá-me pressa para servir, sem desculpas.',
          'Jesus, que eu leve tua presença aos outros com simplicidade.',
          'Senhor, tira-me do centro: faz de mim instrumento.',
          'Nossa Mãe, que eu tenha um coração grande e prático.',
          'Jesus, que eu santifique o cotidiano com caridade concreta.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Gozosos',
        subtitle: '3º - O Nascimento de Jesus',
        imageAsset: 'assets/images/joyful_3_nativity_1.jpg',
        meditations: [
          'Jesus Menino, torna meu coração simples e verdadeiro.',
          'Senhor, que eu te encontre no silêncio, sem barulho por dentro.',
          'Maria, ajuda-me a amar a pobreza do coração: desapego e alegria.',
          'Jesus, que minha casa seja lugar de paz e presença de Deus.',
          'Meu Deus, que eu não me acostume com o milagre do teu amor.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Gozosos',
        subtitle: '4º - A Apresentação de Jesus',
        imageAsset: 'assets/images/joyful_4_presentation_1.jpg',
        meditations: [
          'Senhor, recebe minha vida: é tua, sem reservas.',
          'Maria, ensina-me a obedecer com paz, mesmo sem entender tudo.',
          'Jesus, que eu cumpra meu dever de cada dia com amor.',
          'Nossa Mãe, faze-me fiel: firme nas pequenas coisas.',
          'Senhor, dá-me pureza de intenção: só por ti, só contigo.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Gozosos',
        subtitle: '5º - Jesus perdido e encontrado',
        imageAsset: 'assets/images/joyful_5_finding_1.jpg',
        meditations: [
          'Jesus, que eu te busque de verdade, com perseverança.',
          'Senhor, quando eu me distrair, traz-me de volta com ternura.',
          'Maria, guia minha vida interior: oração simples e constante.',
          'Jesus, que eu ame as coisas do Pai com alegria e ordem.',
          'Senhor, que eu saiba “perder” tempo contigo: é o melhor investimento.',
        ],
      ),
    ],

    // ------------------- LUMINOSOS -------------------
    RosarySet.luminous: const [
      MysterySlide(
        title: 'Mistérios Luminosos',
        subtitle: '1º - O Batismo de Jesus',
        imageAsset: 'assets/images/luminous_1_baptism_1.jpg',
        meditations: [
          'Pai, lembra-me quem eu sou: teu filho amado.',
          'Jesus, purifica minhas intenções e meu olhar.',
          'Espírito Santo, guia minhas decisões: com luz e coragem.',
          'Senhor, que eu viva com dignidade cristã no meu trabalho.',
          'Nossa Mãe, leva-me a Jesus: sempre.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Luminosos',
        subtitle: '2º - As Bodas de Caná',
        imageAsset: 'assets/images/luminous_2_cana_1.jpg',
        meditations: [
          'Maria, apresenta minhas necessidades a Jesus, sem medo.',
          'Senhor, transforma minha água em vinho: rotina em amor.',
          'Jesus, eu confio: “fazei tudo o que Ele vos disser”.',
          'Nossa Mãe, ensina-me a obedecer com alegria.',
          'Senhor, que eu não reclame: que eu recomece.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Luminosos',
        subtitle: '3º - O Anúncio do Reino',
        imageAsset: 'assets/images/luminous_3_kingdom_1.jpg',
        meditations: [
          'Jesus, que eu me converta hoje: sem adiar.',
          'Senhor, faze-me simples: fé sem complicação.',
          'Que eu leve teu Reino com alegria no ordinário.',
          'Jesus, dá-me fome de santidade: de verdade.',
          'Nossa Mãe, ajuda-me a ser luz no meu ambiente.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Luminosos',
        subtitle: '4º - A Transfiguração',
        imageAsset: 'assets/images/luminous_4_transfiguration_1.jpg',
        meditations: [
          'Jesus, deixa-me te olhar: e mudar por dentro.',
          'Senhor, fortalece minha fé quando vier a cruz.',
          'Que eu escute tua voz e obedeça, com paz.',
          'Cristo, transfigura meu trabalho: que seja oração.',
          'Maria, sustenta minha fidelidade: hoje e sempre.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Luminosos',
        subtitle: '5º - A Instituição da Eucaristia',
        imageAsset: 'assets/images/luminous_5_eucharist_1.jpg',
        meditations: [
          'Jesus Eucarístico, fica comigo.',
          'Senhor, aumenta minha fome por ti.',
          'Que eu te receba com alma limpa e coração ardente.',
          'Jesus, ensina-me a amar como tu amas: até o fim.',
          'Nossa Mãe, leva-me à Missa: com desejo e gratidão.',
        ],
      ),
    ],

    // ------------------- DOLOROSOS -------------------
    RosarySet.sorrowful: const [
      MysterySlide(
        title: 'Mistérios Dolorosos',
        subtitle: '1º - A Agonia de Jesus no Horto',
        imageAsset: 'assets/images/sorrowful_1_agony_1.jpg',
        meditations: [
          'Jesus, que eu aceite a vontade do Pai com paz.',
          'Senhor, nas minhas angústias, faze-me firme.',
          'Que eu vigie e reze, sem fugir.',
          'Jesus, dá-me fortaleza para dizer “faça-se”.',
          'Nossa Mãe, segura minha mão quando eu tremer.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Dolorosos',
        subtitle: '2º - A Flagelação',
        imageAsset: 'assets/images/sorrowful_2_scourging_1.jpg',
        meditations: [
          'Senhor, cura-me por tuas chagas.',
          'Jesus, dá-me domínio: coração limpo e forte.',
          'Que eu seja penitente alegre: sem drama.',
          'Senhor, que eu vença a preguiça com amor.',
          'Nossa Mãe, ajuda-me a recomeçar com humildade.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Dolorosos',
        subtitle: '3º - A Coroação de Espinhos',
        imageAsset: 'assets/images/sorrowful_3_thorns_1.jpg',
        meditations: [
          'Jesus, Rei humilhado, reina em mim.',
          'Senhor, ensina-me a calar e a amar.',
          'Que eu não busque aplauso: só fidelidade.',
          'Jesus, dá-me humildade e alegria.',
          'Nossa Mãe, livra-me da vaidade que me rouba a paz.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Dolorosos',
        subtitle: '4º - Jesus carrega a Cruz',
        imageAsset: 'assets/images/sorrowful_4_cross_1.jpg',
        meditations: [
          'Senhor, ajuda-me a carregar minha cruz com amor.',
          'Jesus, que eu não reclame: que eu ofereça.',
          'Que eu seja constante: mesmo cansado.',
          'Jesus, dá-me paciência com os outros e comigo.',
          'Nossa Mãe, ensina-me a amar o caminho da cruz.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Dolorosos',
        subtitle: '5º - A Crucifixão e Morte',
        imageAsset: 'assets/images/sorrowful_5_crucifixion_1.jpg',
        meditations: [
          'Jesus crucificado, eu te adoro e te amo.',
          'Senhor, perdoa-me: e ensina-me a perdoar.',
          'Jesus, que eu te ame até o fim.',
          'Que eu viva com gratidão: tu morreste por mim.',
          'Nossa Mãe, coloca-me junto da Cruz, fiel e em paz.',
        ],
      ),
    ],

    // ------------------- GLORIOSOS -------------------
    RosarySet.glorious: const [
      MysterySlide(
        title: 'Mistérios Gloriosos',
        subtitle: '1º - A Ressurreição',
        imageAsset: 'assets/images/glorious_1_resurrection_1.jpg',
        meditations: [
          'Cristo ressuscitado, renova minha esperança.',
          'Senhor, dá-me alegria verdadeira: a tua.',
          'Jesus, faz-me recomeçar com coragem.',
          'Que eu viva como ressuscitado: sem medo.',
          'Nossa Mãe, ensina-me a sorrir por dentro: Deus venceu.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Gloriosos',
        subtitle: '2º - A Ascensão',
        imageAsset: 'assets/images/glorious_2_ascension_1.jpg',
        meditations: [
          'Senhor, que eu tenha o Céu no horizonte.',
          'Jesus, aumenta minha fé nas coisas invisíveis.',
          'Que eu trabalhe bem aqui, pensando no alto.',
          'Senhor, dá-me audácia para anunciar-te com a vida.',
          'Nossa Mãe, guarda meu coração: firme, alegre, fiel.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Gloriosos',
        subtitle: '3º - Pentecostes',
        imageAsset: 'assets/images/glorious_3_pentecost_1.jpg',
        meditations: [
          'Espírito Santo, vem: acende-me por dentro.',
          'Senhor, dá-me coragem para ser testemunha.',
          'Que eu fale de ti com naturalidade e alegria.',
          'Espírito Santo, ordena minha mente e meu coração.',
          'Nossa Mãe, faz de mim instrumento dócil de Deus.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Gloriosos',
        subtitle: '4º - A Assunção de Maria',
        imageAsset: 'assets/images/glorious_4_assumption_1.jpg',
        meditations: [
          'Maria, leva-me para perto de Jesus.',
          'Nossa Mãe, guarda meu coração puro e alegre.',
          'Que eu viva com dignidade de filho de Deus.',
          'Maria, ensina-me a fidelidade silenciosa.',
          'Senhor, dá-me amor a ti: sem medidas.',
        ],
      ),
      MysterySlide(
        title: 'Mistérios Gloriosos',
        subtitle: '5º - A Coroação de Maria',
        imageAsset: 'assets/images/glorious_5_coronation_1.jpg',
        meditations: [
          'Maria, Rainha, eu me consagro a ti.',
          'Nossa Mãe, governa meu coração: para Jesus.',
          'Que eu seja fiel nas pequenas coisas, com amor.',
          'Maria, dá-me pureza de intenção e alegria.',
          'Senhor, leva-me ao Céu: pela mão de Maria.',
        ],
      ),
    ],

    // ------------------- VIA SACRA (COMENTADO) -------------------
    // ✅ VIA SACRA: Adicionar para habilitar
    /*
    RosarySet.stations: const [
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'I - Jesus é condenado à morte',
        imageAsset: 'assets/images/viacrucis_01.jpg',
        meditations: [
          'Jesus, aceito as incompreensões por amor a Ti.',
          'Senhor, livra-me do julgamento apressado.',
          'Que eu prefira a Tua vontade à aprovação dos outros.',
          'Nossa Mãe, ensina-me o silêncio que ama.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'II - Jesus carrega a cruz',
        imageAsset: 'assets/images/viacrucis_02.jpg',
        meditations: [
          'Senhor, ajuda-me a abraçar minha cruz de hoje.',
          'Jesus, que eu não reclame, mas ofereça.',
          'Dá-me constância nas dificuldades.',
          'Que minha cruz seja caminho de união Contigo.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'III - Jesus cai pela primeira vez',
        imageAsset: 'assets/images/viacrucis_03.jpg',
        meditations: [
          'Jesus, dá-me humildade para aceitar minha fraqueza.',
          'Senhor, levanta-me quando eu falhar.',
          'Que eu não desanime, mas recomece.',
          'Nossa Mãe, segura minha mão no cansaço.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'IV - Jesus encontra sua Mãe',
        imageAsset: 'assets/images/viacrucis_04.jpg',
        meditations: [
          'Maria, consola-me nas minhas dores.',
          'Jesus, que eu te encontre no rosto dos que sofrem.',
          'Nossa Mãe, ensina-me a fidelidade na dor.',
          'Senhor, que eu seja presença que alivia.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'V - Simão Cireneu ajuda Jesus',
        imageAsset: 'assets/images/viacrucis_05.jpg',
        meditations: [
          'Jesus, faze-me pronto para ajudar o próximo.',
          'Senhor, que eu sirva com alegria e sem queixas.',
          'Que eu reconheça Tua presença em quem precisa.',
          'Nossa Mãe, dilata meu coração para a caridade.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'VI - Verônica enxuga o rosto de Jesus',
        imageAsset: 'assets/images/viacrucis_06.jpg',
        meditations: [
          'Jesus, imprime Teu rosto em minha alma.',
          'Senhor, dá-me coragem para ser fiel diante de todos.',
          'Que eu tenha gestos de pureza e consolo.',
          'Nossa Mãe, guarda meu olhar para as coisas do Alto.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'VII - Jesus cai pela segunda vez',
        imageAsset: 'assets/images/viacrucis_07.jpg',
        meditations: [
          'Jesus, perdoa minha reincidência nas faltas.',
          'Senhor, dá-me força para perseverar.',
          'Que eu não confie em mim, mas na Tua graça.',
          'Nossa Mãe, ajuda-me a levantar rápido.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'VIII - Jesus consola as mulheres',
        imageAsset: 'assets/images/viacrucis_08.jpg',
        meditations: [
          'Jesus, dá-me um coração sensível à dor alheia.',
          'Senhor, que eu chores por meus pecados, não por dramas.',
          'Que eu tenha palavras de esperança.',
          'Nossa Mãe, ensina-me a consolar com verdade.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'IX - Jesus cai pela terceira vez',
        imageAsset: 'assets/images/viacrucis_09.jpg',
        meditations: [
          'Jesus, pela Tua queda extrema, dá-me fortaleza final.',
          'Senhor, que eu nunca desista da santidade.',
          'Que eu me abandone à Tua misericórdia.',
          'Nossa Mãe, sê minha força na última hora.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'X - Jesus é despojado de suas vestes',
        imageAsset: 'assets/images/viacrucis_10.jpg',
        meditations: [
          'Jesus, desapega meu coração dos bens da terra.',
          'Senhor, dá-me pureza e simplicidade.',
          'Que eu nada retenha para mim, tudo para Ti.',
          'Nossa Mãe, reveste-me com a graça de Deus.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'XI - Jesus é pregado na cruz',
        imageAsset: 'assets/images/viacrucis_11.jpg',
        meditations: [
          'Jesus, prega meu coração ao Teu na cruz.',
          'Senhor, aceito as dores por amor a Ti.',
          'Que eu não fira os outros com minhas palavras.',
          'Nossa Mãe, ensina-me o perdão total.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'XII - Jesus morre na cruz',
        imageAsset: 'assets/images/viacrucis_12.jpg',
        meditations: [
          'Jesus, morro para o mundo, vivo para Ti.',
          'Senhor, nas Tuas mãos entrego meu espírito.',
          'Tudo está consumado: amaste-me até o fim.',
          'Nossa Mãe, coloca-me junto da Tua dor fiel.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'XIII - Jesus é descido da cruz',
        imageAsset: 'assets/images/viacrucis_13.jpg',
        meditations: [
          'Maria, acolhe-me em Teu colo de Mãe.',
          'Jesus, que eu Te receba com amor na Eucaristia.',
          'Nossa Mãe, ensina-me a piedade sincera.',
          'Senhor, prepara meu coração para ser Teu sepulcro.',
        ],
      ),
      MysterySlide(
        title: 'Via Sacra',
        subtitle: 'XIV - Jesus é sepultado',
        imageAsset: 'assets/images/viacrucis_14.jpg',
        meditations: [
          'Jesus, que eu aguarde com esperança a Ressurreição.',
          'Senhor, que minha vida interior seja Teu repouso.',
          'Tira-me do sepulcro do pecado e da rotina.',
          'Nossa Mãe, guarda minha fé no silêncio.',
        ],
      ),
    ],
    */
  };

  MysterySlide get _currentSlide =>
      _slidesBySet[_currentSet]![_currentSlideIndex];

  String get _currentSetTitle => rosarySetTitlePtBr(_currentSet);

  // Data PT-BR simples (agora Bold)
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
    return '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }

  String get _currentMeditation {
    final list = _currentSlide.meditations;
    if (list.isEmpty) return "";
    final safeIndex = _currentMeditationIndex.clamp(0, list.length - 1);
    return list[safeIndex];
  }

  // -----------------------------------------
  // UI PRINCIPAL (COM GRADIENTE)
  // -----------------------------------------
  @override
  Widget build(BuildContext context) {
    const Color marianBlue = Color(0xFF0B1A3A);

    return Scaffold(
      backgroundColor: marianBlue, // fallback
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
            gradient:
                _currentBackgroundGradient), // ✅ MELHORIA VISUAL: Gradiente
        child: Stack(
          children: [
            SafeArea(
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                itemCount: _slidesBySet[_currentSet]!.length,
                onPageChanged: (newIndex) {
                  setState(() {
                    _currentSlideIndex = newIndex;
                    _currentMeditationIndex = 0;
                  });
                  _saveLastState();
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: _buildGlassBottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMysteryPage(MysterySlide mystery) {
    const Color gold = Color(0xFFD4AF37);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 18), // ligeiramente maior

        // Data (bold)
        Text(
          _formattedDatePtBr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.88),
            fontWeight: FontWeight.bold, // ✅ MELHORIA VISUAL: Mais destaque
          ),
        ),

        const SizedBox(height: 14),

        // Título do conjunto (ex: Mistérios Gloriosos)
        Text(
          _currentSetTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),

        const SizedBox(height: 18), // ligeiramente maior

        // Imagem com borda dourada (✅ Simplificado: Sem navegação)
        _buildMysteryImageCard(mystery.imageAsset),

        const SizedBox(height: 28), // ligeiramente maior

        // Título
        Text(
          mystery.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.2), // ✅ MELHORIA VISUAL: Espaçamento
        ),
        const SizedBox(height: 6), // ligeiramente maior

        // Subtítulo (dourado)
        Text(
          mystery.subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: gold,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 18), // ligeiramente maior

        // Jaculatória clicável (troca)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GestureDetector(
            onTap: _cycleMeditation,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                _currentMeditation,
                key: ValueKey(
                    '${_currentSet.index}-${_currentSlideIndex}-$_currentMeditationIndex'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15, // ligeiramente maior
                  fontStyle: FontStyle.normal,
                  color: Colors.white.withOpacity(0.95), // mais visível
                  height: 1.45, // mais legível
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 130), // espaço pra navbar
      ],
    );
  }

  // -----------------------------------------
  // IMAGEM (Borda Dourada + Sombras + Cantos)
  // -----------------------------------------
  Widget _buildMysteryImageCard(String imageAsset) {
    const Color gold = Color(0xFFD4AF37);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width =
            constraints.maxWidth * 0.96; // ligeiramente menor que o container
        final double height = width * 4 / 3;

        return Center(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  32), // ✅ MELHORIA VISUAL: Cantos mais arredondados
              border: Border.all(
                  color: gold,
                  width: 1.6), // ✅ MELHORIA VISUAL: Borda mais visível
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                      0.55), // ✅ MELHORIA VISUAL: Sombra mais densa e sutil
                  blurRadius: 32,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  30), // ✅ MELHORIA VISUAL: Combina com o container
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF50535C), Color(0xFF1F2230)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_rounded,
                          size: 72, color: Colors.white70),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // -----------------------------------------
  // JACULATÓRIA CÍCLICA
  // -----------------------------------------
  void _cycleMeditation() {
    // HapticFeedback.lightImpact(); // ✅ Opcional: Feedback tátil
    final list = _currentSlide.meditations;
    if (list.isEmpty) return;
    setState(() {
      _currentMeditationIndex = (_currentMeditationIndex + 1) % list.length;
    });
    _saveLastState();
  }

  // -----------------------------------------
  // BOTTOM SHEET (SELETOR DE MISTÉRIOS)
  // -----------------------------------------
  void _openMysterySetSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => _buildMysterySetSheet(),
    );
  }

  Widget _buildMysterySetSheet() {
    const Color gold = Color(0xFFD4AF37);
    const Color marianBlue = Color(0xFF0B1A3A);

    return Container(
      padding: const EdgeInsets.all(26), // ligeiramente maior
      decoration: BoxDecoration(
        color: marianBlue.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30)), // cantos arredondados
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 35,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 26),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Text(
            'Escolha o conjunto de mistérios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.98),
            ),
          ),
          const SizedBox(height: 20), // ligeiramente maior
          _buildSetOption(RosarySet.joyful, "Mistérios Gozosos", gold),
          _buildSetOption(RosarySet.luminous, "Mistérios Luminosos", gold),
          _buildSetOption(RosarySet.sorrowful, "Mistérios Dolorosos", gold),
          _buildSetOption(RosarySet.glorious, "Mistérios Gloriosos", gold),

          // ✅ VIA SACRA: Adicionar para habilitar no BottomSheet
          /*
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.white12),
          ),
          _buildSetOption(RosarySet.stations, "Via Sacra (Via Crucis)", gold, icon: Icons.straighten_rounded),
          */

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildSetOption(RosarySet set, String title, Color gold,
      {IconData icon = Icons.layers_rounded}) {
    final bool isActive = _currentSet == set;

    return InkWell(
      onTap: () {
        Navigator.pop(context);

        if (_currentSet == set)
          return; // Não faz nada se já estiver selecionado

        setState(() {
          _currentSet = set;
          _currentSlideIndex = 0;
          _currentMeditationIndex = 0;

          _pageController = PageController(initialPage: 0);
        });

        _saveLastState();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 14), // ligeiramente maior
        margin: const EdgeInsets.only(bottom: 10), // ligeiramente maior
        decoration: BoxDecoration(
          color: isActive
              ? gold.withOpacity(0.18) // mais visível
              : Colors.white.withOpacity(0.04), // sutil
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? gold : Colors.white.withOpacity(0.18),
            width: isActive ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isActive ? gold : Colors.white70),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isActive ? gold : Colors.white.withOpacity(0.96),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------
  // NAVBAR GLASSMORPHISM (3 abas)
  // -----------------------------------------
  Widget _buildGlassBottomNavBar() {
    const Color gold = Color(0xFFD4AF37);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22), // ligeiramente maior
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24), // cantos arredondados
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // mais blur
          child: Container(
            height: 58, // ligeiramente maior
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05), // sutil
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: Colors.white.withOpacity(0.16)), // sutil
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
  }) {
    final bool isActive = _currentBottomIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _currentBottomIndex = index);

            // Home: vai para o primeiro mistério do conjunto atual
            if (index == 0) {
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );
              setState(() {
                _currentSlideIndex = 0;
                _currentMeditationIndex = 0;
              });
              _saveLastState();
              return;
            }

            // Guia
            if (index == 1) {
              _openGuide();
              return;
            }

            // Mistérios: abre o seletor do conjunto
            if (index == 2) {
              _openMysterySetSelector();
              return;
            }
          },
          borderRadius: BorderRadius.circular(18),
          splashColor: activeColor.withOpacity(0.2),
          highlightColor: activeColor.withOpacity(0.1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: isActive ? 1.0 : 0.65, // ✅ MELHORIA VISUAL: Mais sutil
            child: Center(
              child: Icon(
                icon,
                size: 22,
                color: isActive
                    ? activeColor
                    : Colors.white.withOpacity(0.8), // mais visível
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Guia MVP (dialog)
  void _openGuide() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1A3A),
          title: const Text(
            'Guia rápido',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          content: Text(
            '• Arraste para o lado para trocar de mistério ou estação.\n'
            '• Toque na jaculatória/meditação para trocar por outra.\n'
            '• Em “Mistérios”, escolha qual conjunto deseja contemplar.\n',
            style: TextStyle(color: Colors.white.withOpacity(0.9), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
