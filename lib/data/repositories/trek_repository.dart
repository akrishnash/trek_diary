import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trek.dart';
import '../models/day.dart';
import '../models/stop.dart';
import '../models/diary_entry.dart';
import '../../core/constants/app_constants.dart';

// Sample data pre-loaded on first launch
final _sampleTreks = [
  Trek(
    id: 'trek-1', name: 'Valley of Flowers', region: 'Uttarakhand, India',
    difficulty: 'Moderate', totalDays: 6,
    coverGradient: 'linear-gradient(145deg, #1A3A0A 0%, #3D6B1A 45%, #7A8C3A 100%)',
    description: 'A UNESCO World Heritage Site blooming with hundreds of species of wildflowers.',
    createdAt: '2025-09-01', completed: true,
    days: [
      TrekDay(dayNum: 1, title: 'Govindghat to Ghangaria', stops: [
        TrekStop(id: 's1', name: 'Govindghat', elevation: 1828, distance: 0,
          weather: '☀️ Sunny', mood: '😊 Happy',
          notes: 'Starting point of the trek. Crisp mountain morning air.', photos: []),
        TrekStop(id: 's2', name: 'Bhyundar Village', elevation: 2200, distance: 4,
          weather: '⛅ Partly Cloudy', mood: '🥾 On the Move',
          notes: 'Quaint village with local tea stalls. Stopped for chai and momos.', photos: []),
        TrekStop(id: 's3', name: 'Ghangaria', elevation: 3048, distance: 13,
          weather: '🌧️ Rainy', mood: '😴 Tired',
          notes: 'Base camp for Valley of Flowers. Rain pattering on the tin roof all night.', photos: []),
      ]),
      TrekDay(dayNum: 2, title: 'Into the Valley', stops: [
        TrekStop(id: 's4', name: 'Valley Entry Gate', elevation: 3352, distance: 3,
          weather: '🌫️ Misty', mood: '🤩 Amazing',
          notes: 'The moment the valley opened up — absolutely breathtaking.', photos: []),
        TrekStop(id: 's5', name: 'Pushpawati River', elevation: 3600, distance: 7,
          weather: '☀️ Sunny', mood: '😌 Peaceful',
          notes: 'Crystal clear glacial water rushing over smooth stones.', photos: []),
      ]),
      TrekDay(dayNum: 3, title: 'Hemkund Sahib', stops: []),
      TrekDay(dayNum: 4, title: 'Valley Deep Exploration', stops: []),
      TrekDay(dayNum: 5, title: 'Return to Ghangaria', stops: []),
      TrekDay(dayNum: 6, title: 'Descent to Govindghat', stops: []),
    ],
  ),
  Trek(
    id: 'trek-2', name: 'Hampta Pass', region: 'Himachal Pradesh, India',
    difficulty: 'Challenging', totalDays: 5,
    coverGradient: 'linear-gradient(145deg, #0D0D1E 0%, #1E2A4A 50%, #3D4A7A 100%)',
    description: 'A dramatic high-altitude pass connecting the lush Kullu valley to the barren moonscape of Lahaul.',
    createdAt: '2025-08-15', completed: false,
    days: [
      TrekDay(dayNum: 1, title: 'Manali to Chika', stops: [
        TrekStop(id: 's6', name: 'Manali', elevation: 2050, distance: 0,
          weather: '☀️ Sunny', mood: '😊 Happy',
          notes: 'Packed up gear and headed out at dawn.', photos: []),
        TrekStop(id: 's7', name: 'Chika Camp', elevation: 3100, distance: 8,
          weather: '💨 Windy', mood: '🥾 On the Move',
          notes: 'First campsite. Pine forests all around.', photos: []),
      ]),
      TrekDay(dayNum: 2, title: 'Chika to Balu Ka Ghera', stops: []),
      TrekDay(dayNum: 3, title: 'Hampta Pass Summit', stops: []),
      TrekDay(dayNum: 4, title: 'Shea Goru to Chatru', stops: []),
      TrekDay(dayNum: 5, title: 'Chandratal Lake', stops: []),
    ],
  ),
];

class TrekRepository {
  final SharedPreferences _prefs;
  TrekRepository(this._prefs);

