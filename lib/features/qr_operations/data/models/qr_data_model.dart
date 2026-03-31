class QrDataModel {
  final String id;
  final String title;
  final String compressedDescription;
  final String description;
  final String? imageUrl;
  final String? yearRange;

  final String? type; // 'history', 'landmark', etc.

  const QrDataModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.yearRange,
    this.type,
  });

  factory QrDataModel.fromJson(Map<String, dynamic> json) {
    return QrDataModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      yearRange: json['yearRange'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'yearRange': yearRange,
      'type': type,
    };
  }
}
