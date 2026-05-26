import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/util/id_generator.dart';

void main() {
  group('IdGenerator', () {
    test('generate returns 22-char ID with correct prefix', () {
      final id = IdGenerator.generate(
        prefix: 'm',
        parts: ['Test Marker', 'Short desc'],
      );

      expect(id.length, 22);
      expect(id.startsWith('m'), true);
      expect(id, matches(RegExp(r'^[a-z0-9]+$')));
    });

    test('generate with different prefix changes first char', () {
      const parts = ['Same content', 'for both'];

      final markerIdM = IdGenerator.generate(prefix: 'm', parts: parts);
      final markerIdB = IdGenerator.generate(prefix: 'b', parts: parts);

      expect(markerIdM.startsWith('m'), true);
      expect(markerIdB.startsWith('b'), true);
      expect(markerIdM.substring(1), isNotEmpty);
      expect(markerIdB.substring(1), isNotEmpty);
    });

    test('same content generates different IDs due to timestamp/salt', () {
      const parts = ['Building', 'Historic site'];

      final id1 = IdGenerator.generate(prefix: 'b', parts: parts);
      final id2 = IdGenerator.generate(prefix: 'b', parts: parts);

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1 != id2, true);
    });

    test('different content generates different IDs', () {
      final id1 = IdGenerator.generate(
        prefix: 'm',
        parts: ['Content A', 'desc'],
      );
      final id2 = IdGenerator.generate(
        prefix: 'm',
        parts: ['Content B', 'desc'],
      );

      expect(id1 != id2, true);
    });

    test('generate handles empty parts list', () {
      final id = IdGenerator.generate(prefix: 'm', parts: []);

      expect(id.length, 22);
      expect(id.startsWith('m'), true);
    });

    test('generate handles unicode characters in parts', () {
      final id = IdGenerator.generate(
        prefix: 'b',
        parts: ['Москва', '日本', 'القاهرة'],
      );

      expect(id.length, 22);
      expect(id.startsWith('b'), true);
    });

    test('generate with many parts still produces 22-char ID', () {
      final id = IdGenerator.generate(
        prefix: 'm',
        parts: List.generate(10, (i) => 'Part $i'),
      );

      expect(id.length, 22);
    });

    test('prefix affects only first character', () {
      const parts = ['Test', 'Data'];
      final idM = IdGenerator.generate(prefix: 'm', parts: parts);
      final idB = IdGenerator.generate(prefix: 'b', parts: parts);

      expect(idM[0], 'm');
      expect(idB[0], 'b');
      expect(idM.substring(1).runes.length, 21);
      expect(idB.substring(1).runes.length, 21);
    });
  });
}
