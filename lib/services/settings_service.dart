import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kid_profile.dart';

class SavedWorksheetSeed {
  final String activityId;
  final String title;
  final int seed;
  final DateTime timestamp;
  final Map<String, dynamic> configMap;

  const SavedWorksheetSeed({
    required this.activityId,
    required this.title,
    required this.seed,
    required this.timestamp,
    this.configMap = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'title': title,
      'seed': seed,
      'timestamp': timestamp.toIso8601String(),
      'configMap': configMap,
    };
  }

  factory SavedWorksheetSeed.fromJson(Map<String, dynamic> json) {
    return SavedWorksheetSeed(
      activityId: json['activityId'] as String,
      title: json['title'] as String,
      seed: json['seed'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      configMap: json['configMap'] is Map
          ? Map<String, dynamic>.from(json['configMap'] as Map)
          : const {},
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedWorksheetSeed &&
          runtimeType == other.runtimeType &&
          activityId == other.activityId &&
          seed == other.seed;

  @override
  int get hashCode => activityId.hashCode ^ seed.hashCode;
}

class SettingsService {
  static const String _kidProfileKey = 'learn_loop_kid_profile';
  static const String _recentsKey = 'learn_loop_recents';
  static const String _favoritesKey = 'learn_loop_favorites';

  static final ValueNotifier<KidProfile> kidProfileNotifier =
      ValueNotifier<KidProfile>(const KidProfile());

  static final ValueNotifier<List<SavedWorksheetSeed>> recentsNotifier =
      ValueNotifier<List<SavedWorksheetSeed>>([]);

  static final ValueNotifier<List<SavedWorksheetSeed>> favoritesNotifier =
      ValueNotifier<List<SavedWorksheetSeed>>([]);

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Kid Profile
      final jsonStr = prefs.getString(_kidProfileKey);
      if (jsonStr != null) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        kidProfileNotifier.value = KidProfile.fromJson(map);
      }

      // 2. Recents
      final recentsStr = prefs.getString(_recentsKey);
      if (recentsStr != null) {
        final List list = jsonDecode(recentsStr);
        recentsNotifier.value = list
            .map(
              (e) => SavedWorksheetSeed.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }

      // 3. Favorites
      final favStr = prefs.getString(_favoritesKey);
      if (favStr != null) {
        final List list = jsonDecode(favStr);
        favoritesNotifier.value = list
            .map(
              (e) => SavedWorksheetSeed.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading SettingsService: $e');
    } finally {
      _initialized = true;
    }
  }

  static Future<void> saveKidProfile(KidProfile profile) async {
    kidProfileNotifier.value = profile;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kidProfileKey, jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('Error saving KidProfile settings: $e');
    }
  }

  static Future<void> addRecentWorksheet(SavedWorksheetSeed seed) async {
    final updated = List<SavedWorksheetSeed>.from(recentsNotifier.value);
    updated.removeWhere(
      (item) => item.activityId == seed.activityId && item.seed == seed.seed,
    );
    updated.insert(0, seed);
    if (updated.length > 20) {
      updated.removeLast();
    }
    recentsNotifier.value = updated;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _recentsKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving recents: $e');
    }
  }

  static Future<void> toggleFavorite(SavedWorksheetSeed seed) async {
    final updated = List<SavedWorksheetSeed>.from(favoritesNotifier.value);
    final exists = updated.any(
      (item) => item.activityId == seed.activityId && item.seed == seed.seed,
    );
    if (exists) {
      updated.removeWhere(
        (item) => item.activityId == seed.activityId && item.seed == seed.seed,
      );
    } else {
      updated.insert(0, seed);
    }
    favoritesNotifier.value = updated;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _favoritesKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  static bool isFavorite(String activityId, int seed) {
    return favoritesNotifier.value.any(
      (item) => item.activityId == activityId && item.seed == seed,
    );
  }

  static KidProfile get currentKidProfile => kidProfileNotifier.value;
}
