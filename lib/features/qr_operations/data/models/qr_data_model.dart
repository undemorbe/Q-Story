class PlaceDescription {
  final String top;
  final String main;
  final String bottom;

  const PlaceDescription({
    required this.top,
    required this.main,
    required this.bottom,
  });

  factory PlaceDescription.fromJson(Map<String, dynamic> json) {
    return PlaceDescription(
      top: json['top'] as String? ?? '',
      main: json['main'] as String? ?? '',
      bottom: json['bottom'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top': top,
      'main': main,
      'bottom': bottom,
    };
  }
}

class QrDataModel {
  final String id;
  final String title;
  final String compressedDescription;
  final PlaceDescription description;
  final String? image;
  final String? dateStart;
  final String? dateEnd;
  final String type;
  final String? person;
  final List<String> resources;

  const QrDataModel({
    required this.id,
    required this.title,
    required this.compressedDescription,
    required this.description,
    required this.type,
    this.image,
    this.dateStart,
    this.dateEnd,
    this.person,
    this.resources = const [],
  });

  factory QrDataModel.fromJson(Map<String, dynamic> json) {
    return QrDataModel(
      id: json['id'] as String,
      title: json['title'] as String,
      compressedDescription: json['compressed-description'] as String? ?? '',
      description: PlaceDescription.fromJson(json['description'] as Map<String, dynamic>),
      type: json['type'] as String,
      image: json['image'] as String?,
      dateStart: json['date-start'] as String?,
      dateEnd: json['date-end'] as String?,
      person: json['person'] as String?,
      resources: (json['resources'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'compressed-description': compressedDescription,
      'description': description.toJson(),
      'type': type,
      'image': image,
      'date-start': dateStart,
      'date-end': dateEnd,
      'person': person,
      'resources': resources,
    };
  }

  /// Helper to get a displayable year range from date-start and date-end
  /// Formats ISO 8601 dates (e.g., "1918-02-01T00:00:00Z") to human readable format
  String? get yearRange {
    String? formatDate(String? isoDate) {
      if (isoDate == null || isoDate.isEmpty) return null;
      try {
        final dateTime = DateTime.parse(isoDate);
        // Format as "1 февраля 1918" or "February 1, 1918" depending on locale
        final months = [
          'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
          'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
        ];
        return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
      } catch (_) {
        return isoDate; // Fallback to original if parsing fails
      }
    }

    final formattedStart = formatDate(dateStart);
    final formattedEnd = formatDate(dateEnd);

    if (formattedStart != null && formattedEnd != null) {
      return '$formattedStart — $formattedEnd';
    } else if (formattedStart != null) {
      return formattedStart;
    } else if (formattedEnd != null) {
      return formattedEnd;
    }
    return null;
  }

  /// Helper to get full description as a single string
  String get fullDescription {
    final parts = [
      if (description.top.isNotEmpty) description.top,
      if (description.main.isNotEmpty) description.main,
      if (description.bottom.isNotEmpty) description.bottom,
    ];
    return parts.join('\n\n');
  }
}
