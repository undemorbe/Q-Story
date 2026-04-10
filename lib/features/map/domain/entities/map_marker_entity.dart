class MapMarkerEntity {
  final String id;
  final double lat;
  final double lon;
  final String title;
  final String compressedDescription;
  final String type;
  final bool isCompleted;

  const MapMarkerEntity({
    required this.id,
    required this.lat,
    required this.lon,
    required this.title,
    required this.compressedDescription,
    required this.type,
    this.isCompleted = false,
  });
}
