/// Where a fact comes from; decides how the reminder presents it.
enum FactKind {
  /// Wikipedia "Did you know" — short teasers curated by editors.
  didYouKnow,

  /// Wikipedia "On this day", the editor-selected anniversaries.
  onThisDay,

  /// A place from the user's own map area that they haven't visited yet.
  nearby,
}

/// One candidate for a daily reminder.
class InterestingFact {
  const InterestingFact({
    required this.id,
    required this.kind,
    required this.text,
    this.title,
    this.year,
    this.url,
    this.hasImage = false,
  });

  /// Stable id used to avoid sending the same fact twice.
  final String id;
  final FactKind kind;

  /// The fact itself, already cleaned (see [FactCurator.clean]).
  final String text;

  /// Article / place name, when there is one.
  final String? title;
  final int? year;

  /// Article to open when the notification is tapped.
  final String? url;
  final bool hasImage;

  @override
  String toString() => 'InterestingFact(${kind.name}, $id, $text)';
}

/// Pure rules that turn raw Wikipedia snippets into something worth a
/// notification: tidy text, no grim news, best candidates first.
abstract final class FactCurator {
  static const minLength = 30;
  static const maxLength = 220;

  // Notes that only make sense next to the picture on the main page.
  static final _pictureNotes = RegExp(
    r'\s*\((?:на\s+(?:илл|фото|снимке|рисунке|карте)[^)]*|изображ[её]н[^)]*|pictured|shown|illustrated|depicted|video featured|featured)\)',
    caseSensitive: false,
  );

  /// Words that make a cheerful "go for a walk" push inappropriate.
  static const _grim = [
    // ru
    'погиб', 'гибел', 'жертв', 'убит', 'убий', 'убив', 'теракт', 'катастроф', 'крушени', 'взрыв', 'расстрел',
    'казн', 'умер', 'смерт', 'резн', 'геноцид', 'эпидеми', 'землетрясени', 'цунами', 'циклон', 'ураган', 'голод',
    'бомб', 'самоубий', 'холокост', 'депортац', 'репресс',
    // en
    'killed',
    'killing',
    'kill ',
    'perish',
    'bodies',
    'death',
    'died',
    'dead',
    'massacre',
    'bomb',
    'crash',
    'terror',
    'earthquake',
    'genocide',
    'executed', 'execution', 'murder', 'shooting', 'explosion', 'disaster', 'cyclone', 'hurricane', 'famine',
    'epidemic', 'suicide', 'holocaust', 'casualt',
  ];

  /// Removes picture notes and stray spaces; capitalizes the first letter
  /// ("On this day" items often start in lower case).
  static String clean(String raw) {
    var s = raw.replaceAll(_pictureNotes, '');
    s = s.replaceAll(RegExp(r'\s+'), ' ').replaceAllMapped(RegExp(r'\s+([.,;:!?)])'), (m) => m[1]!).trim();
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// War stories are history too, but shouldn't fill every reminder.
  static const _war = ['войн', 'сражени', 'битв', 'фронт', 'вермахт', 'war:', ' war ', 'battle', 'operation', 'troops'];

  /// Firsts, openings and discoveries make the best "did you know".
  static const _delight = [
    'перв',
    'открыт',
    'основан',
    'премьер',
    'изобр',
    'построен',
    'обнаруж',
    'рекорд',
    'first',
    'opened',
    'founded',
    'premiere',
    'invent',
    'discover',
    'launched',
    'record',
  ];

  static bool _has(String text, List<String> words) {
    final t = ' ${text.toLowerCase()} ';
    return words.any(t.contains);
  }

  static bool isGrim(String text) {
    final t = text.toLowerCase();
    return _grim.any(t.contains);
  }

  /// True if the fact can go into a notification at all.
  static bool isSuitable(InterestingFact f) =>
      f.text.length >= minLength && f.text.length <= maxLength && !isGrim(f.text) && !isGrim(f.title ?? '');

  /// Higher is better. Only compares facts of the same kind.
  static int score(InterestingFact f) {
    var s = 0;
    if (f.hasImage) s += 2;
    // A history app: older anniversaries beat yesterday's news.
    if (f.year != null) {
      if (f.year! <= 1945) s += 2;
      if (f.year! > 2000) s -= 1;
    }
    // Shorter texts read better in a notification.
    if (f.text.length <= 140) s += 1;
    if (f.kind == FactKind.nearby && f.year != null) s += 1;
    if (_has(f.text, _war)) s -= 2;
    if (_has(f.text, _delight)) s += 1;
    return s;
  }

  /// Suitable facts not in [used], best first; ties keep source order.
  static List<InterestingFact> rank(Iterable<InterestingFact> facts, {Set<String> used = const {}}) {
    final list = [
      for (final f in facts)
        if (isSuitable(f) && !used.contains(f.id)) f,
    ];
    final order = {for (var i = 0; i < list.length; i++) list[i]: i};
    list.sort((a, b) {
      final d = score(b) - score(a);
      return d != 0 ? d : order[a]! - order[b]!;
    });
    return list;
  }

  /// First one or two sentences of [text], at most [maxLength] characters.
  static String lead(String text) {
    final t = clean(text);
    final sentences = RegExp(r'[^.!?…]+[.!?…]+(?:\s|$)').allMatches(t).map((m) => m.group(0)!.trim()).toList();
    if (sentences.isEmpty) return t.length <= maxLength ? t : '${t.substring(0, maxLength - 1).trimRight()}…';
    var out = sentences.first;
    if (out.length < 80 && sentences.length > 1 && out.length + sentences[1].length < maxLength) {
      out = '$out ${sentences[1]}';
    }
    return out.length <= maxLength ? out : '${out.substring(0, maxLength - 1).trimRight()}…';
  }
}
