class TrekStop {
  final String id;
  final String name;
  final int elevation;
  final double distance;
  final String weather;
  final String mood;
  final String notes;
  final List<String> photos; // base64 or file paths

  const TrekStop({
    required this.id,
    required this.name,
    required this.elevation,
    required this.distance,
    required this.weather,
    required this.mood,
    required this.notes,
    required this.photos,
  });

  TrekStop copyWith({
    String? name, int? elevation, double? distance,
    String? weather, String? mood, String? notes, List<String>? photos,
  }) => TrekStop(
    id:        id,
    name:      name      ?? this.name,
    elevation: elevation ?? this.elevation,
    distance:  distance  ?? this.distance,
    weather:   weather   ?? this.weather,
    mood:      mood      ?? this.mood,
    notes:     notes     ?? this.notes,
    photos:    photos    ?? this.photos,
  );

  factory TrekStop.fromJson(Map<String, dynamic> json) => TrekStop(
    id:        json['id'] as String,
    name:      json['name'] as String,
    elevation: json['elevation'] as int? ?? 0,
    distance:  (json['distance'] as num?)?.toDouble() ?? 0.0,
    weather:   json['weather'] as String? ?? '☀️ Sunny',
    mood:      json['mood'] as String? ?? '😊 Happy',
    notes:     json['notes'] as String? ?? '',
    photos:    List<String>.from(json['photos'] as List? ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'elevation': elevation, 'distance': distance,
    'weather': weather, 'mood': mood, 'notes': notes, 'photos': photos,
  };
}
