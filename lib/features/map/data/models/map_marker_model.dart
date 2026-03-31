import '../../domain/entities/map_marker_entity.dart';

class MapMarkerModel extends MapMarkerEntity {
  const MapMarkerModel({
    required super.id,
    required super.latitude,
    required super.longitude,
    required super.title,
    required super.description,
    super.isCompleted,
  });

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) {
    return MapMarkerModel(
      id: json['id'] as String,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['long'] as num).toDouble(),
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': latitude,
      'long': longitude,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  MapMarkerModel copyWith({
    String? id,
    double? latitude,
    double? longitude,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return MapMarkerModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
