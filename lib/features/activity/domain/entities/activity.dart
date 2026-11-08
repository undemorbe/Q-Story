import '../../../places/domain/entities/place.dart';
import '../../../places/domain/entities/place_source.dart';

/// How the user proved they were at a place.
enum VisitMethod { qr, geofence, manual }

/// A place the user has physically discovered.
class Visit {
  const Visit({
    required this.placeId,
    required this.title,
    required this.source,
    required this.category,
    required this.lat,
    required this.lon,
    required this.at,
    required this.method,
  });

  factory Visit.fromPlace(Place p, VisitMethod method, DateTime at) => Visit(
    placeId: p.id,
    title: p.title,
    source: p.source,
    category: p.category,
    lat: p.lat,
    lon: p.lon,
    at: at,
    method: method,
  );

  final String placeId;
  final String title;
  final PlaceSource source;
  final PlaceCategory category;
  final double lat;
  final double lon;
  final DateTime at;
  final VisitMethod method;

  Map<String, Object?> toJson() => {
    'placeId': placeId,
    'title': title,
    'source': source.name,
    'category': category.name,
    'lat': lat,
    'lon': lon,
    'at': at.millisecondsSinceEpoch,
    'method': method.name,
  };

  factory Visit.fromJson(Map<String, Object?> j) => Visit(
    placeId: j['placeId'] as String,
    title: (j['title'] as String?) ?? '',
    source: PlaceSource.parse(j['source'] as String?),
    category: PlaceCategory.parse(j['category'] as String?),
    lat: (j['lat'] as num?)?.toDouble() ?? 0,
    lon: (j['lon'] as num?)?.toDouble() ?? 0,
    at: DateTime.fromMillisecondsSinceEpoch(j['at'] as int),
    method: VisitMethod.values.firstWhere((m) => m.name == j['method'], orElse: () => VisitMethod.manual),
  );
}

enum HuntStatus { active, found, abandoned }

/// A "search" session: from the moment the user picks a target place until
/// they reach it (or give up). Captures how much effort finding it took.
class Hunt {
  const Hunt({
    required this.id,
    required this.placeId,
    required this.placeTitle,
    required this.targetLat,
    required this.targetLon,
    required this.startedAt,
    this.endedAt,
    this.status = HuntStatus.active,
    this.steps = 0,
    this.distanceM = 0,
    this.startDistanceM,
    this.stepsEstimated = false,
  });

  final String id;
  final String placeId;
  final String placeTitle;
  final double targetLat;
  final double targetLon;
  final DateTime startedAt;
  final DateTime? endedAt;
  final HuntStatus status;
  final int steps;
  final double distanceM;

  /// Straight-line distance to the target when the hunt started.
  final double? startDistanceM;

  /// True if the device had no step counter and steps were derived from GPS.
  final bool stepsEstimated;

  Duration duration(DateTime now) => (endedAt ?? now).difference(startedAt);

  /// Walked distance divided by straight-line distance (≥ 1; 1 = perfect).
  double? get detourRatio {
    final s = startDistanceM;
    if (s == null || s < 20 || distanceM <= 0) return null;
    return distanceM / s;
  }

  Hunt copyWith({DateTime? endedAt, HuntStatus? status, int? steps, double? distanceM, bool? stepsEstimated}) => Hunt(
    id: id,
    placeId: placeId,
    placeTitle: placeTitle,
    targetLat: targetLat,
    targetLon: targetLon,
    startedAt: startedAt,
    endedAt: endedAt ?? this.endedAt,
    status: status ?? this.status,
    steps: steps ?? this.steps,
    distanceM: distanceM ?? this.distanceM,
    startDistanceM: startDistanceM,
    stepsEstimated: stepsEstimated ?? this.stepsEstimated,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'placeId': placeId,
    'placeTitle': placeTitle,
    'targetLat': targetLat,
    'targetLon': targetLon,
    'startedAt': startedAt.millisecondsSinceEpoch,
    'endedAt': endedAt?.millisecondsSinceEpoch,
    'status': status.name,
    'steps': steps,
    'distanceM': distanceM,
    'startDistanceM': startDistanceM,
    'stepsEstimated': stepsEstimated,
  };

