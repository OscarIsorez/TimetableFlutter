import 'package:flutter/material.dart';
import 'package:timetableapp/components/app_Theme.dart';
import 'package:timetableapp/pages/home_page.dart';
import 'package:timetableapp/sharedpreference_helper.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper().init();
  tz.initializeTimeZones();

  runApp(const MyApp());
}

//
//
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timetable',
      theme: AppTheme.lightTheme,
      home: const MyHomePage(),
    );
  }
}
