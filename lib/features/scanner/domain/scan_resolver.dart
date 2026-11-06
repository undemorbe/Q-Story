import '../../../core/errors/failures.dart';
import '../../../core/util/result.dart';
import '../../places/domain/entities/place.dart';
import '../../places/domain/repositories/places_repository.dart';
import '../../places/domain/services/qr_payload_parser.dart';

sealed class ScanOutcome {
  const ScanOutcome();
}

class ScanFoundPlace extends ScanOutcome {
  const ScanFoundPlace(this.place);
  final Place place;
}

class ScanLink extends ScanOutcome {
  const ScanLink(this.uri);
  final Uri uri;
}

class ScanUnknown extends ScanOutcome {
  const ScanUnknown(this.raw);
  final String raw;
}

class ScanFailed extends ScanOutcome {
  const ScanFailed(this.failure);
  final Failure failure;
}

/// Turns a raw QR payload into a concrete place using the open sources.
class ScanResolver {
  ScanResolver(this._repo);
  final PlacesRepository _repo;

  Future<ScanOutcome> resolve(String raw, {String language = 'ru'}) async {
    final target = QrPayloadParser.parse(raw);
    switch (target) {
      case QrInlinePlace(place: final p):
        await _repo.remember(p);
        return ScanFoundPlace(p);
      case QrPlaceRef(source: final s, sourceId: final id):
        final r = await _repo.details(s, id, language: language, preferCache: false);
        return switch (r) {
          Ok(value: final p) => ScanFoundPlace(p),
          Err(failure: final f) => ScanFailed(f),
        };
      case QrExternalLink(uri: final u):
        return ScanLink(u);
      case QrUnknown(raw: final r):
        return ScanUnknown(r);
    }
  }
}
