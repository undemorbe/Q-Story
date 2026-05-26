/// Payload for `POST /post-info`. Maps 1:1 to the backend contract:
///
/// ```json
/// {
///   "marker":   { "id", "lat", "lon", "title", "type", "compressed-description" },
///   "building": { "id", "title", "compressed-description", "description":{top,main,bottom},
///                 "image", "date-start", "date-end", "type", "person", "resources":[] }
/// }
/// ```
class MarkerSubmissionEntity {
  final MarkerPayload marker;
  final BuildingPayload building;

  const MarkerSubmissionEntity({
    required this.marker,
    required this.building,
  });

  Map<String, dynamic> toJson() => {
        'marker': marker.toJson(),
        'building': building.toJson(),
      };
}

class MarkerPayload {
  final String id;
  final double lat;
  final double lon;
  final String title;
  final String type;
  final String compressedDescription;

  const MarkerPayload({
    required this.id,
    required this.lat,
    required this.lon,
    required this.title,
    required this.type,
    required this.compressedDescription,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'lat': lat.toString(),
        'lon': lon.toString(),
        'title': title,
        'type': type,
        'compressed-description': compressedDescription,
      };
}

class BuildingPayload {
  final String id;
  final String title;
  final String compressedDescription;
  final String descriptionTop;
  final String descriptionMain;
  final String descriptionBottom;
  final String image;
  final String dateStart;
  final String dateEnd;
  final String type;
  final String person;
  final List<String> resources;

  const BuildingPayload({
    required this.id,
    required this.title,
    required this.compressedDescription,
    required this.descriptionTop,
    required this.descriptionMain,
    required this.descriptionBottom,
    required this.image,
    required this.dateStart,
    required this.dateEnd,
    required this.type,
    required this.person,
    required this.resources,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'compressed-description': compressedDescription,
        'description': {
          'top': descriptionTop,
          'main': descriptionMain,
          'bottom': descriptionBottom,
        },
        'image': image,
        'date-start': dateStart,
        'date-end': dateEnd,
        'type': type,
        'person': person,
        'resources': resources,
      };
}
