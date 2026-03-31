class MapMarkerEntity {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final bool isCompleted;

  const MapMarkerEntity({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}
