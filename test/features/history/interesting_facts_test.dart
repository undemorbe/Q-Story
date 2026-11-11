import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/history/data/datasources/wiki_facts_client.dart';
import 'package:qstory/features/history/data/repositories/interesting_facts_repository.dart';
import 'package:qstory/features/history/domain/interesting_fact.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_query.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fakes.dart';

InterestingFact fact(
  String id,
  String text, {
  FactKind kind = FactKind.didYouKnow,
  int? year,
  bool image = false,
  String? title,
}) => InterestingFact(id: id, kind: kind, text: text, year: year, hasImage: image, title: title);

const _ruDyk = '''
<div class="dyk">
<ul>
<li><b><a href="/wiki/%D0%9A%D0%BE%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B0%D1%8F_%D0%BD%D0%B0%D0%B1%D0%B5%D1%80%D0%B5%D0%B6%D0%BD%D0%B0%D1%8F" title="Котельническая набережная">Какой дом</a></b> на&#160;набережной строили пленные (<i>на&#160;илл.</i>)&#160;?</li>
<li>Почему <b><a href="/wiki/Ёжик">ёжик</a></b> из&nbsp;мультфильма стал символом &laquo;туманности&raquo; ?</li>
<li><a href="/wiki/Википедия:Знаете_ли_вы">Архив</a></li>
<li><b><a href="/wiki/Проект:Знаете_ли_вы">Предложить</a></b></li>
</ul>
</div>''';

const _enDyk = '''
<ul>
<li>... that <b><a href="/wiki/Amber_Room" title="Amber Room">the Amber Room</a></b> (pictured) was given to Peter the Great?</li>
<li>... that the <b><a href="/wiki/Tea_clipper">tea clipper</a></b> raced &amp; won in 1866?</li>
</ul>''';

Map<String, Object?> _otd() => {
  'selected': [
    {
      'text': 'основан   Санкт-Петербург .',
      'year': 1703,
      'pages': [
        {
          'titles': {'normalized': 'Санкт-Петербург'},
          'thumbnail': {'source': 'x.jpg'},
          'content_urls': {
            'mobile': {'page': 'https://ru.m.wikipedia.org/wiki/Санкт-Петербург'},
          },
        },
      ],
    },
    {'text': 'Без года', 'pages': []},
    {'text': 'В Москве открылась первая линия метро.', 'year': 1935},
  ],
};

