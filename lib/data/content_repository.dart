import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';

typedef AssetLoader = Future<String> Function(String path);

/// Reads the bundled prayer content. Via Sacra collections are listed in
/// [viaSacraFiles] in display order; a collection without stations (texts not
/// received yet) is shown as "em breve".
final class ContentRepository {
  ContentRepository({AssetLoader? loadAsset})
    : _load = loadAsset ?? rootBundle.loadString;

  final AssetLoader _load;

  static const viaSacraFiles = [
    'assets/data/via_sacra_sao_josemaria.json',
    'assets/data/via_sacra_papa_francisco.json',
    'assets/data/via_sacra_melodia-santo-afonso.json',
    'assets/data/via_sacra_melodia-newman.json',
    'assets/data/via_sacra_melodia-madre-teresa.json',
    'assets/data/via_sacra_melodia-champourcin.json',
    'assets/data/via_sacra_melodia-frei-asinello.json',
    'assets/data/via_sacra_breve.json',
  ];

  static const anthologyFiles = ['assets/data/melodia_do_calvario.json'];

  List<MysterySet>? _sets;
  List<ViaSacraCollection>? _collections;
  List<ViaSacraAnthology>? _anthologies;
  Map<String, ArtworkCredit>? _credits;
  Article? _guide;
  List<SaintWork>? _saints;

  /// What the saints wrote on each mystery (read apart from contemplation).
  Future<List<SaintWork>> saintWorks() async {
    if (_saints != null) return _saints!;
    final json =
        jsonDecode(await _load('assets/data/com_os_santos.json')) as Map;
    return _saints = [
      for (final w in json['works'] as List)
        SaintWork.fromJson(w as Map<String, dynamic>),
    ];
  }

  /// "Contemplar os mistérios", drawn from Rosarium Virginis Mariae.
  Future<Article> contemplationGuide() async =>
      _guide ??= Article.fromJson(
        jsonDecode(await _load('assets/data/guia_contemplacao.json'))
            as Map<String, dynamic>,
      );

  /// Painting credits keyed by image file name.
  Future<Map<String, ArtworkCredit>> artworkCredits() async {
    if (_credits != null) return _credits!;
    try {
      final json = jsonDecode(await _load('assets/data/credits.json')) as Map;
      return _credits = {
        for (final e in json.entries)
          e.key as String: ArtworkCredit.fromJson(
            e.value as Map<String, dynamic>,
          ),
      };
    } catch (_) {
      return _credits = const {};
    }
  }

  Future<List<ViaSacraAnthology>> anthologies() async {
    if (_anthologies != null) return _anthologies!;
    return _anthologies = [
      for (final path in anthologyFiles)
        ViaSacraAnthology.fromJson(
          jsonDecode(await _load(path)) as Map<String, dynamic>,
        ),
    ];
  }

  Future<List<MysterySet>> mysterySets() async {
    if (_sets != null) return _sets!;
    final json = jsonDecode(await _load('assets/data/rosary.json')) as Map;
    return _sets = [
      for (final s in json['sets'] as List)
        MysterySet.fromJson(s as Map<String, dynamic>),
    ];
  }

  Future<List<ViaSacraCollection>> viaSacraCollections() async {
    if (_collections != null) return _collections!;
    final list = <ViaSacraCollection>[];
    for (final path in viaSacraFiles) {
      final raw = await _load(path);
      list.add(
        ViaSacraCollection.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    }
    list.sort((a, b) => a.order.compareTo(b.order));
    return _collections = list;
  }
}
