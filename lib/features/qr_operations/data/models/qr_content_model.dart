class QrContentModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? type;

  const QrContentModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.type,
  });

  factory QrContentModel.fromJson(Map<String, dynamic> json) {
    return QrContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String?,
    );
  }
}
