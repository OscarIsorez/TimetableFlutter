import 'package:shared_preferences/shared_preferences.dart';

Future<String?> selectUrlFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('url') ?? "";
}

String setUrlFromStorage() {
  selectUrlFromStorage().then((value) => value);
  return selectUrlFromStorage().toString();
}
