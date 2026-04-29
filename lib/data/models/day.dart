import 'stop.dart';
import 'diary_entry.dart';

class TrekDay {
  final int dayNum;
  final String title;
  final List<TrekStop> stops;
  final DiaryEntry? diary;

  const TrekDay({
    required this.dayNum,
    required this.title,
    required this.stops,
    this.diary,
  });

  TrekDay copyWith({
    int? dayNum, String? title, List<TrekStop>? stops, DiaryEntry? diary,
    bool clearDiary = false,
  }) => TrekDay(
    dayNum: dayNum ?? this.dayNum,
    title:  title  ?? this.title,
    stops:  stops  ?? this.stops,
    diary:  clearDiary ? null : (diary ?? this.diary),
  );

  factory TrekDay.fromJson(Map<String, dynamic> json) => TrekDay(
    dayNum: json['dayNum'] as int,
    title:  json['title'] as String? ?? 'Day ${json['dayNum']}',
    stops:  (json['stops'] as List).map((s) => TrekStop.fromJson(s as Map<String, dynamic>)).toList(),
    diary:  json['diary'] != null ? DiaryEntry.fromJson(json['diary'] as Map<String, dynamic>) : null,
  );

  Map<String, dynamic> toJson() => {
    'dayNum': dayNum,
    'title': title,
    'stops': stops.map((s) => s.toJson()).toList(),
    if (diary != null) 'diary': diary!.toJson(),
  };
}
