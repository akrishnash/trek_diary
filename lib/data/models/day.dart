import 'stop.dart';

class TrekDay {
  final int dayNum;
  final String title;
  final List<TrekStop> stops;

  const TrekDay({
    required this.dayNum,
    required this.title,
    required this.stops,
  });

  TrekDay copyWith({int? dayNum, String? title, List<TrekStop>? stops}) => TrekDay(
    dayNum: dayNum ?? this.dayNum,
    title:  title  ?? this.title,
    stops:  stops  ?? this.stops,
  );

  factory TrekDay.fromJson(Map<String, dynamic> json) => TrekDay(
    dayNum: json['dayNum'] as int,
    title:  json['title'] as String? ?? 'Day ${json['dayNum']}',
    stops:  (json['stops'] as List).map((s) => TrekStop.fromJson(s as Map<String, dynamic>)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'dayNum': dayNum,
    'title': title,
    'stops': stops.map((s) => s.toJson()).toList(),
  };
}
