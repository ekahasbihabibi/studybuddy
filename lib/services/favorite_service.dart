import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _key = 'favorite_module_ids';

  static Future<List<String>> getFavoriteModuleIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> toggleFavorite(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];

    if (current.contains(moduleId)) {
      current.remove(moduleId);
    } else {
      current.add(moduleId);
    }

    await prefs.setStringList(_key, current);
  }

  static Future<bool> isFavorite(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    return current.contains(moduleId);
  }
}
