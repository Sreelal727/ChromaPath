import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _prefix = 'level_completed_';
  static const _highestUnlocked = 'highest_unlocked';

  static Future<Set<int>> getCompletedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    return keys
        .map((k) => int.tryParse(k.replaceFirst(_prefix, '')))
        .whereType<int>()
        .toSet();
  }

  /// Marks a level completed and returns true if this is the FIRST time
  /// (so caller can award coins).
  static Future<bool> markCompleted(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$levelId';
    final alreadyDone = prefs.getBool(key) ?? false;
    await prefs.setBool(key, true);
    final current = prefs.getInt(_highestUnlocked) ?? 1;
    if (levelId >= current) {
      await prefs.setInt(_highestUnlocked, levelId + 1);
    }
    return !alreadyDone;
  }

  static Future<int> getHighestUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highestUnlocked) ?? 1;
  }
}
