/// Content models, loaded from `assets/data/*.json`.
library;

final class Mystery {
  const Mystery({
    required this.number,
    required this.name,
    required this.images,
    required this.meditations,
  });

  final int number;
  final String name;

  /// Paintings to contemplate, the main one first.
  final List<String> images;
  final List<String> meditations;

  String get image => images.first;

  factory Mystery.fromJson(Map<String, dynamic> json) {
    final images = ((json['images'] as List?) ?? const []).cast<String>();
    return Mystery(
      number: json['number'] as int,
      name: json['name'] as String,
      images: images.isNotEmpty ? images : [json['image'] as String],
      meditations: (json['meditations'] as List).cast<String>(),
    );
  }
}

/// Who painted a work, for the caption under each image.
final class ArtworkCredit {
  const ArtworkCredit({
    required this.title,
    required this.artist,
    required this.year,
    required this.location,
    required this.license,
  });

  final String title;
  final String artist;
  final String year;
  final String location;
  final String license;

  String get caption => '$artist · $title${year.isEmpty ? '' : ', $year'}';

  factory ArtworkCredit.fromJson(Map<String, dynamic> json) => ArtworkCredit(
    title: json['title'] as String? ?? '',
    artist: json['artist'] as String? ?? '',
    year: json['year'] as String? ?? '',
    location: json['location'] as String? ?? '',
    license: json['license'] as String? ?? '',
  );
}

final class MysterySet {
  const MysterySet({
    required this.id,
    required this.title,
    required this.mysteries,
  });

  final String id;
  final String title;
  final List<Mystery> mysteries;

  /// "Mistérios Gloriosos" → "Gloriosos".
  String get shortTitle => title.replaceFirst('Mistérios ', '');

  factory MysterySet.fromJson(Map<String, dynamic> json) => MysterySet(
    id: json['id'] as String,
    title: json['title'] as String,
    mysteries: [
      for (final m in json['mysteries'] as List)
        Mystery.fromJson(m as Map<String, dynamic>),
    ],
  );
}

final class Station {
  const Station({
    required this.number,
    required this.title,
    required this.image,
    required this.paragraphs,
  });

  final int number;
  final String title;
  final String image;
  final List<String> paragraphs;

  factory Station.fromJson(Map<String, dynamic> json) => Station(
    number: json['number'] as int,
    title: json['title'] as String,
    image: json['image'] as String,
    paragraphs: (json['paragraphs'] as List).cast<String>(),
  );
}

final class ViaSacraCollection {
  const ViaSacraCollection({
    required this.id,
    required this.title,
    required this.author,
    required this.order,
    required this.kind,
    required this.stations,
    this.group,
    this.intro = const [],
    this.closing = const [],
    this.source,
    this.sourceUrl,
  });

  final String id;
  final String title;
  final String author;
  final int order;

  /// `meditacao` (long texts) or `jaculatorias` (one short prayer per line).
  final String kind;
  final List<Station> stations;

  /// Id of the anthology this Via Sacra belongs to (e.g. A melodia do
  /// Calvário), if any.
  final String? group;

  /// Opening and closing prayers, shown as the first and last pages.
  final List<String> intro;
  final List<String> closing;
  final String? source;
  final String? sourceUrl;

  bool get isAvailable => stations.isNotEmpty;

  factory ViaSacraCollection.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) =>
        ((json[key] as List?) ?? const []).cast<String>();
    final source = json['source'] as String?;
    return ViaSacraCollection(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      order: json['order'] as int,
      kind: json['kind'] as String? ?? 'meditacao',
      group: json['group'] as String?,
      intro: strings('intro'),
      closing: strings('closing'),
      source: (source == null || source.isEmpty) ? null : source,
      sourceUrl: json['source_url'] as String?,
      stations: [
        for (final s in json['stations'] as List)
          Station.fromJson(s as Map<String, dynamic>),
      ],
    );
  }
}

/// A free-standing text (preface, introductory reading).
final class Article {
  const Article({
    required this.title,
    required this.author,
    required this.paragraphs,
    this.sourceUrl,
  });

  final String title;
  final String author;
  final List<String> paragraphs;
  final String? sourceUrl;

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    title: json['title'] as String,
    author: json['author'] as String? ?? '',
    paragraphs: (json['paragraphs'] as List).cast<String>(),
    sourceUrl: json['source_url'] as String?,
  );
}

/// An anthology of Vias Sacras, like Pe. Alberto Shintani's
/// "A melodia do Calvário".
final class ViaSacraAnthology {
  const ViaSacraAnthology({
    required this.id,
    required this.title,
    required this.organizer,
    required this.instagram,
    required this.preface,
    required this.readings,
  });

  final String id;
  final String title;
  final String organizer;
  final String? instagram;
  final Article preface;
  final List<Article> readings;

  factory ViaSacraAnthology.fromJson(Map<String, dynamic> json) =>
      ViaSacraAnthology(
        id: json['id'] as String,
        title: json['title'] as String,
        organizer: json['organizer'] as String,
        instagram: json['instagram'] as String?,
        preface: Article.fromJson(json['preface'] as Map<String, dynamic>),
        readings: [
          for (final r in json['readings'] as List)
            Article.fromJson(r as Map<String, dynamic>),
        ],
      );
}

/// A saint's text on one mystery (e.g. São Josemaria's Santo Rosário).
final class SaintEntry {
  const SaintEntry({
    required this.setId,
    required this.mystery,
    required this.title,
    required this.paragraphs,
  });

  final String setId;
  final int mystery;
  final String title;
  final List<String> paragraphs;

  factory SaintEntry.fromJson(Map<String, dynamic> json) => SaintEntry(
    setId: json['set'] as String,
    mystery: json['mystery'] as int,
    title: json['title'] as String,
    paragraphs: (json['paragraphs'] as List).cast<String>(),
  );
}

final class SaintWork {
  const SaintWork({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.entries,
  });

  final String id;
  final String title;
  final String author;
  final String description;
  final List<SaintEntry> entries;

  factory SaintWork.fromJson(Map<String, dynamic> json) => SaintWork(
    id: json['id'] as String,
    title: json['title'] as String,
    author: json['author'] as String,
    description: json['description'] as String? ?? '',
    entries: [
      for (final e in json['entries'] as List)
        SaintEntry.fromJson(e as Map<String, dynamic>),
    ],
  );
}

/// Traditional weekday distribution (St John Paul II, Rosarium Virginis
/// Mariae 38): Mon/Sat joyful, Tue/Fri sorrowful, Thu luminous,
/// Wed/Sun glorious.
/// Days on which each set is prayed, for display.
String daysForSet(String setId) => switch (setId) {
  'joyful' => 'Segunda e sábado',
  'sorrowful' => 'Terça e sexta',
  'luminous' => 'Quinta-feira',
  _ => 'Quarta e domingo',
};

String mysterySetForWeekday(int weekday) => switch (weekday) {
  DateTime.monday || DateTime.saturday => 'joyful',
  DateTime.tuesday || DateTime.friday => 'sorrowful',
  DateTime.thursday => 'luminous',
  _ => 'glorious',
};

String romanNumeral(int n) {
  const values = [10, 9, 5, 4, 1];
  const symbols = ['X', 'IX', 'V', 'IV', 'I'];
  final buffer = StringBuffer();
  var rest = n;
  for (var i = 0; i < values.length; i++) {
    while (rest >= values[i]) {
      buffer.write(symbols[i]);
      rest -= values[i];
    }
  }
  return buffer.toString();
}
