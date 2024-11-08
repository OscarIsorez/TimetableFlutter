import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._internal();
  SharedPreferences? _preferences;

  factory SharedPreferencesHelper() {
    return _instance;
  }

  SharedPreferencesHelper._internal();

  // Méthode pour initialiser SharedPreferences, appelée une seule fois
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Méthode pour récupérer une valeur synchrone
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  // Méthode pour sauvegarder une valeur de manière synchrone
  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }
}
