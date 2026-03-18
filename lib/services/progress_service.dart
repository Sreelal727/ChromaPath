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

  static Future<void> markCompleted(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$levelId', true);
    final current = prefs.getInt(_highestUnlocked) ?? 1;
    if (levelId >= current) {
      await prefs.setInt(_highestUnlocked, levelId + 1);
    }
  }

  static Future<int> getHighestUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highestUnlocked) ?? 1;
  }
}
