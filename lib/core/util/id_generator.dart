import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Deterministic-ish ID derived from user-provided text and entropy.
///
/// Combines:
///  * caller-supplied strings (title, descriptions, coords) → semantic
///    fingerprint of the content the user typed,
///  * current millisecond timestamp → uniqueness across submissions of
///    the same text,
///  * 32 random bits → uniqueness within the same millisecond.
///
/// Result is base36 of the SHA-1 of the joined input, truncated. Example:
/// `mr2lqf8wzs4k9xa3` for a marker, `mr2lqf8wzs4k9xa4` for the matching
/// building (using a different prefix).
class IdGenerator {
  static final _random = Random.secure();

  /// Generate a 22-char lowercase ID prefixed with [prefix] (1 char).
  ///
  /// `prefix='m'` → marker, `'b'` → building.
  static String generate({
    required String prefix,
    required List<String> parts,
  }) {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final salt = _random.nextInt(0xFFFFFFFF);
    final joined = '$prefix|${parts.join('|')}|$ts|$salt';
    final digest = sha1.convert(utf8.encode(joined));
    return prefix + _toBase36(digest.bytes).substring(0, 21);
  }

  /// Big-int base36 encoding of byte buffer.
  static String _toBase36(List<int> bytes) {
    BigInt n = BigInt.zero;
    for (final b in bytes) {
      n = (n << 8) | BigInt.from(b);
    }
    return n.toRadixString(36).padLeft(31, '0');
  }
}
