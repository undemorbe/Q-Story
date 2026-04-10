class HistoryEntity {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String yearRange;
  final List<String> resources;

  const HistoryEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.yearRange,
    this.resources = const [],
  });
}