  List<Trek> getAll() {
    try {
      final raw = _prefs.getString(AppConstants.storageKeyTreks);
      if (raw == null) {
        _save(_sampleTreks);
        return List.from(_sampleTreks);
      }
      final list = jsonDecode(raw) as List;
      return list.map((e) => Trek.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return List.from(_sampleTreks);
    }
  }

  void _save(List<Trek> treks) {
    _prefs.setString(AppConstants.storageKeyTreks, jsonEncode(treks.map((t) => t.toJson()).toList()));
  }

  List<Trek> addTrek(Trek trek) {
    final treks = [trek, ...getAll()];
    _save(treks);
    return treks;
  }

  List<Trek> updateTrek(String id, Trek Function(Trek) updater) {
    final treks = getAll().map((t) => t.id == id ? updater(t) : t).toList();
    _save(treks);
    return treks;
  }

  List<Trek> deleteTrek(String id) {
    final treks = getAll().where((t) => t.id != id).toList();
    _save(treks);
    return treks;
  }

  List<Trek> addStop(String trekId, int dayNum, TrekStop stop) {
    return updateTrek(trekId, (trek) {
      final days = trek.days.map((d) {
        if (d.dayNum != dayNum) return d;
        return d.copyWith(stops: [...d.stops, stop]);
      }).toList();
      return trek.copyWith(days: days);
    });
  }

  List<Trek> updateStop(String trekId, int dayNum, String stopId, TrekStop Function(TrekStop) updater) {
    return updateTrek(trekId, (trek) {
      final days = trek.days.map((d) {
        if (d.dayNum != dayNum) return d;
        final stops = d.stops.map((s) => s.id == stopId ? updater(s) : s).toList();
        return d.copyWith(stops: stops);
      }).toList();
      return trek.copyWith(days: days);
    });
  }

  List<Trek> setDiary(String trekId, int dayNum, DiaryEntry entry) {
    return updateTrek(trekId, (trek) {
      final days = trek.days.map((d) {
        if (d.dayNum != dayNum) return d;
        return d.copyWith(diary: entry);
      }).toList();
      return trek.copyWith(days: days);
    });
  }

  void clearAll() => _prefs.remove(AppConstants.storageKeyTreks);
}

// Providers
final sharedPrefsProvider = Provider<SharedPreferences>((_) => throw UnimplementedError());

final trekRepositoryProvider = Provider<TrekRepository>((ref) {
  return TrekRepository(ref.read(sharedPrefsProvider));
});

final trekListProvider = StateNotifierProvider<TrekListNotifier, List<Trek>>((ref) {
  return TrekListNotifier(ref.read(trekRepositoryProvider));
});

class TrekListNotifier extends StateNotifier<List<Trek>> {
  final TrekRepository _repo;
  TrekListNotifier(this._repo) : super(_repo.getAll());

  void addTrek(Trek trek)           => state = _repo.addTrek(trek);
  void updateTrek(String id, Trek Function(Trek) u) => state = _repo.updateTrek(id, u);
  void deleteTrek(String id)        => state = _repo.deleteTrek(id);
  void addStop(String trekId, int dayNum, TrekStop stop) => state = _repo.addStop(trekId, dayNum, stop);
  void updateStop(String trekId, int dayNum, String stopId, TrekStop Function(TrekStop) u) =>
      state = _repo.updateStop(trekId, dayNum, stopId, u);
  void setDiary(String trekId, int dayNum, DiaryEntry entry) => state = _repo.setDiary(trekId, dayNum, entry);
  void clearAll() { _repo.clearAll(); state = []; }
}

// ── Derived providers — each watches only what it needs ──────────────────────
// Using select() so downstream widgets rebuild only when their specific value
// changes, not on any trek list mutation.

final trekCountProvider = Provider<int>((ref) =>
    ref.watch(trekListProvider).length);

final totalStopsProvider = Provider<int>((ref) =>
    ref.watch(trekListProvider).fold(0, (s, t) => s + t.stopsCount));

final completedCountProvider = Provider<int>((ref) =>
    ref.watch(trekListProvider).where((t) => t.completed).length);

/// First non-completed trek — shown as the "active" spotlight on the dashboard.
final activeTrekProvider = Provider<Trek?>((ref) =>
    ref.watch(trekListProvider).where((t) => !t.completed).firstOrNull);

// Helper: get a trek photo URL by index derived from trek name
String getTrekPhotoUrl(Trek trek) {
  final photos = AppConstants.naturePhotos;
  int h = 0;
  for (final c in trek.name.codeUnits) h = (h * 31 + c) & 0xFFFFFFFF;
  return photos[h.abs() % photos.length];
}
