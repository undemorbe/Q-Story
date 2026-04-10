import '../../domain/entities/map_marker_entity.dart';

class MapMarkerModel extends MapMarkerEntity {
  const MapMarkerModel({
    required super.id,
    required super.lat,
    required super.lon,
    required super.title,
    required super.compressedDescription,
    required super.type,
    super.isCompleted,
  });

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) {
    return MapMarkerModel(
      id: json['id'] as String,
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lon: double.tryParse(json['lon'].toString()) ?? 0.0,
      title: json['title'] as String,
      compressedDescription: json['compressed-description'] as String? ?? '',
      type: json['type'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': lat,
      'lon': lon,
      'title': title,
      'compressed-description': compressedDescription,
      'type': type,
      'isCompleted': isCompleted,
    };
  }

  MapMarkerModel copyWith({
    String? id,
    double? lat,
    double? lon,
    String? title,
    String? compressedDescription,
    String? type,
    bool? isCompleted,
  }) {
    return MapMarkerModel(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      title: title ?? this.title,
      compressedDescription: compressedDescription ?? this.compressedDescription,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
