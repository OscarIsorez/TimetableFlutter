import 'package:flutter/material.dart';
import 'package:timetableapp/components/App_Theme.dart';
import 'package:timetableapp/pages/home_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();

  runApp(const MyApp());
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]).then((_) {
  //   runApp(const MyApp());
  // });
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
      // darkTheme: AppTheme.darkTheme,
      home: const MyHomePage(),
    );
  }
}
