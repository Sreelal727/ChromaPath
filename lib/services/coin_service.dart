import 'package:shared_preferences/shared_preferences.dart';

class CoinService {
  static const _coinsKey = 'user_coins';
  static const _startingCoins = 50;
  static const solveReward = 25;
  static const revealPathCost = 30;
  static const solvePuzzleCost = 75;

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_coinsKey)) {
      await prefs.setInt(_coinsKey, _startingCoins);
      return _startingCoins;
    }
    return prefs.getInt(_coinsKey) ?? _startingCoins;
  }

  static Future<int> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_coinsKey) ?? _startingCoins;
    final updated = current + amount;
    await prefs.setInt(_coinsKey, updated);
    return updated;
  }

  static Future<int?> spendCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_coinsKey) ?? _startingCoins;
    if (current < amount) return null; // Not enough coins
    final updated = current - amount;
    await prefs.setInt(_coinsKey, updated);
    return updated;
  }

  static Future<bool> canAfford(int amount) async {
    final coins = await getCoins();
    return coins >= amount;
  }
}
