import 'day.dart';

class Trek {
  final String id;
  final String name;
  final String region;
  final String difficulty;
  final int totalDays;
  final String coverGradient;
  final String? coverImageUrl; // user-set cover photo URL
  final String description;
  final List<TrekDay> days;
  final String createdAt;
  final bool completed;

  const Trek({
    required this.id,
    required this.name,
    required this.region,
    required this.difficulty,
    required this.totalDays,
    required this.coverGradient,
    this.coverImageUrl,
    required this.description,
    required this.days,
    required this.createdAt,
    this.completed = false,
  });

  Trek copyWith({
    String? name, String? region, String? difficulty, int? totalDays,
    String? coverGradient, String? coverImageUrl, bool clearCoverImage = false,
    String? description, List<TrekDay>? days, String? createdAt, bool? completed,
  }) => Trek(
    id:            id,
    name:          name           ?? this.name,
    region:        region         ?? this.region,
    difficulty:    difficulty     ?? this.difficulty,
    totalDays:     totalDays      ?? this.totalDays,
    coverGradient: coverGradient  ?? this.coverGradient,
    coverImageUrl: clearCoverImage ? null : (coverImageUrl ?? this.coverImageUrl),
    description:   description    ?? this.description,
    days:          days           ?? this.days,
    createdAt:     createdAt      ?? this.createdAt,
    completed:     completed      ?? this.completed,
  );

  factory Trek.fromJson(Map<String, dynamic> json) => Trek(
    id:            json['id'] as String,
    name:          json['name'] as String,
    region:        json['region'] as String? ?? '',
    difficulty:    json['difficulty'] as String? ?? 'Moderate',
    totalDays:     json['totalDays'] as int,
    coverGradient: json['coverGradient'] as String? ?? '',
    coverImageUrl: json['coverImageUrl'] as String?,
    description:   json['description'] as String? ?? '',
    days:          (json['days'] as List).map((d) => TrekDay.fromJson(d as Map<String, dynamic>)).toList(),
    createdAt:     json['createdAt'] as String? ?? '',
    completed:     json['completed'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'region': region, 'difficulty': difficulty,
    'totalDays': totalDays, 'coverGradient': coverGradient,
    if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
    'description': description, 'days': days.map((d) => d.toJson()).toList(),
    'createdAt': createdAt, 'completed': completed,
  };

  int get stopsCount => days.fold(0, (sum, d) => sum + d.stops.length);
  int get daysLogged  => days.where((d) => d.stops.isNotEmpty).length;
  double get progress => totalDays > 0 ? daysLogged / totalDays : 0;
}
