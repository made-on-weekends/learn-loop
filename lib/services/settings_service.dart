import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kid_profile.dart';

class SettingsService {
  static const String _kidProfileKey = 'learn_loop_kid_profile';

  static final ValueNotifier<KidProfile> kidProfileNotifier =
      ValueNotifier<KidProfile>(const KidProfile());

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kidProfileKey);
      if (jsonStr != null) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        kidProfileNotifier.value = KidProfile.fromJson(map);
      }
    } catch (e) {
      debugPrint('Error loading KidProfile settings: $e');
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

  static KidProfile get currentKidProfile => kidProfileNotifier.value;
}