void main() {
  group('FactCurator', () {
    test('clean drops picture notes, fixes spaces and capitalizes', () {
      expect(FactCurator.clean('  какой дом  (на илл.) строили ?'), 'Какой дом строили?');
      expect(FactCurator.clean('…that the bridge (pictured) is old'), '…that the bridge is old');
      expect(FactCurator.clean(''), '');
    });

    test('grim facts are not suitable, including by title', () {
      expect(FactCurator.isGrim('Взрыв на складе'), isTrue);
      expect(FactCurator.isGrim('The ship sank, killing 111 people'), isTrue);
      expect(FactCurator.isGrim('Британские ВВС применили бомбы'), isTrue);
      expect(FactCurator.isGrim('Открылся первый музей города'), isFalse);
      final ok = fact('a', 'Открылся первый в России публичный музей — Кунсткамера.');
      expect(FactCurator.isSuitable(ok), isTrue);
      expect(FactCurator.isSuitable(fact('b', ok.text, title: 'Теракт')), isFalse);
    });

    test('too short or too long facts are not suitable', () {
      expect(FactCurator.isSuitable(fact('a', 'Коротко.')), isFalse);
      expect(FactCurator.isSuitable(fact('b', 'Очень длинный текст. ' * 20)), isFalse);
    });

    test('rank prefers pictures and old anniversaries, skips used, keeps ties in order', () {
      final facts = [
        fact('plain1', 'Обычный факт про город и его улицы.', kind: FactKind.onThisDay, year: 1990),
        fact('modern', 'Совсем свежее событие про город и улицы.', kind: FactKind.onThisDay, year: 2015),
        fact('old', 'Давнее событие про город и его улицы.', kind: FactKind.onThisDay, year: 1820),
        fact('pic', 'Событие с картинкой про город и улицы.', kind: FactKind.onThisDay, year: 1990, image: true),
        fact('plain2', 'Ещё один обычный факт про этот город.', kind: FactKind.onThisDay, year: 1990),
        fact('used', 'Давнее событие с картинкой про город.', kind: FactKind.onThisDay, year: 1800, image: true),
      ];
      final ids = FactCurator.rank(facts, used: {'used'}).map((f) => f.id).toList();
      expect(ids.take(2).toSet(), {'old', 'pic'});
      expect(ids.indexOf('plain1'), lessThan(ids.indexOf('plain2')));
      expect(ids.last, 'modern');
      expect(ids, isNot(contains('used')));
    });

    test('war stories rank below discoveries', () {
      final ids = FactCurator.rank([
        fact('war', 'Началось сражение за небольшой город на реке.', year: 1812),
        fact('first', 'Открылся первый в мире зоопарк для публики.', year: 1812),
      ]).map((f) => f.id);
      expect(ids, ['first', 'war']);
    });

    test('lead takes one or two sentences within the limit', () {
      expect(FactCurator.lead('Короткая. Вторая фраза тоже. Третья.'), 'Короткая. Вторая фраза тоже.');
      final long = 'Первое предложение достаточно длинное, чтобы не добавлять к нему ничего больше сверху. Второе.';
      expect(FactCurator.lead(long), long.split(' Второе').first);
      final huge = FactCurator.lead('а' * 400);
      expect(huge.length, FactCurator.maxLength);
      expect(huge, endsWith('…'));
    });
  });

  group('WikiFactsClient parsing', () {
    test('ru "Did you know" keeps only article teasers', () {
      final f = WikiFactsClient.parseDidYouKnow(_ruDyk, 'ru');
      expect(f, hasLength(2));
      expect(f[0].id, 'dyk:ru:Котельническая набережная');
      expect(f[0].text, 'Какой дом на набережной строили пленные?');
      expect(f[0].hasImage, isTrue);
      expect(f[0].url, startsWith('https://ru.m.wikipedia.org/wiki/'));
      expect(f[1].text, contains('ёжик из мультфильма'));
      expect(f[1].hasImage, isFalse);
      expect(f.every((e) => e.kind == FactKind.didYouKnow), isTrue);
    });

    test('en "Did you know" reads as a continuation', () {
      final f = WikiFactsClient.parseDidYouKnow(_enDyk, 'en');
      expect(f.map((e) => e.text), [
        '…that the Amber Room was given to Peter the Great?',
        '…that the tea clipper raced & won in 1866?',
      ]);
      expect(f.first.hasImage, isTrue);
      expect(f.first.title, 'Amber Room');
    });

    test('"On this day" needs a year and keeps the article link', () {
      final f = WikiFactsClient.parseOnThisDay(_otd(), 'ru', 5, 27);
      expect(f, hasLength(2));
      expect(f[0].text, 'Основан Санкт-Петербург.');
      expect(f[0].year, 1703);
      expect(f[0].title, 'Санкт-Петербург');
      expect(f[0].hasImage, isTrue);
      expect(f[0].id, 'otd:ru:527:1703:Санкт-Петербург');
      expect(f[1].url, isNull);
      expect(f[1].id, startsWith('otd:ru:527:1935:'));
    });

    test('empty or malformed answers give no facts', () {
      expect(WikiFactsClient.parseOnThisDay(null, 'en', 1, 1), isEmpty);
      expect(WikiFactsClient.parseOnThisDay({'selected': 'x'}, 'en', 1, 1), isEmpty);
      expect(WikiFactsClient.parseDidYouKnow('<p>nothing</p>', 'en'), isEmpty);
    });

    test('unescape handles common entities', () {
      expect(
        WikiFactsClient.unescape('a&#160;b &quot;c&quot; &#39;d&#39; &lt;e&gt; &#1072; &amp;amp;'),
        'a b "c" \'d\' <e> а &amp;',
      );
    });

    test('langOf maps locales to the two supported wikis', () {
      expect(WikiFactsClient.langOf('ru'), 'ru');
      expect(WikiFactsClient.langOf('ru_RU'), 'ru');
      expect(WikiFactsClient.langOf('en'), 'en');
      expect(WikiFactsClient.langOf('de'), 'en');
    });

    test('requests hit the right endpoints', () async {
      final seen = <Uri>[];
      final client = WikiFactsClient(
        fakeDio((o) {
          seen.add(o.uri);
          return o.uri.path.contains('onthisday')
              ? _otd()
              : {
                  'parse': {'text': _enDyk},
                };
        }),
      );
      expect(await client.onThisDay('ru', 3, 7), hasLength(2));
      expect(seen.last.toString(), 'https://ru.wikipedia.org/api/rest_v1/feed/onthisday/selected/03/07');
      expect(await client.didYouKnow('en'), hasLength(2));
      expect(seen.last.host, 'en.wikipedia.org');
      expect(seen.last.queryParameters['text'], '{{Did you know}}');
      expect(seen.last.queryParameters['title'], 'Main Page');
    });
  });

  group('InterestingFactsRepository', () {
    late TestEnv env;
    setUp(() async => env = await TestEnv.create());
    tearDown(() => env.dispose());

    const desc =
        'Памятник открыт в 1910 году на средства горожан. Автор — скульптор из Петербурга. Реставрирован в 2005 году.';

    test('placeFact uses the lead of the description', () {
      final p = Place(
        source: PlaceSource.wikipedia,
        sourceId: 'ru:1',
        title: 'Памятник',
        lat: 59,
        lon: 30,
        description: desc,
        yearStart: 1910,
        url: 'https://ru.wikipedia.org/wiki/X',
      );
      final f = InterestingFactsRepository.placeFact(p)!;
      expect(f.id, 'place:wikipedia:ru:1');
      expect(f.kind, FactKind.nearby);
      expect(f.text, 'Памятник открыт в 1910 году на средства горожан. Автор — скульптор из Петербурга.');
      expect(f.year, 1910);
      expect(f.title, 'Памятник');
    });

    test('placeFact skips places without a meaningful text', () {
      expect(InterestingFactsRepository.placeFact(place('n/1', summary: 'Памятник')), isNull);
    });

    test('nearby offers unvisited, non-photo places from the last map load', () async {
      final osm = FakeClient(
        PlaceSource.osm,
        places: [
          place('n/1', summary: desc),
          place('n/2', summary: desc, lat: 59.001),
          place('n/3', summary: desc, category: PlaceCategory.photo, lat: 59.002),
        ],
      );
      await env.placesRepo([osm]).nearby(const PlaceQuery(lat: 59, lon: 30), sources: {PlaceSource.osm});
      await env.activity.addVisit(Visit.fromPlace(place('n/2'), VisitMethod.manual, DateTime(2026)));

      final repo = InterestingFactsRepository(WikiFactsClient(Dio()), env.placesRepo([osm]), env.activity);
      expect((await repo.nearby()).map((f) => f.id), ['place:osm:n/1']);
    });

    test('network failures give an empty list instead of an error', () async {
      final repo = InterestingFactsRepository(
        WikiFactsClient(fakeDio((_) => 500)),
        env.placesRepo(const []),
        env.activity,
      );
      expect(await repo.didYouKnow('ru'), isEmpty);
      expect(await repo.onThisDay('ru', 1, 1), isEmpty);
      expect(await repo.nearby(), isEmpty);
    });
  });

  group('PlacesRepositoryImpl.recentlyLoaded', () {
    test('returns the latest load only, nearest to its centre first', () async {
      var now = DateTime(2026, 1, 1, 12);
      final osm = FakeClient(PlaceSource.osm, places: [place('old')]);
      final wiki = FakeClient(PlaceSource.wikipedia);
      final env = await TestEnv.create();
      addTearDown(env.dispose);
      final repo = env.placesRepo([osm, wiki], clock: () => now);

      expect(await repo.recentlyLoaded(), isEmpty);
      await repo.nearby(const PlaceQuery(lat: 10, lon: 10), sources: {PlaceSource.osm});

      now = now.add(const Duration(hours: 2));
      osm.places = [place('far', lat: 59.02), place('near', lat: 59.001)];
      wiki.places = [place('mid', source: PlaceSource.wikipedia, lat: 59.01)];
      await repo.nearby(const PlaceQuery(lat: 59, lon: 30), sources: {PlaceSource.osm, PlaceSource.wikipedia});

      final ids = (await repo.recentlyLoaded()).map((p) => p.sourceId).toList();
      expect(ids, ['near', 'mid', 'far']);
      expect(await repo.recentlyLoaded(limit: 1), hasLength(1));
    });
  });
}