  factory Hunt.fromJson(Map<String, Object?> j) => Hunt(
    id: j['id'] as String,
    placeId: j['placeId'] as String,
    placeTitle: (j['placeTitle'] as String?) ?? '',
    targetLat: (j['targetLat'] as num).toDouble(),
    targetLon: (j['targetLon'] as num).toDouble(),
    startedAt: DateTime.fromMillisecondsSinceEpoch(j['startedAt'] as int),
    endedAt: j['endedAt'] == null ? null : DateTime.fromMillisecondsSinceEpoch(j['endedAt'] as int),
    status: HuntStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => HuntStatus.abandoned),
    steps: (j['steps'] as num?)?.toInt() ?? 0,
    distanceM: (j['distanceM'] as num?)?.toDouble() ?? 0,
    startDistanceM: (j['startDistanceM'] as num?)?.toDouble(),
    stepsEstimated: (j['stepsEstimated'] as bool?) ?? false,
  );
}

/// Per-day movement aggregate. [hourSteps] has 24 buckets.
class DayActivity {
  DayActivity({
    required this.day,
    this.steps = 0,
    this.distanceM = 0,
    this.activeSeconds = 0,
    this.maxSpeedMps = 0,
    List<int>? hourSteps,
  }) : hourSteps = hourSteps ?? List<int>.filled(24, 0);

  /// Local date formatted as `yyyy-MM-dd`.
  final String day;
  int steps;
  double distanceM;
  int activeSeconds;
  double maxSpeedMps;
  final List<int> hourSteps;

  DateTime get date => DateTime.parse(day);

  static String keyOf(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  Map<String, Object?> toJson() => {
    'day': day,
    'steps': steps,
    'distanceM': distanceM,
    'activeSeconds': activeSeconds,
    'maxSpeedMps': maxSpeedMps,
    'hourSteps': hourSteps,
  };

  factory DayActivity.fromJson(Map<String, Object?> j) => DayActivity(
    day: j['day'] as String,
    steps: (j['steps'] as num?)?.toInt() ?? 0,
    distanceM: (j['distanceM'] as num?)?.toDouble() ?? 0,
    activeSeconds: (j['activeSeconds'] as num?)?.toInt() ?? 0,
    maxSpeedMps: (j['maxSpeedMps'] as num?)?.toDouble() ?? 0,
    hourSteps: ((j['hourSteps'] as List?) ?? List.filled(24, 0)).map((e) => (e as num).toInt()).toList(),
  );
}

enum ActivityEventType {
  scan,
  view,
  favorite,
  unfavorite,
  visit,
  huntStart,
  huntFound,
  huntAbandon,
  placesLoaded,
  userPlaceCreated,
}

/// Append-only event log used for statistics.
class ActivityEvent {
  const ActivityEvent({required this.type, required this.at, this.placeId, this.source, this.value});

  final ActivityEventType type;
  final DateTime at;
  final String? placeId;
  final PlaceSource? source;

  /// Free numeric payload (e.g. number of places loaded).
  final num? value;

  Map<String, Object?> toJson() => {
    'type': type.name,
    'at': at.millisecondsSinceEpoch,
    'placeId': placeId,
    'source': source?.name,
    'value': value,
  };

  factory ActivityEvent.fromJson(Map<String, Object?> j) => ActivityEvent(
    type: ActivityEventType.values.firstWhere((t) => t.name == j['type'], orElse: () => ActivityEventType.view),
    at: DateTime.fromMillisecondsSinceEpoch(j['at'] as int),
    placeId: j['placeId'] as String?,
    source: j['source'] == null ? null : PlaceSource.parse(j['source'] as String),
    value: j['value'] as num?,
  );
}
